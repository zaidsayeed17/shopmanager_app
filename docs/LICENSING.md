# ShopManager Offline Device Licensing Architecture

This document outlines the offline, hardware-bound cryptographic licensing architecture implemented in **ShopManager**.

---

## 1. Overview & Security Model

ShopManager enforces an offline licensing policy:
- The app operates only on a device holding an authenticated digital license signed by the developer.
- Each license is bound to the physical device's hardware-backed key pair generated inside the **Android Keystore**.
- Copying a license file or token to another phone will fail activation because the cryptographic device fingerprint will not match.
- The licensing engine is **100% offline**: there are no server calls, telemetry, or network requirements.

---

## 2. Core Cryptographic Components

1. **Digital Signatures**:
   - Algorithm: **Ed25519** (RFC 8032) via vetted [`package:cryptography`](https://pub.dev/packages/cryptography).
   - Private signing keys exist strictly within the developer tool (`C:\ShopManagerLicenseTool\`).
   - The app embeds only public verification keys in `lib/core/licensing/trusted_keys.dart`.

2. **Device Identity & Fingerprinting**:
   - An elliptic curve key pair (`EC secp256r1`) is generated inside **Android Keystore** on first launch with alias `shopmanager_device_key_v1`.
   - StrongBox hardware security module is attempted first with automatic fallback to standard TEE.
   - Non-exportable private key with `setUserAuthenticationRequired(false)`.
   - **Device Fingerprint**: The first 16 bytes of SHA-256 over the public key's DER encoding (`SubjectPublicKeyInfo`).
   - Resettable or privacy-invasive identifiers (`ANDROID_ID`, IMEI, serial, MAC) are never used.

3. **Human-Readable Request Code**:
   - The 16-byte fingerprint is encoded using **Crockford Base32** with a modulo-32 check character for typo detection.
   - Formatted into clean 4-character blocks: `XXXX-XXXX-XXXX-XXXX-XXXX-XXXX-XXX`.
   - Case-insensitive; ignores spaces, dashes, and resolves common visual confusions (`O->0`, `I/L->1`).

4. **License Token Structure**:
   - Format: `base64url(payloadJsonUtf8) + "." + base64url(ed25519Signature)`
   - Context String: `"ShopManagerLicense/v1\n" + rawPayloadBytes`
   - Verification strictly validates the cryptographic signature **BEFORE** parsing JSON. The payload is never re-serialized.
   - Stored in the app-private internal files directory (`shopmanager.license`).
   - Completely isolated from the SQLite database: database backups and factory resets never wipe or touch the license.

---

## 3. Application Lifecycle & Startup Gate

- Gated through `MaterialApp.router`'s `builder` in `lib/main.dart`:
  - When checking: displays a brand splash screen.
  - When unlicensed / invalid / unsupported: displays `ActivationScreen` **instead of mounting the application routes**.
  - No database provider is instantiated, read, migrated, or seeded until the license passes verification.
- Re-verified on cold start and when returning from background (`AppLifecycleState.resumed`).
- Transient Keystore errors on resume do not lock an already-verified active process; definitive failures (wrong device, bad signature) lock immediately.

---

## 4. Operational Limitations & Recovery

- **Reinstall / Clear Storage**:
  Android wipes hardware Keystore keys upon application uninstall or `Clear Storage`. A new Request Code will be generated upon reinstallation. The customer must request a license reissue from the vendor.
- **Offline Revocation**:
  Because the app is completely offline and does not connect to a central server, old phones cannot be remotely revoked. Once a customer moves to a new device, their prior device remains usable with its existing license until overwritten.
- **Lost Developer Keys**:
  If both primary and recovery private keys are lost by the developer, no new licenses can ever be signed for installed apps without shipping an APK update with new embedded public keys.
