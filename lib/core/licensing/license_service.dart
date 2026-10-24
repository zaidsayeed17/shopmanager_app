import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'device_identity.dart';
import 'license_storage.dart';
import 'license_verifier.dart';
import 'trusted_keys.dart';

bool licenseBypassAllowed({required bool isRelease, required bool defineFlag}) {
  return !isRelease && defineFlag;
}

sealed class LicenseState {
  const LicenseState();
}

class LicenseChecking extends LicenseState {
  const LicenseChecking();
}

class LicenseLicensed extends LicenseState {
  final LicenseInfo info;
  final bool isBypass;
  const LicenseLicensed(this.info, {this.isBypass = false});
}

class LicenseUnlicensed extends LicenseState {
  const LicenseUnlicensed();
}

class LicenseInvalid extends LicenseState {
  final String reason;
  const LicenseInvalid(this.reason);
}

class LicenseWrongDevice extends LicenseState {
  const LicenseWrongDevice();
}

class LicenseVerifyError extends LicenseState {
  final String message;
  const LicenseVerifyError(this.message);
}

class LicenseDeviceUnsupported extends LicenseState {
  const LicenseDeviceUnsupported();
}

class LicenseNotConfigured extends LicenseState {
  const LicenseNotConfigured();
}

class LicenseService extends Notifier<LicenseState> with WidgetsBindingObserver {
  bool _hasEverPassedInProcess = false;

  DeviceIdentity get _deviceIdentity => ref.read(deviceIdentityProvider);
  LicenseStorage get _storage => ref.read(licenseStorageProvider);
  LicenseVerifier get _verifier => ref.read(licenseVerifierProvider);

  bool get _isBypass => licenseBypassAllowed(
        isRelease: kReleaseMode,
        defineFlag: const bool.fromEnvironment('LICENSE_BYPASS', defaultValue: false),
      );

  @override
  LicenseState build() {
    WidgetsBinding.instance.addObserver(this);
    ref.onDispose(() {
      WidgetsBinding.instance.removeObserver(this);
    });

    Future.microtask(() => checkLicense());

    return const LicenseChecking();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      checkLicense();
    }
  }

  /// Verifies license on cold start or app resume.
  Future<void> checkLicense() async {
    if (_isBypass) {
      const dummyInfo = LicenseInfo(
        v: 1,
        kid: 'debug-bypass',
        lid: 'debug-bypass-lid',
        product: 'shopmanager',
        customer: 'Debug User',
        shop: 'Development Mode',
        fingerprint: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15],
        iat: 0,
        rawToken: '',
      );
      state = const LicenseLicensed(dummyInfo, isBypass: true);
      return;
    }

    if (_verifier.trustedKeys.isEmpty) {
      state = const LicenseNotConfigured();
      return;
    }

    try {
      final token = await _storage.readLicenseToken();
      if (token == null || token.isEmpty) {
        state = const LicenseUnlicensed();
        return;
      }

      // 1. Verify token cryptographic signature & structure
      final info = await _verifier.verifyToken(token);

      // 2. Obtain device fingerprint
      final deviceFp = await _deviceIdentity.getFingerprint();

      // 3. Compare fingerprints byte-for-byte
      if (!_fingerprintEquals(info.fingerprint, deviceFp)) {
        state = const LicenseWrongDevice();
        return;
      }

      // 4. Prove device key is usable
      final usable = await _deviceIdentity.proveKeyUsable();
      if (!usable) {
        state = const LicenseVerifyError('Device security key could not be used.');
        return;
      }

      _hasEverPassedInProcess = true;
      state = LicenseLicensed(info);
    } on DeviceUnsupportedException {
      state = const LicenseDeviceUnsupported();
    } on LicenseConfigurationException {
      state = const LicenseNotConfigured();
    } on LicenseSignatureException catch (e) {
      state = LicenseInvalid(e.message);
    } on LicenseFormatException catch (e) {
      state = LicenseInvalid(e.message);
    } on KeyMissingException {
      state = const LicenseInvalid('Device security key is missing.');
    } on KeyUnusableException {
      state = const LicenseVerifyError('Device security key could not be used.');
    } on KeystoreUnavailableException catch (e) {
      // If a check already passed in this process and a later check fails with a TRANSIENT
      // Keystore error, keep the licensed state; otherwise report retryable verifyError.
      if (!_hasEverPassedInProcess) {
        state = LicenseVerifyError(e.message);
      }
    } catch (e) {
      if (!_hasEverPassedInProcess) {
        state = LicenseVerifyError(e.toString());
      }
    }
  }

  /// Attempts to activate with a new license token provided by the user.
  Future<bool> activate(String rawToken) async {
    if (_verifier.trustedKeys.isEmpty) {
      state = const LicenseNotConfigured();
      return false;
    }

    state = const LicenseChecking();

    try {
      // 1. Verify token cryptographic signature & format
      final info = await _verifier.verifyToken(rawToken);

      // 2. Fetch device fingerprint
      final deviceFp = await _deviceIdentity.getFingerprint();

      // 3. Assert device match
      if (!_fingerprintEquals(info.fingerprint, deviceFp)) {
        state = const LicenseWrongDevice();
        return false;
      }

      // 4. Prove key usability
      final usable = await _deviceIdentity.proveKeyUsable();
      if (!usable) {
        state = const LicenseVerifyError('Device security key could not be verified.');
        return false;
      }

      // 5. Atomically store verified token
      await _storage.writeLicenseToken(info.rawToken);

      _hasEverPassedInProcess = true;
      state = LicenseLicensed(info);
      return true;
    } on DeviceUnsupportedException {
      state = const LicenseDeviceUnsupported();
      return false;
    } on LicenseConfigurationException {
      state = const LicenseNotConfigured();
      return false;
    } on LicenseSignatureException catch (e) {
      state = LicenseInvalid(e.message);
      return false;
    } on LicenseFormatException catch (e) {
      state = LicenseInvalid(e.message);
      return false;
    } on KeyMissingException {
      state = const LicenseInvalid('Device security key is missing.');
      return false;
    } on KeyUnusableException {
      state = const LicenseVerifyError('Device security key could not be used.');
      return false;
    } on KeystoreUnavailableException catch (e) {
      state = LicenseVerifyError(e.message);
      return false;
    } catch (e) {
      state = LicenseVerifyError(e.toString());
      return false;
    }
  }

  bool _fingerprintEquals(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

/// DeviceIdentity provider
final deviceIdentityProvider = Provider<DeviceIdentity>((ref) {
  return AndroidDeviceIdentity();
});

/// LicenseStorage provider
final licenseStorageProvider = Provider<LicenseStorage>((ref) {
  return LicenseStorage();
});

/// LicenseVerifier provider
final licenseVerifierProvider = Provider<LicenseVerifier>((ref) {
  return LicenseVerifier(trustedKeys: trustedKeys);
});

/// LicenseService state provider
final licenseServiceProvider = NotifierProvider<LicenseService, LicenseState>(LicenseService.new);
