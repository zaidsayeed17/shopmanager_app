import 'dart:convert';
import 'dart:typed_data';
import 'package:cryptography/cryptography.dart';
import 'trusted_keys.dart';

class LicenseVerificationException implements Exception {
  final String message;
  const LicenseVerificationException(this.message);
  @override
  String toString() => message;
}

class LicenseSignatureException extends LicenseVerificationException {
  const LicenseSignatureException(super.message);
}

class LicenseFormatException extends LicenseVerificationException {
  const LicenseFormatException(super.message);
}

class LicenseConfigurationException extends LicenseVerificationException {
  const LicenseConfigurationException(super.message);
}

class LicenseInfo {
  final int v;
  final String kid;
  final String lid;
  final String product;
  final String customer;
  final String? shop;
  final List<int> fingerprint;
  final int iat;
  final String rawToken;

  const LicenseInfo({
    required this.v,
    required this.kid,
    required this.lid,
    required this.product,
    required this.customer,
    this.shop,
    required this.fingerprint,
    required this.iat,
    required this.rawToken,
  });
}

class LicenseVerifier {
  static const String contextPrefix = "ShopManagerLicense/v1\n";
  final List<TrustedKey> trustedKeys;

  LicenseVerifier({required this.trustedKeys});

  /// Sanitizes raw token text from user input (strips WhatsApp wrapping, quotes, spaces).
  static String sanitizeToken(String raw) {
    var cleaned = raw.trim();
    // Strip surrounding single or double quotes
    if ((cleaned.startsWith('"') && cleaned.endsWith('"')) ||
        (cleaned.startsWith("'") && cleaned.endsWith("'"))) {
      cleaned = cleaned.substring(1, cleaned.length - 1).trim();
    }
    // Remove all whitespace, line breaks, carriage returns
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), '');
    return cleaned;
  }

  /// Verifies the token according to the fixed specification:
  /// 1. Token cleanup
  /// 2. Split payload & signature
  /// 3. Verify signature BEFORE parsing JSON (using context string + raw payload bytes)
  /// 4. Parse JSON without re-serializing
  /// 5. Validate required fields (v, kid, product, lid, customer, fp)
  Future<LicenseInfo> verifyToken(String rawToken) async {
    final token = sanitizeToken(rawToken);

    if (trustedKeys.isEmpty) {
      throw const LicenseConfigurationException('Licensing is not configured (no trusted keys embedded)');
    }

    final parts = token.split('.');
    if (parts.length != 2) {
      throw const LicenseFormatException('Not a ShopManager license or damaged or incomplete (copy it again)');
    }

    final Uint8List payloadBytes;
    final Uint8List signatureBytes;
    try {
      payloadBytes = Uint8List.fromList(base64Url.decode(base64.normalize(parts[0])));
      signatureBytes = Uint8List.fromList(base64Url.decode(base64.normalize(parts[1])));
    } catch (_) {
      throw const LicenseFormatException('Not a ShopManager license or damaged or incomplete (copy it again)');
    }

    if (signatureBytes.length != 64) {
      throw const LicenseSignatureException('Invalid signature length (tampered or corrupted token)');
    }

    // Context-bound message: "ShopManagerLicense/v1\n" + raw payloadBytes
    final contextBytes = ascii.encode(contextPrefix);
    final signedMessage = Uint8List(contextBytes.length + payloadBytes.length)
      ..setRange(0, contextBytes.length, contextBytes)
      ..setRange(contextBytes.length, contextBytes.length + payloadBytes.length, payloadBytes);

    // Verify signature BEFORE parsing JSON
    final algorithm = Ed25519();
    TrustedKey? matchingTrustedKey;

    for (final key in trustedKeys) {
      final pubKey = SimplePublicKey(key.publicKeyBytes, type: KeyPairType.ed25519);
      final ok = await algorithm.verify(
        signedMessage,
        signature: Signature(signatureBytes, publicKey: pubKey),
      );
      if (ok) {
        matchingTrustedKey = key;
        break;
      }
    }

    if (matchingTrustedKey == null) {
      throw const LicenseSignatureException('Signed by an unrecognized key (an app update is needed)');
    }

    // Parse JSON only after signature verification succeeded
    final Map<String, dynamic> json;
    try {
      final utf8String = utf8.decode(payloadBytes);
      json = jsonDecode(utf8String) as Map<String, dynamic>;
    } catch (_) {
      throw const LicenseFormatException('License payload is not valid JSON');
    }

    // Validate fields
    final v = json['v'];
    if (v is! int || v != 1) {
      throw const LicenseFormatException('Unsupported license version');
    }

    final product = json['product'];
    if (product != 'shopmanager') {
      throw const LicenseFormatException('Wrong product license');
    }

    final kid = json['kid'];
    if (kid != matchingTrustedKey.kid) {
      throw const LicenseFormatException('Key ID mismatch in signed payload');
    }

    final lid = json['lid'];
    if (lid is! String || lid.trim().isEmpty) {
      throw const LicenseFormatException('Missing license ID');
    }

    final customer = json['customer'];
    if (customer is! String || customer.trim().isEmpty) {
      throw const LicenseFormatException('Missing customer name');
    }

    final shop = json['shop'] as String?;

    final fpRaw = json['fp'];
    final List<int> fingerprint;
    if (fpRaw is String) {
      // Decode base64 or hex
      if (fpRaw.length == 32 && RegExp(r'^[0-9a-fA-F]+$').hasMatch(fpRaw)) {
        fingerprint = _hexDecode(fpRaw);
      } else {
        fingerprint = base64Url.decode(base64.normalize(fpRaw));
      }
    } else if (fpRaw is List) {
      fingerprint = fpRaw.map((e) => (e as num).toInt()).toList();
    } else {
      throw const LicenseFormatException('Missing or invalid device fingerprint');
    }

    if (fingerprint.length != 16) {
      throw const LicenseFormatException('Device fingerprint must be exactly 16 bytes');
    }

    final iat = json['iat'] is int ? json['iat'] as int : 0;

    return LicenseInfo(
      v: v,
      kid: kid,
      lid: lid,
      product: product,
      customer: customer,
      shop: shop,
      fingerprint: fingerprint,
      iat: iat,
      rawToken: token,
    );
  }

  static List<int> _hexDecode(String hex) {
    final result = <int>[];
    for (int i = 0; i < hex.length; i += 2) {
      result.add(int.parse(hex.substring(i, i + 2), radix: 16));
    }
    return result;
  }
}
