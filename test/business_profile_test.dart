import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopmanager/core/constants/app_constants.dart';
import 'package:shopmanager/data/db/app_database.dart';
import 'package:shopmanager/data/repositories/business_profile_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late BusinessProfileRepository profileRepo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    profileRepo = BusinessProfileRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('Business Profile Repository Tests', () {
    test('getBusinessProfile() returns default shop name and empty contact when table is empty', () async {
      final profile = await profileRepo.getBusinessProfile();
      expect(profile.name, equals(AppConstants.shopName));
      expect(profile.mobile, isEmpty);
      expect(profile.address, isEmpty);
      expect(profile.hasMobile, isFalse);
      expect(profile.hasAddress, isFalse);
      expect(profile.initials, equals('M'));
    });

    test('updateBusinessProfile() persists name, mobile, and address in settingsTable', () async {
      await profileRepo.updateBusinessProfile(
        name: 'Apex Traders',
        mobile: '9876543210',
        address: '123 Market Street, City',
      );

      final profile = await profileRepo.getBusinessProfile();
      expect(profile.name, equals('Apex Traders'));
      expect(profile.mobile, equals('9876543210'));
      expect(profile.address, equals('123 Market Street, City'));
      expect(profile.hasMobile, isTrue);
      expect(profile.hasAddress, isTrue);
      expect(profile.initials, equals('A'));
    });

    test('updateBusinessProfile() throws ArgumentError on empty shop name', () async {
      expect(
        () => profileRepo.updateBusinessProfile(name: '   '),
        throwsA(isA<ArgumentError>().having((e) => e.message, 'message', contains('Shop Name is required'))),
      );
    });

    test('updateBusinessProfile() throws ArgumentError on invalid mobile number', () async {
      expect(
        () => profileRepo.updateBusinessProfile(name: 'Apex Traders', mobile: '12345'),
        throwsA(isA<ArgumentError>().having((e) => e.message, 'message', contains('10-digit mobile number'))),
      );
    });

    test('watchBusinessProfile() emits updated profile in real time', () async {
      final stream = profileRepo.watchBusinessProfile();

      expect(
        stream,
        emitsInOrder([
          isA<BusinessProfile>().having((p) => p.name, 'name', AppConstants.shopName),
          isA<BusinessProfile>()
              .having((p) => p.name, 'name', 'Sunrise Clothing')
              .having((p) => p.mobile, 'mobile', '9123456789'),
        ]),
      );

      // Trigger update after listener attaches
      await Future.delayed(const Duration(milliseconds: 50));
      await profileRepo.updateBusinessProfile(
        name: 'Sunrise Clothing',
        mobile: '9123456789',
      );
    });
  });
}
