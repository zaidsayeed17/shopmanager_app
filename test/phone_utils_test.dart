import 'package:flutter_test/flutter_test.dart';
import 'package:shopmanager/core/utils/phone_utils.dart';

void main() {
  group('toWhatsAppNumber Unit Tests', () {
    test('Bare 10-digit Indian number', () {
      expect(toWhatsAppNumber('9876543210'), equals('919876543210'));
    });

    test('Number with spaces, dashes, parentheses', () {
      expect(toWhatsAppNumber('+91 (987) 654-3210'), equals('919876543210'));
      expect(toWhatsAppNumber('98765 43210'), equals('919876543210'));
    });

    test('Number already prefixed with 91', () {
      expect(toWhatsAppNumber('919876543210'), equals('919876543210'));
      expect(toWhatsAppNumber('+919876543210'), equals('919876543210'));
    });

    test('Number with leading 0 (11 digits)', () {
      expect(toWhatsAppNumber('09876543210'), equals('919876543210'));
    });

    test('Plausible international number', () {
      expect(toWhatsAppNumber('+1 415 555 2671'), equals('14155552671'));
    });

    test('Garbage or invalid inputs return null', () {
      expect(toWhatsAppNumber(null), isNull);
      expect(toWhatsAppNumber(''), isNull);
      expect(toWhatsAppNumber('   '), isNull);
      expect(toWhatsAppNumber('abc'), isNull);
      expect(toWhatsAppNumber('12345'), isNull);
      expect(toWhatsAppNumber('0000000000'), isNull);
    });
  });
}
