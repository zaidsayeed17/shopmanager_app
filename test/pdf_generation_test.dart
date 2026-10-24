import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopmanager/core/constants/app_constants.dart';
import 'package:shopmanager/data/db/app_database.dart';
import 'package:shopmanager/data/models/bill_model.dart';
import 'package:shopmanager/data/repositories/billing_repository.dart';
import 'package:shopmanager/services/pdf_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (MethodCall methodCall) async {
        return Directory.systemTemp.path;
      },
    );
  });

  group('PDF Bill Generation Tests', () {
    final customer = CustomerEntity(
      id: 1,
      name: 'Ramesh Kumar',
      mobile: '9876543210',
      address: 'Plot 42, Industrial Area Phase 1, City',
      openingBalance: 0.0,
      isWholesale: false,
      isActive: true,
      createdAt: DateTime(2026, 1, 1),
    );

    test('Case 1: Fully Paid Bill PDF Generation', () async {
      final bill = BillModel(
        id: 101,
        billNumber: 'INV-00101',
        customerId: 1,
        customerName: 'Ramesh Kumar',
        billDate: DateTime(2026, 9, 28, 14, 30),
        subtotal: 5000.0,
        discount: 0.0,
        otherCharges: 0.0,
        previousOutstandingSnapshot: 0.0,
        grandTotal: 5000.0,
        amountPaid: 5000.0,
        remainingBalance: 0.0,
        status: 'active',
      );

      final items = [
        const BillItemDetail(
          id: 1,
          billId: 101,
          itemId: 10,
          itemName: 'Steel Rod 12mm',
          quantity: 100,
          unit: 'pcs',
          rate: 50.0,
          amount: 5000.0,
        ),
      ];

      final payments = [
        PaymentEntity(
          id: 1,
          billId: 101,
          customerId: 1,
          date: DateTime(2026, 9, 28, 14, 30),
          amount: 5000.0,
          method: 'UPI',
          type: 'bill_payment',
          notes: 'Full payment via GPay',
          createdAt: DateTime(2026, 9, 28, 14, 30),
        ),
      ];

      final pdfDetail = BillDetailData(
        bill: bill,
        customer: customer,
        items: items,
        payments: payments,
      );

      final pdfBytes = await PdfService.generateBillPdf(pdfDetail);
      expect(pdfBytes, isNotEmpty);
      expect(pdfBytes.length, greaterThan(1000));

      final tempFile = await PdfService.savePdfToTempFile(pdfBytes, bill.billNumber);
      expect(tempFile.existsSync(), isTrue);
    });

    test('Case 2: Partial Bill with Discount, Other Charges, Prev Outstanding PDF Generation', () async {
      final bill = BillModel(
        id: 102,
        billNumber: 'INV-00102',
        customerId: 1,
        customerName: 'Ramesh Kumar',
        billDate: DateTime(2026, 9, 29, 10, 15),
        subtotal: 20000.0,
        discount: 2000.0,
        otherCharges: 400.0,
        previousOutstandingSnapshot: 3500.0,
        grandTotal: 18400.0,
        amountPaid: 10000.0,
        remainingBalance: 8400.0,
        status: 'active',
        notes: 'Delivered to site B. Partial cash paid on delivery.',
      );

      final items = [
        const BillItemDetail(
          id: 2,
          billId: 102,
          itemId: 11,
          itemName: 'Cement Sheet 8x4',
          quantity: 20,
          unit: 'sheets',
          rate: 700.0,
          amount: 14000.0,
        ),
        const BillItemDetail(
          id: 3,
          billId: 102,
          itemId: 12,
          itemName: 'PVC Pipe 4 inch',
          quantity: 15,
          unit: 'length',
          rate: 400.0,
          amount: 6000.0,
        ),
      ];

      final payments = [
        PaymentEntity(
          id: 2,
          billId: 102,
          customerId: 1,
          date: DateTime(2026, 9, 29, 10, 15),
          amount: 10000.0,
          method: 'Cash',
          type: 'bill_payment',
          notes: 'Advance cash payment',
          createdAt: DateTime(2026, 9, 29, 10, 15),
        ),
      ];

      final pdfDetail = BillDetailData(
        bill: bill,
        customer: customer,
        items: items,
        payments: payments,
      );

      final pdfBytes = await PdfService.generateBillPdf(pdfDetail);
      expect(pdfBytes, isNotEmpty);
      expect(pdfBytes.length, greaterThan(1000));

      final tempFile = await PdfService.savePdfToTempFile(pdfBytes, bill.billNumber);
      expect(tempFile.existsSync(), isTrue);
    });

    test('Case 3: Voided Bill PDF Generation with Watermark', () async {
      final bill = BillModel(
        id: 103,
        billNumber: 'INV-00103',
        customerId: 1,
        customerName: 'Ramesh Kumar',
        billDate: DateTime(2026, 9, 29, 16, 00),
        subtotal: 12000.0,
        discount: 0.0,
        otherCharges: 0.0,
        previousOutstandingSnapshot: 0.0,
        grandTotal: 12000.0,
        amountPaid: 0.0,
        remainingBalance: 12000.0,
        status: 'void',
        voidReason: 'Billed to wrong party by mistake',
        voidedAt: DateTime(2026, 9, 29, 16, 45),
      );

      final items = [
        const BillItemDetail(
          id: 4,
          billId: 103,
          itemId: 13,
          itemName: 'Iron Angle 50x5',
          quantity: 24,
          unit: 'kg',
          rate: 500.0,
          amount: 12000.0,
        ),
      ];

      final pdfDetail = BillDetailData(
        bill: bill,
        customer: customer,
        items: items,
        payments: const [],
      );

      final pdfBytes = await PdfService.generateBillPdf(pdfDetail);
      expect(pdfBytes, isNotEmpty);
      expect(pdfBytes.length, greaterThan(1000));

      final tempFile = await PdfService.savePdfToTempFile(pdfBytes, bill.billNumber);
      expect(tempFile.existsSync(), isTrue);
    });

    test('AppConstants.shopName matches placeholder requirement', () {
      expect(AppConstants.shopName, equals('My Business'));
    });
  });
}
