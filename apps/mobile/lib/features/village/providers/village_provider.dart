import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nardana_connect/core/services/notification_service.dart';

class VillageItem {
  final String id;
  final String nameMr;
  final String nameEn;
  final String taluka;

  const VillageItem({
    required this.id,
    required this.nameMr,
    required this.nameEn,
    required this.taluka,
  });
}

const List<VillageItem> kSupportedVillages = [
  VillageItem(id: 'all', nameMr: 'सर्व गावे', nameEn: 'All Villages', taluka: 'Shindkheda'),
  VillageItem(id: 'a0000000-0000-0000-0000-000000000001', nameMr: 'नरडाणा', nameEn: 'Nardana', taluka: 'Shindkheda'),
  VillageItem(id: 'a0000000-0000-0000-0000-000000000002', nameMr: 'वाघाळी', nameEn: 'Waghadi', taluka: 'Shindkheda'),
  VillageItem(id: 'a0000000-0000-0000-0000-000000000003', nameMr: 'होळ', nameEn: 'Hol', taluka: 'Shindkheda'),
  VillageItem(id: 'a0000000-0000-0000-0000-000000000004', nameMr: 'बेटावद', nameEn: 'Betawad', taluka: 'Shindkheda'),
  VillageItem(id: 'a0000000-0000-0000-0000-000000000005', nameMr: 'चिमठाणे', nameEn: 'Chimthane', taluka: 'Shindkheda'),
  VillageItem(id: 'a0000000-0000-0000-0000-000000000006', nameMr: 'वरडी', nameEn: 'Vardi', taluka: 'Shindkheda'),
  VillageItem(id: 'a0000000-0000-0000-0000-000000000007', nameMr: 'शिंदखेडा', nameEn: 'Shindkheda', taluka: 'Shindkheda'),
];

final selectedVillageProvider = StateNotifierProvider<VillageNotifier, VillageItem>((ref) {
  return VillageNotifier();
});

class VillageNotifier extends StateNotifier<VillageItem> {
  VillageNotifier() : super(kSupportedVillages[1]) { // Default to Nardana
    _loadSavedVillage();
  }

  Future<void> _loadSavedVillage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedId = prefs.getString('selected_village_id');
    if (savedId != null) {
      final found = kSupportedVillages.firstWhere(
        (v) => v.id == savedId,
        orElse: () => kSupportedVillages[1],
      );
      state = found;
    }
  }

  Future<void> selectVillage(VillageItem village) async {
    final oldVillage = state;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_village_id', village.id);
    state = village;

    // Update FCM topic subscriptions
    if (oldVillage.id != 'all' && oldVillage.id != village.id) {
      await NotificationService.instance.unsubscribeFromVillage(oldVillage.nameEn);
    }
    if (village.id != 'all') {
      await NotificationService.instance.subscribeToVillage(village.nameEn);
    }
  }
}

