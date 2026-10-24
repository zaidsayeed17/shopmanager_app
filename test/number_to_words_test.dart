import 'package:flutter_test/flutter_test.dart';
import 'package:shopmanager/services/pdf_service.dart';

void main() {
  group('PdfService.numberToWordsIndian Unit Tests', () {
    test('Converts zero rupees to words', () {
      expect(PdfService.numberToWordsIndian(0), equals('Zero Rupees Only'));
      expect(PdfService.numberToWordsIndian(0.0), equals('Zero Rupees Only'));
    });

    test('Converts small double-digit amounts to words', () {
      expect(PdfService.numberToWordsIndian(14), equals('Fourteen Rupees Only'));
      expect(PdfService.numberToWordsIndian(99), equals('Ninety Nine Rupees Only'));
    });

    test('Converts thousand-range amounts to words', () {
      expect(
        PdfService.numberToWordsIndian(1740),
        equals('One Thousand Seven Hundred Forty Rupees Only'),
      );
      expect(
        PdfService.numberToWordsIndian(5000),
        equals('Five Thousand Rupees Only'),
      );
    });

    test('Converts lakh and crore range amounts to words', () {
      expect(
        PdfService.numberToWordsIndian(100000),
        equals('One Lakh Rupees Only'),
      );
      expect(
        PdfService.numberToWordsIndian(12345678),
        equals('One Crore Twenty Three Lakh Forty Five Thousand Six Hundred Seventy Eight Rupees Only'),
      );
    });

    test('Handles paise and decimals correctly', () {
      expect(
        PdfService.numberToWordsIndian(1740.50),
        equals('One Thousand Seven Hundred Forty Rupees and Fifty Paise Only'),
      );
      expect(
        PdfService.numberToWordsIndian(15.75),
        equals('Fifteen Rupees and Seventy Five Paise Only'),
      );
      expect(
        PdfService.numberToWordsIndian(0.25),
        equals('Zero Rupees and Twenty Five Paise Only'),
      );
    });
  });
}
