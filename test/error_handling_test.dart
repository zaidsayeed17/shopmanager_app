import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';

import 'package:shopmanager/data/db/app_database.dart';
import 'package:shopmanager/data/repositories/customer_repository.dart';
import 'package:shopmanager/core/widgets/error_boundary.dart';

void main() {
  late AppDatabase db;
  late CustomerRepository customerRepo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    customerRepo = CustomerRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('Phase 14 — Customer Repository Duplicate Checks', () {
    test('customerNameExists checks case-insensitive duplicate names', () async {
      await customerRepo.addCustomer(
        name: 'Rajesh Kumar',
        mobile: '9820144521',
      );

      final existsUpper = await customerRepo.customerNameExists('RAJESH KUMAR');
      final existsLower = await customerRepo.customerNameExists('rajesh kumar');
      final existsOther = await customerRepo.customerNameExists('Suresh Kumar');

      expect(existsUpper, isTrue);
      expect(existsLower, isTrue);
      expect(existsOther, isFalse);
    });

    test('customerNameExists excludes specific customer ID during edit', () async {
      final id = await customerRepo.addCustomer(
        name: 'Rajesh Kumar',
        mobile: '9820144521',
      );

      final existsSameId = await customerRepo.customerNameExists('Rajesh Kumar', excludeId: id);
      final existsOtherId = await customerRepo.customerNameExists('Rajesh Kumar', excludeId: 999);

      expect(existsSameId, isFalse);
      expect(existsOtherId, isTrue);
    });

    test('findCustomerByMobile finds customer by exact mobile number', () async {
      final id = await customerRepo.addCustomer(
        name: 'Anil Sharma',
        mobile: '9821033219',
      );

      final found = await customerRepo.findCustomerByMobile('9821033219');
      final notFound = await customerRepo.findCustomerByMobile('9999999999');

      expect(found, isNotNull);
      expect(found?.id, equals(id));
      expect(found?.name, equals('Anil Sharma'));
      expect(notFound, isNull);
    });

    test('findCustomerByMobile excludes current customer ID during edit', () async {
      final id = await customerRepo.addCustomer(
        name: 'Anil Sharma',
        mobile: '9821033219',
      );

      final foundSelf = await customerRepo.findCustomerByMobile('9821033219', excludeId: id);
      expect(foundSelf, isNull);
    });
  });

  group('Phase 14 — Global Error Boundary Widget', () {
    testWidgets('GlobalErrorBoundaryWidget renders title, body message, and restart button', (tester) async {
      await tester.pumpWidget(
        const GlobalErrorBoundaryWidget(),
      );

      expect(find.text('Something went wrong'), findsOneWidget);
      expect(
        find.textContaining('Please restart the app. If this keeps happening, check Settings > Backup & Restore'),
        findsOneWidget,
      );
      expect(find.text('Restart App'), findsOneWidget);
    });
  });
}
