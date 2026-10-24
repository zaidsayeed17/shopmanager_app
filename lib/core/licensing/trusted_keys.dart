class TrustedKey {
  final String kid;
  final String name;
  final List<int> publicKeyBytes;

  const TrustedKey({
    required this.kid,
    required this.name,
    required this.publicKeyBytes,
  });
}

/// Production trusted developer public keys.
const List<TrustedKey> trustedKeys = [
  TrustedKey(
    kid: 'c3e521f184618096',
    name: 'primary',
    publicKeyBytes: [
      12, 44, 158, 29, 115, 53, 25, 144, 241, 9, 253, 209, 232, 215, 55, 255,
      170, 241, 186, 221, 242, 140, 140, 54, 72, 61, 207, 237, 55, 162, 224, 248,
    ],
  ),
  TrustedKey(
    kid: 'e80e710ac034c577',
    name: 'recovery',
    publicKeyBytes: [
      245, 205, 227, 49, 92, 222, 233, 181, 239, 246, 21, 198, 37, 239, 225, 167,
      6, 26, 155, 172, 97, 117, 147, 195, 121, 39, 114, 11, 193, 249, 233, 232,
    ],
  ),
];
