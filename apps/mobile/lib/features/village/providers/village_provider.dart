import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nardana_connect/core/services/notification_service.dart';

class VillageItem {
  final String id;
  final String nameMr;
  final String nameEn;
  final String taluka;
  final String pincode;

  const VillageItem({
    required this.id,
    required this.nameMr,
    required this.nameEn,
    required this.taluka,
    this.pincode = '425404',
  });
}

const VillageItem kNardanaVillage = VillageItem(
  id: 'a0000000-0000-0000-0000-000000000001',
  nameMr: 'नरडाणा',
  nameEn: 'Nardana',
  taluka: 'शिंदखेडा (Shindkheda)',
  pincode: '425404',
);

const List<VillageItem> kSupportedVillages = [
  kNardanaVillage,
];

final selectedVillageProvider = StateNotifierProvider<VillageNotifier, VillageItem>((ref) {
  return VillageNotifier();
});

class VillageNotifier extends StateNotifier<VillageItem> {
  VillageNotifier() : super(kNardanaVillage);

  Future<void> selectVillage(VillageItem village) async {
    state = kNardanaVillage;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_village_id', kNardanaVillage.id);
    await NotificationService.instance.subscribeToVillage('Nardana');
  }
}

