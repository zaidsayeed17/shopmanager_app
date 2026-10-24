import 'package:flutter_test/flutter_test.dart';
import 'package:shopmanager/core/utils/pricing_utils.dart';

void main() {
  group('resolveUnitPrice Tests', () {
    test('Retail customer returns retail price even if wholesale price exists', () {
      final price = resolveUnitPrice(
        retail: 250.0,
        wholesale: 200.0,
        isWholesaleCustomer: false,
      );
      expect(price, equals(250.0));
    });

    test('Wholesale customer with positive wholesale price returns wholesale price', () {
      final price = resolveUnitPrice(
        retail: 250.0,
        wholesale: 200.0,
        isWholesaleCustomer: true,
      );
      expect(price, equals(200.0));
    });

    test('Wholesale customer with null wholesale price falls back to retail price', () {
      final price = resolveUnitPrice(
        retail: 250.0,
        wholesale: null,
        isWholesaleCustomer: true,
      );
      expect(price, equals(250.0));
    });

    test('Wholesale customer with 0 wholesale price falls back to retail price', () {
      final price = resolveUnitPrice(
        retail: 250.0,
        wholesale: 0.0,
        isWholesaleCustomer: true,
      );
      expect(price, equals(250.0));
    });

    test('Walk-in / non-wholesale customer returns retail price when wholesale is null', () {
      final price = resolveUnitPrice(
        retail: 180.0,
        wholesale: null,
        isWholesaleCustomer: false,
      );
      expect(price, equals(180.0));
    });
  });
}
