import 'package:flutter_test/flutter_test.dart';
import 'package:nardana_connect/features/vehicles/models/vehicle_listing_model.dart';
import 'package:nardana_connect/features/legal/models/disclaimer_model.dart';

void main() {
  group('Vehicle Rental Directory Tests', () {
    test('VehicleListingModel initializes and masks registration number for privacy', () {
      const listing = VehicleListingModel(
        id: 'test-1',
        driverName: 'कैलास निवृत्ती पाटील',
        vehicleType: 'अर्टिगा (७ सीटर)',
        vehicleModel: 'Maruti Ertiga VXi',
        vehicleNumber: 'MH 18 BX 4412',
        contactNumber: '9421889901',
        locationText: 'स्टेशन परिसर, नरडाणा',
      );

      expect(listing.driverName, 'कैलास निवृत्ती पाटील');
      expect(listing.isAvailable, true);
      expect(listing.isApproved, true);
      expect(listing.maskedVehicleNumber, 'MH 1 ••••');
    });

    test('Fallback vehicle listings are strictly from Nardana', () {
      final list = VehicleListingModel.fallbackListings;
      expect(list.length, greaterThanOrEqualTo(5));
      for (final item in list) {
        expect(item.locationText, contains('नरडाणा'));
        expect(item.contactNumber.length, 10);
      }
    });
  });

  group('Disclaimer Management Tests', () {
    test('DisclaimerSectionModel correctly parses bilingual legal data', () {
      final section = DisclaimerSectionModel.fromMap({
        'id': 'sec-1',
        'section_key': 'vehicle_and_driver',
        'title_mr': '५. वाहन व ड्रायव्हर माहिती',
        'title_en': '5. Vehicle Rental & Driver Directory',
        'content_mr': 'वाहन भाडे आणि ड्रायव्हर संपर्क माहिती...',
        'content_en': 'Vehicle rental details and driver contact information...',
        'is_active': true,
        'is_material': true,
        'requires_reacceptance': true,
      });

      expect(section.sectionKey, 'vehicle_and_driver');
      expect(section.titleMr, '५. वाहन व ड्रायव्हर माहिती');
      expect(section.isMaterial, true);
      expect(section.requiresReacceptance, true);
    });

    test('DisclaimerDocumentModel default values provide legal fallback', () {
      final doc = DisclaimerDocumentModel.fromMap({});
      expect(doc.currentVersion, '1.0.0');
      expect(doc.titleMr, contains('अस्वीकरण'));
    });
  });
}
