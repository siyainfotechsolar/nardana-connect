import 'package:flutter_test/flutter_test.dart';
import 'package:nardana_connect/features/updates/models/village_update_model.dart';
import 'package:nardana_connect/features/updates/services/village_updates_service.dart';

void main() {
  group('Village Updates & Invitations Tests', () {
    test('VillageUpdateModel correctly parses JSON with all attributes', () {
      final json = {
        'id': 'e1000000-0000-0000-0000-000000000001',
        'village_id': 'a0000000-0000-0000-0000-000000000001',
        'category': 'kirtan_bhajan',
        'title_mr': 'अखंड हरिनाम सप्ताह',
        'title_en': 'Akhand Harinam Saptah',
        'description_mr': 'ज्ञानेश्वरी पारायण व कीर्तन सोहळा',
        'event_date': '2026-11-20',
        'event_time': 'सायं. ६:०० वाजता',
        'venue_mr': 'श्री विठ्ठल मंदिर, नरडाणा',
        'organizer_name': 'उत्सव समिती',
        'organizer_contact': '9823012345',
        'latitude': 21.2885,
        'longitude': 74.8388,
        'status': 'published',
        'is_approved': true,
      };

      final model = VillageUpdateModel.fromJson(json);

      expect(model.id, 'e1000000-0000-0000-0000-000000000001');
      expect(model.category, 'kirtan_bhajan');
      expect(model.categoryLabel, 'कीर्तन / भजन');
      expect(model.categoryIcon, '🚩');
      expect(model.titleMr, 'अखंड हरिनाम सप्ताह');
      expect(model.venueMr, 'श्री विठ्ठल मंदिर, नरडाणा');
      expect(model.hasValidGps, isTrue);
      expect(model.isApproved, isTrue);
    });

    test('hasValidGps detects valid GPS and rejects invalid/zero coordinates', () {
      const valid = VillageUpdateModel(
        id: '1',
        category: 'announcement',
        titleMr: 'सूचना',
        descriptionMr: 'तपशील',
        latitude: 21.2885,
        longitude: 74.8388,
      );
      expect(valid.hasValidGps, isTrue);

      const zeroCoords = VillageUpdateModel(
        id: '2',
        category: 'announcement',
        titleMr: 'सूचना',
        descriptionMr: 'तपशील',
        latitude: 0.0,
        longitude: 0.0,
      );
      expect(zeroCoords.hasValidGps, isFalse);

      const nullCoords = VillageUpdateModel(
        id: '3',
        category: 'announcement',
        titleMr: 'सूचना',
        descriptionMr: 'तपशील',
      );
      expect(nullCoords.hasValidGps, isFalse);

      const outOfRange = VillageUpdateModel(
        id: '4',
        category: 'announcement',
        titleMr: 'सूचना',
        descriptionMr: 'तपशील',
        latitude: 95.0,
        longitude: 190.0,
      );
      expect(outOfRange.hasValidGps, isFalse);
    });

    test('isUpcoming correctly distinguishes upcoming and past events', () {
      final tomorrow = DateTime.now().add(const Duration(days: 2));
      final tomorrowStr = '${tomorrow.year}-${tomorrow.month.toString().padLeft(2, '0')}-${tomorrow.day.toString().padLeft(2, '0')}';

      final upcoming = VillageUpdateModel(
        id: '1',
        category: 'festival',
        titleMr: 'आगामी उत्सव',
        descriptionMr: 'माहिती',
        eventDate: tomorrowStr,
      );
      expect(upcoming.isUpcoming, isTrue);

      final past = const VillageUpdateModel(
        id: '2',
        category: 'festival',
        titleMr: 'झालेला उत्सव',
        descriptionMr: 'माहिती',
        eventDate: '2020-01-01',
      );
      expect(past.isUpcoming, isFalse);
    });

    test('Fallback events in VillageUpdatesService are authentic to Nardana', () async {
      final updates = await VillageUpdatesService.instance.getPublishedUpdates();

      expect(updates.isNotEmpty, isTrue);
      for (final u in updates) {
        expect(u.isApproved, isTrue);
        expect(u.status, 'published');
        expect(u.titleMr.isNotEmpty, isTrue);
        expect(u.descriptionMr.isNotEmpty, isTrue);
        // Every fallback venue or title mentions Nardana (नरडाणा)
        final mentionsNardana = u.titleMr.contains('नरडाणा') ||
            (u.venueMr != null && u.venueMr!.contains('नरडाणा')) ||
            (u.organizerName != null && u.organizerName!.contains('नरडाणा'));
        expect(mentionsNardana, isTrue);
      }
    });
  });
}

