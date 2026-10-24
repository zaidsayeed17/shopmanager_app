import 'dart:convert';
import 'dart:io';
import 'package:cryptography/cryptography.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopmanager/core/licensing/license_service.dart';
import 'package:shopmanager/core/licensing/license_storage.dart';
import 'package:shopmanager/core/licensing/license_verifier.dart';
import 'package:shopmanager/core/licensing/request_code.dart';
import 'package:shopmanager/core/licensing/trusted_keys.dart';

void main() {
  group('RequestCode Tests', () {
    test('16-byte fingerprint encodes and decodes correctly', () {
      final fp = List<int>.generate(16, (i) => i * 13 % 256);
      final code = RequestCode.encode(fp);
      expect(code.length, 33);
      final decoded = RequestCode.decode(code);
      expect(decoded, equals(fp));
    });

    test('Tolerates formatting, whitespace, quotes, dashes and case', () {
      final fp = [10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 110, 120, 130, 140, 150, 160];
      final code = RequestCode.encode(fp);
      final mangled = ' "${code.toLowerCase()}" \n';
      final decoded = RequestCode.decode(mangled);
      expect(decoded, equals(fp));
    });

    test('Catches typos using check character', () {
      final fp = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16];
      final code = RequestCode.encode(fp);

      final chars = code.split('');
      chars[chars.length - 1] = chars[chars.length - 1] == '0' ? '1' : '0';
      final badCode = chars.join('');

      expect(() => RequestCode.decode(badCode), throwsA(isA<FormatException>()));
    });
  });

  group('LicenseVerifier Tests', () {
    late SimpleKeyPair testKeyPair;
    late SimplePublicKey testPublicKey;
    late String testKid;
    late TrustedKey testTrustedKey;
    late List<int> testFingerprint;

    setUp(() async {
      final ed25519 = Ed25519();
      testKeyPair = await ed25519.newKeyPair();
      testPublicKey = await testKeyPair.extractPublicKey();

      final sha256 = Sha256();
      final hash = await sha256.hash(testPublicKey.bytes);
      testKid = hash.bytes.sublist(0, 8).map((b) => b.toRadixString(16).padLeft(2, '0')).join();

      testTrustedKey = TrustedKey(
        kid: testKid,
        name: 'test',
        publicKeyBytes: testPublicKey.bytes,
      );

      testFingerprint = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16];
    });

    Future<String> createTestToken({
      String? kid,
      int v = 1,
      String product = 'shopmanager',
      String customer = 'Test Customer',
      String? shop = 'Test Shop',
      List<int>? fp,
      SimpleKeyPair? keyToSignWith,
    }) async {
      final payloadMap = {
        'v': v,
        'kid': kid ?? testKid,
        'lid': 'LID-TEST-001',
        'product': product,
        'customer': customer,
        'shop': ?shop,
        'fp': base64Url.encode(fp ?? testFingerprint),
        'iat': 1700000000,
      };

      final payloadBytes = utf8.encode(jsonEncode(payloadMap));
      final contextBytes = ascii.encode("ShopManagerLicense/v1\n");
      final signedMessage = [...contextBytes, ...payloadBytes];

      final ed25519 = Ed25519();
      final sig = await ed25519.sign(signedMessage, keyPair: keyToSignWith ?? testKeyPair);

      return '${base64Url.encode(payloadBytes).replaceAll('=', '')}.${base64Url.encode(sig.bytes).replaceAll('=', '')}';
    }

    test('Valid license token verifies successfully', () async {
      final verifier = LicenseVerifier(trustedKeys: [testTrustedKey]);
      final token = await createTestToken();
      final info = await verifier.verifyToken(token);

      expect(info.v, 1);
      expect(info.kid, testKid);
      expect(info.product, 'shopmanager');
      expect(info.customer, 'Test Customer');
      expect(info.shop, 'Test Shop');
      expect(info.fingerprint, equals(testFingerprint));
    });

    test('Tolerates surrounding quotes and whitespace from WhatsApp', () async {
      final verifier = LicenseVerifier(trustedKeys: [testTrustedKey]);
      final token = await createTestToken();
      final wrapped = '\n  "$token"  \r\n';
      final info = await verifier.verifyToken(wrapped);

      expect(info.customer, 'Test Customer');
    });

    test('Tampered payload fails verification', () async {
      final verifier = LicenseVerifier(trustedKeys: [testTrustedKey]);
      final token = await createTestToken();

      final parts = token.split('.');
      final rawPayload = utf8.decode(base64Url.decode(base64.normalize(parts[0])));
      final tamperedJson = rawPayload.replaceAll('Test Customer', 'Hacked Customer');
      final tamperedPayloadPart = base64Url.encode(utf8.encode(tamperedJson)).replaceAll('=', '');
      final tamperedToken = '$tamperedPayloadPart.${parts[1]}';

      expect(
        () => verifier.verifyToken(tamperedToken),
        throwsA(isA<LicenseSignatureException>()),
      );
    });

    test('Tampered signature fails verification', () async {
      final verifier = LicenseVerifier(trustedKeys: [testTrustedKey]);
      final token = await createTestToken();

      final parts = token.split('.');
      final sigBytes = base64Url.decode(base64.normalize(parts[1]));
      sigBytes[0] = (sigBytes[0] + 1) % 256;
      final tamperedSig = base64Url.encode(sigBytes).replaceAll('=', '');
      final tamperedToken = '${parts[0]}.$tamperedSig';

      expect(
        () => verifier.verifyToken(tamperedToken),
        throwsA(isA<LicenseSignatureException>()),
      );
    });

    test('License signed by untrusted key fails', () async {
      final otherKeyPair = await Ed25519().newKeyPair();
      final token = await createTestToken(keyToSignWith: otherKeyPair);

      final verifier = LicenseVerifier(trustedKeys: [testTrustedKey]);
      expect(
        () => verifier.verifyToken(token),
        throwsA(isA<LicenseSignatureException>()),
      );
    });

    test('Unknown kid fails verification', () async {
      final token = await createTestToken(kid: 'unknown-kid-xyz');
      final verifier = LicenseVerifier(trustedKeys: [testTrustedKey]);

      expect(
        () => verifier.verifyToken(token),
        throwsA(isA<LicenseFormatException>()),
      );
    });

    test('Wrong product fails verification', () async {
      final token = await createTestToken(product: 'other_app');
      final verifier = LicenseVerifier(trustedKeys: [testTrustedKey]);

      expect(
        () => verifier.verifyToken(token),
        throwsA(isA<LicenseFormatException>()),
      );
    });

    test('Unsupported version fails verification', () async {
      final token = await createTestToken(v: 2);
      final verifier = LicenseVerifier(trustedKeys: [testTrustedKey]);

      expect(
        () => verifier.verifyToken(token),
        throwsA(isA<LicenseFormatException>()),
      );
    });

    test('Empty trustedKeys list reports notConfigured', () async {
      final verifier = LicenseVerifier(trustedKeys: []);
      final token = await createTestToken();

      expect(
        () => verifier.verifyToken(token),
        throwsA(isA<LicenseConfigurationException>()),
      );
    });

    test('Golden vector produced by developer tool verifies exactly', () async {
      const goldenKid = '65b60673d6ed884b';
      const goldenPubBytes = [
        121, 181, 86, 46, 143, 230, 84, 249, 64, 120, 177, 18, 232, 169, 139, 167,
        144, 31, 133, 58, 230, 149, 190, 215, 224, 227, 145, 11, 173, 4, 150, 100
      ];
      const goldenFp = [10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 110, 120, 130, 140, 150, 160];
      const goldenToken =
          'eyJ2IjoxLCJraWQiOiI2NWI2MDY3M2Q2ZWQ4ODRiIiwibGlkIjoiTElELVRFU1QtMjAyNjEwMjMtR09MREVOIiwicHJvZHVjdCI6InNob3BtYW5hZ2VyIiwiY3VzdG9tZXIiOiJHb2xkZW4gQ3VzdG9tZXIiLCJzaG9wIjoiR29sZGVuIFRleHRpbGVzIiwiZnAiOiJDaFFlS0RJOFJsQmFaRzU0Z295V29BPT0iLCJpYXQiOjE3NjExNzc2MDB9.02nQSK2N8kRBqfSEKD9o0sGbQudy7ortQQV107pd_e12WFqt7zBMxZe0-AU9Ft313aHtkmybZrLxAgPOe4LlAQ';

      final goldenTrustedKey = TrustedKey(
        kid: goldenKid,
        name: 'golden',
        publicKeyBytes: goldenPubBytes,
      );

      final verifier = LicenseVerifier(trustedKeys: [goldenTrustedKey]);
      final info = await verifier.verifyToken(goldenToken);

      expect(info.customer, 'Golden Customer');
      expect(info.shop, 'Golden Textiles');
      expect(info.lid, 'LID-TEST-20261023-GOLDEN');
      expect(info.fingerprint, equals(goldenFp));
    });
  });

  group('LicenseStorage & Isolation Tests', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('storage_test_');
    });

    tearDown(() async {
      if (tempDir.existsSync()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('Atomically writes and reads license token', () async {
      final storage = LicenseStorage(tempDir);
      expect(await storage.readLicenseToken(), isNull);

      await storage.writeLicenseToken('test.sample.token');
      expect(await storage.readLicenseToken(), 'test.sample.token');
      expect(await storage.hasLicenseFile(), isTrue);
    });

    test('License file lives outside the database and survives table wipe', () async {
      final storage = LicenseStorage(tempDir);
      await storage.writeLicenseToken('persistent.license.token');

      // Simulate a database factory reset or database delete
      final mockDbFile = File('${tempDir.path}${Platform.pathSeparator}app_database.db');
      await mockDbFile.writeAsString('fake database content');
      expect(mockDbFile.existsSync(), isTrue);

      // Simulate Restore Backup replacing or deleting the DB file
      await mockDbFile.delete();
      expect(mockDbFile.existsSync(), isFalse);

      // Verify license is untouched!
      expect(await storage.readLicenseToken(), 'persistent.license.token');
    });
  });

  group('Debug Bypass & Policy Tests', () {
    test('licenseBypassAllowed returns false in release mode', () {
      expect(licenseBypassAllowed(isRelease: true, defineFlag: true), isFalse);
      expect(licenseBypassAllowed(isRelease: true, defineFlag: false), isFalse);
      expect(licenseBypassAllowed(isRelease: false, defineFlag: false), isFalse);
      expect(licenseBypassAllowed(isRelease: false, defineFlag: true), isTrue);
    });
  });

  group('Repository Audit Verification', () {
    test('Confirm NO private key or signing calls exist anywhere under lib/', () {
      final libDir = Directory('lib');
      final dartFiles = libDir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));

      for (final file in dartFiles) {
        final content = file.readAsStringSync();
        // Disallow signing methods or private key generation in lib/
        expect(
          content.contains('.sign('),
          isFalse,
          reason: 'Signing call found in lib/: ${file.path}',
        );
        expect(
          content.contains('newKeyPair('),
          isFalse,
          reason: 'newKeyPair call found in lib/: ${file.path}',
        );
        expect(
          content.contains('newKeyPairFromSeed('),
          isFalse,
          reason: 'newKeyPairFromSeed call found in lib/: ${file.path}',
        );
      }
    });
  });
}
