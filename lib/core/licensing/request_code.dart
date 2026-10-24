import 'dart:typed_data';

/// Human-friendly encoding of 16-byte device fingerprint using Crockford Base32
/// with a check character for typo detection.
class RequestCode {
  static const String alphabet = '0123456789ABCDEFGHJKMNPQRSTVWXYZ';

  /// Encodes a 16-byte fingerprint into a formatted request code.
  static String encode(List<int> fingerprint16) {
    if (fingerprint16.length != 16) {
      throw ArgumentError('Fingerprint must be exactly 16 bytes');
    }

    // Convert 16 bytes to BigInt (big-endian)
    BigInt val = BigInt.zero;
    for (final b in fingerprint16) {
      val = (val << 8) | BigInt.from(b & 0xFF);
    }

    // Convert to 26 Base32 characters (padded with leading zeros if needed)
    final chars = List<String>.filled(26, '0');
    final radix = BigInt.from(32);
    for (int i = 25; i >= 0; i--) {
      final rem = (val % radix).toInt();
      chars[i] = alphabet[rem];
      val = val ~/ radix;
    }

    final raw26 = chars.join('');
    final checkChar = _computeCheckChar(raw26);
    final full27 = '$raw26$checkChar';

    // Format into groups of 4: XXXX-XXXX-XXXX-XXXX-XXXX-XXXX-XXX
    final buffer = StringBuffer();
    for (int i = 0; i < full27.length; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write('-');
      }
      buffer.write(full27[i]);
    }
    return buffer.toString();
  }

  /// Decodes and verifies a formatted or unformatted request code back to 16-byte fingerprint.
  /// Tolerates spaces, dashes, lowercase, and common visual substitutions (O->0, I/L->1).
  static List<int> decode(String input) {
    // 1. Clean input: remove spaces and dashes, convert to upper case
    var cleaned = input.replaceAll(RegExp(r'[\s\-"\x27]'), '').toUpperCase();

    // 2. Map visual similarities per Crockford Base32 spec
    cleaned = cleaned.replaceAll('O', '0').replaceAll('I', '1').replaceAll('L', '1');

    if (cleaned.length != 27) {
      throw FormatException('Request code must be 27 characters (got ${cleaned.length})');
    }

    final payload26 = cleaned.substring(0, 26);
    final checkChar = cleaned[26];

    // Validate characters
    for (int i = 0; i < 26; i++) {
      if (!alphabet.contains(payload26[i])) {
        throw FormatException('Invalid character "${payload26[i]}" in request code');
      }
    }

    // 3. Verify check character
    final expectedCheckChar = _computeCheckChar(payload26);
    if (checkChar != expectedCheckChar) {
      throw const FormatException('Request code checksum failed (possible typo)');
    }

    // 4. Decode 26 characters to BigInt
    BigInt val = BigInt.zero;
    final radix = BigInt.from(32);
    for (int i = 0; i < 26; i++) {
      final idx = alphabet.indexOf(payload26[i]);
      val = (val * radix) + BigInt.from(idx);
    }

    // 5. Convert BigInt back to 16 bytes
    final bytes = Uint8List(16);
    final mask8 = BigInt.from(0xFF);
    for (int i = 15; i >= 0; i--) {
      bytes[i] = (val & mask8).toInt();
      val = val >> 8;
    }

    return bytes;
  }

  static String _computeCheckChar(String payload26) {
    int sum = 0;
    for (int i = 0; i < payload26.length; i++) {
      final charIndex = alphabet.indexOf(payload26[i]);
      sum += (charIndex * (i + 1));
    }
    return alphabet[sum % 32];
  }
}
