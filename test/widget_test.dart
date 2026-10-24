import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopmanager/core/constants/app_constants.dart';
import 'package:shopmanager/data/models/customer_model.dart';
import 'package:shopmanager/data/repositories/business_profile_repository.dart';
import 'package:shopmanager/data/repositories/providers.dart';
import 'package:shopmanager/core/licensing/license_service.dart';
import 'package:shopmanager/core/licensing/license_verifier.dart';
import 'package:shopmanager/main.dart';

class _TestLicenseService extends LicenseService {
  @override
  LicenseState build() {
    return const LicenseLicensed(
      LicenseInfo(
        v: 1,
        kid: 'test-key',
        lid: 'test-lid',
        product: 'shopmanager',
        customer: 'Test Customer',
        shop: 'Test Shop',
        fingerprint: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16],
        iat: 1700000000,
        rawToken: 'test.token',
      ),
    );
  }

  @override
  Future<void> checkLicense() async {}
}

void main() {
  final testCustomers = [
    const Customer(
      id: 1,
      name: 'Rajesh Kumar (Sri Krishna Traders)',
      mobile: '9820144521',
      address: 'Plot 42, GIDC Phase II, Industrial Estate, Vatva, Ahmedabad - 382445',
      gstin: '24AABCS1429B1Z',
      openingBalance: 42850.0,
      outstandingBalance: 42850.0,
      notes: 'Weekly payment terms on Saturday',
      isActive: true,
    ),
    const Customer(
      id: 2,
      name: 'Anil Sharma - Metro Hardware',
      mobile: '9821033219',
      address: 'Gala 5, Industrial Area, Thane West',
      gstin: '27BBBCA1111B1Z2',
      openingBalance: 8750.0,
      outstandingBalance: 8750.0,
      notes: 'Preferred dispatch via local tempo',
      isActive: true,
    ),
  ];

  Widget buildTestApp() {
    return ProviderScope(
      overrides: [
        licenseServiceProvider.overrideWith(_TestLicenseService.new),
        businessProfileProvider.overrideWith((ref) => Stream.value(const BusinessProfile(name: AppConstants.shopName, mobile: '', address: ''))),
        customersStreamProvider.overrideWith((ref) => Stream.value(testCustomers)),
        customerByIdProvider.overrideWith((ref, id) async {
          return testCustomers.firstWhere((c) => c.id == id, orElse: () => testCustomers.first);
        }),
      ],
      child: const ShopManagerApp(),
    );
  }

  testWidgets('App renders navigation shell and dashboard sections by default', (WidgetTester tester) async {
    await tester.pumpWidget(buildTestApp());
    await tester.pumpAndSettle();

    // Verify Dashboard section headers exist
    expect(find.text("TODAY'S SNAPSHOT"), findsOneWidget);
    expect(find.text('STOCK OVERVIEW'), findsOneWidget);
    expect(find.text('WORKER STATUS'), findsOneWidget);
    expect(find.text('RECENT BILLS'), findsOneWidget);
  });

  testWidgets('Navigates to Customers screen and displays customer list', (WidgetTester tester) async {
    await tester.pumpWidget(buildTestApp());
    await tester.pumpAndSettle();

    // Tap on Customers nav item
    final customersTab = find.text('Customers');
    expect(customersTab, findsOneWidget);
    await tester.tap(customersTab);
    await tester.pumpAndSettle();

    // Verify Customer Screen UI elements
    expect(find.text('CUSTOMER LEDGER'), findsOneWidget);
    expect(find.textContaining('All ('), findsOneWidget);
    expect(find.textContaining('With Balance ('), findsOneWidget);
    expect(find.textContaining('Cleared ('), findsOneWidget);
  });

  testWidgets('Navigates to Customer Detail screen and renders header, balance, and tabs', (WidgetTester tester) async {
    await tester.pumpWidget(buildTestApp());
    await tester.pumpAndSettle();

    // Tap on Customers nav item
    await tester.tap(find.text('Customers'));
    await tester.pumpAndSettle();

    // Ensure customer card is visible before tapping
    final customerCard = find.text('Rajesh Kumar (Sri Krishna Traders)');
    expect(customerCard, findsOneWidget);
    await tester.ensureVisible(customerCard);
    await tester.pumpAndSettle();

    await tester.tap(customerCard);
    await tester.pumpAndSettle();

    // Verify Customer Detail Screen elements
    expect(find.text('Call'), findsOneWidget);
    expect(find.text('WhatsApp'), findsOneWidget);
    expect(find.text('ACCOUNT BALANCE'), findsOneWidget);
    expect(find.text('Ledger'), findsOneWidget);
  });
}
