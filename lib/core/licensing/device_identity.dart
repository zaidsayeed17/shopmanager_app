import 'dart:convert';
import 'package:cryptography/cryptography.dart';
import 'package:flutter/services.dart';
import 'request_code.dart';

class DeviceUnsupportedException implements Exception {
  final String message;
  const DeviceUnsupportedException([this.message = 'Device is unsupported']);
  @override
  String toString() => message;
}

class KeystoreUnavailableException implements Exception {
  final String message;
  const KeystoreUnavailableException([this.message = 'Keystore is unavailable']);
  @override
  String toString() => message;
}

class KeyMissingException implements Exception {
  final String message;
  const KeyMissingException([this.message = 'Device key is missing']);
  @override
  String toString() => message;
}

class KeyUnusableException implements Exception {
  final String message;
  const KeyUnusableException([this.message = 'Device key is unusable']);
  @override
  String toString() => message;
}

class DeviceKeyInfo {
  final Uint8List publicKeyDer;
  final String securityLevel;

  const DeviceKeyInfo({
    required this.publicKeyDer,
    required this.securityLevel,
  });
}

abstract class DeviceIdentity {
  Future<DeviceKeyInfo> getDeviceKey();
  Future<bool> proveKeyUsable();
  Future<List<int>> getFingerprint();
  Future<String> getRequestCode();
}

class AndroidDeviceIdentity implements DeviceIdentity {
  static const MethodChannel _channel = MethodChannel('shopmanager/device_key');

  List<int>? _cachedFingerprint;
  String? _cachedRequestCode;

  @override
  Future<DeviceKeyInfo> getDeviceKey() async {
    try {
      final res = await _channel.invokeMethod<Map<dynamic, dynamic>>('getDeviceKey');
      if (res == null) {
        throw const KeystoreUnavailableException('Null response from getDeviceKey');
      }

      final derBase64 = res['publicKeyDer'] as String?;
      final securityLevel = res['securityLevel'] as String? ?? 'unknown';

      if (derBase64 == null) {
        throw const KeystoreUnavailableException('Public key DER is missing');
      }

      final derBytes = Uint8List.fromList(base64Decode(derBase64));
      return DeviceKeyInfo(
        publicKeyDer: derBytes,
        securityLevel: securityLevel,
      );
    } on PlatformException catch (e) {
      _mapPlatformException(e);
      rethrow;
    }
  }

  @override
  Future<bool> proveKeyUsable() async {
    try {
      final res = await _channel.invokeMethod<bool>('proveKeyUsable');
      return res ?? false;
    } on PlatformException catch (e) {
      _mapPlatformException(e);
      rethrow;
    }
  }

  @override
  Future<List<int>> getFingerprint() async {
    if (_cachedFingerprint != null) return _cachedFingerprint!;
    final keyInfo = await getDeviceKey();
    final sha256 = Sha256();
    final digest = await sha256.hash(keyInfo.publicKeyDer);
    _cachedFingerprint = digest.bytes.sublist(0, 16);
    return _cachedFingerprint!;
  }

  @override
  Future<String> getRequestCode() async {
    if (_cachedRequestCode != null) return _cachedRequestCode!;
    final fp = await getFingerprint();
    _cachedRequestCode = RequestCode.encode(fp);
    return _cachedRequestCode!;
  }

  void _mapPlatformException(PlatformException e) {
    switch (e.code) {
      case 'DEVICE_UNSUPPORTED':
        throw DeviceUnsupportedException(e.message ?? 'Device requires Android 6.0 (API 23)+');
      case 'KEYSTORE_UNAVAILABLE':
        throw KeystoreUnavailableException(e.message ?? 'Keystore unavailable');
      case 'KEY_MISSING':
        throw KeyMissingException(e.message ?? 'Device key missing');
      case 'KEY_UNUSABLE':
        throw KeyUnusableException(e.message ?? 'Device key unusable');
      default:
        throw KeystoreUnavailableException(e.message ?? e.toString());
    }
  }
}

class FakeDeviceIdentity implements DeviceIdentity {
  final Uint8List publicKeyDer;
  final String securityLevel;
  final bool isUsable;
  final bool isUnsupported;

  FakeDeviceIdentity({
    Uint8List? publicKeyDer,
    this.securityLevel = 'strongbox',
    this.isUsable = true,
    this.isUnsupported = false,
  }) : publicKeyDer = publicKeyDer ?? Uint8List.fromList(List<int>.generate(91, (i) => i));

  @override
  Future<DeviceKeyInfo> getDeviceKey() async {
    if (isUnsupported) {
      throw const DeviceUnsupportedException();
    }
    return DeviceKeyInfo(
      publicKeyDer: publicKeyDer,
      securityLevel: securityLevel,
    );
  }

  @override
  Future<bool> proveKeyUsable() async {
    if (isUnsupported) {
      throw const DeviceUnsupportedException();
    }
    if (!isUsable) {
      throw const KeyUnusableException();
    }
    return true;
  }

  @override
  Future<List<int>> getFingerprint() async {
    if (isUnsupported) {
      throw const DeviceUnsupportedException();
    }
    final sha256 = Sha256();
    final digest = await sha256.hash(publicKeyDer);
    return digest.bytes.sublist(0, 16);
  }

  @override
  Future<String> getRequestCode() async {
    final fp = await getFingerprint();
    return RequestCode.encode(fp);
  }
}
