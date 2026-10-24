import 'package:drift/drift.dart';
import 'bills.dart';
import 'customers.dart';

@DataClassName('PaymentEntity')
class Payments extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get customerId => integer().references(Customers, #id)();
  IntColumn get billId => integer().nullable().references(Bills, #id)();
  RealColumn get amount => real()();
  TextColumn get method => text()(); // 'cash'/'upi'/'other'
  TextColumn get type => text().withDefault(const Constant('bill_payment'))(); // 'bill_payment'/'advance'/'advance_applied'
  DateTimeColumn get date => dateTime()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
