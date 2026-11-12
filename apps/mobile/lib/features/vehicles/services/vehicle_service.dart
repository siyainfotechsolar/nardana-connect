import 'package:flutter/foundation.dart';
import 'package:nardana_connect/core/services/supabase_service.dart';
import 'package:nardana_connect/features/vehicles/models/vehicle_listing_model.dart';

class VehicleCategory {
  final String id;
  final String slug;
  final String nameMr;
  final String nameEn;
  final String iconName;
  final int displayOrder;

  const VehicleCategory({
    required this.id,
    required this.slug,
    required this.nameMr,
    required this.nameEn,
    required this.iconName,
    required this.displayOrder,
  });

  factory VehicleCategory.fromMap(Map<String, dynamic> map) {
    return VehicleCategory(
      id: map['id']?.toString() ?? '',
      slug: map['slug']?.toString() ?? '',
      nameMr: map['name_mr']?.toString() ?? '',
      nameEn: map['name_en']?.toString() ?? '',
      iconName: map['icon_name']?.toString() ?? 'directions_car',
      displayOrder: (map['display_order'] as num?)?.toInt() ?? 0,
    );
  }
}

class VehicleService {
  static final VehicleService instance = VehicleService._();
  VehicleService._();

  static const List<Map<String, String>> defaultCategories = [
    {'slug': 'all', 'name_mr': 'सर्व गाड्या', 'name_en': 'All'},
    {'slug': 'car', 'name_mr': 'कार', 'name_en': 'Car'},
    {'slug': 'taxi', 'name_mr': 'टॅक्सी', 'name_en': 'Taxi'},
    {'slug': 'ertiga', 'name_mr': 'अर्टिगा (७ सीटर)', 'name_en': 'Ertiga'},
    {'slug': 'innova', 'name_mr': 'इनोव्हा', 'name_en': 'Innova'},
    {'slug': 'pickup', 'name_mr': 'पिकअप / छोटा हत्ती', 'name_en': 'Pickup'},
    {'slug': 'tempo', 'name_mr': 'टेम्पो', 'name_en': 'Tempo'},
    {'slug': 'tractor', 'name_mr': 'ट्रॅक्टर', 'name_en': 'Tractor'},
    {'slug': 'jcb', 'name_mr': 'जेसीबी (JCB)', 'name_en': 'JCB'},
    {'slug': 'truck', 'name_mr': 'ट्रक', 'name_en': 'Truck'},
    {'slug': 'bus', 'name_mr': 'बस / ट्रॅव्हलर', 'name_en': 'Bus'},
    {'slug': 'other', 'name_mr': 'इतर वाहने', 'name_en': 'Other'},
  ];

  /// Fetch categories from Supabase
  Future<List<VehicleCategory>> fetchCategories() async {
    try {
      final res = await SupabaseService.client
          .from('vehicle_categories')
          .select('*')
          .order('display_order', ascending: true);

      if (res.isNotEmpty) {
        return (res as List)
            .map((e) => VehicleCategory.fromMap(e as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      debugPrint('[VehicleService] fetchCategories error: $e');
    }

    return defaultCategories.asMap().entries.map((entry) {
      final idx = entry.key;
      final c = entry.value;
      return VehicleCategory(
        id: c['slug']!,
        slug: c['slug']!,
        nameMr: c['name_mr']!,
        nameEn: c['name_en']!,
        iconName: 'directions_car',
        displayOrder: idx,
      );
    }).toList();
  }

  /// Fetch approved and active vehicle listings for Nardana
  Future<List<VehicleListingModel>> fetchListings({
    String? categorySlug,
    String? availabilityStatus,
    String? searchQuery,
  }) async {
    try {
      var query = SupabaseService.client
          .from('vehicle_listings')
          .select('*')
          .eq('approval_status', 'approved')
          .eq('is_active', true);

      if (availabilityStatus != null && availabilityStatus.isNotEmpty && availabilityStatus != 'all') {
        query = query.eq('availability_status', availabilityStatus);
      }

      final res = await query.order('created_at', ascending: false);

      if (res.isNotEmpty) {
        List<VehicleListingModel> items = (res as List)
            .map((e) => VehicleListingModel.fromMap(e as Map<String, dynamic>))
            .toList();

        if (categorySlug != null && categorySlug.isNotEmpty && categorySlug != 'all') {
          items = items.where((item) {
            final t = item.vehicleType.toLowerCase();
            final c = categorySlug.toLowerCase();
            return t.contains(c) || _matchesCategorySlug(item.vehicleType, categorySlug);
          }).toList();
        }

        if (searchQuery != null && searchQuery.trim().isNotEmpty) {
          final q = searchQuery.toLowerCase().trim();
          items = items.where((item) {
            return item.driverName.toLowerCase().contains(q) ||
                item.vehicleType.toLowerCase().contains(q) ||
                item.vehicleModel.toLowerCase().contains(q) ||
                (item.locationText ?? '').toLowerCase().contains(q);
          }).toList();
        }

        return items;
      }
    } catch (e) {
      debugPrint('[VehicleService] fetchListings error: $e');
    }

    // Fallback listings with filtering
    var list = VehicleListingModel.fallbackListings;
    if (availabilityStatus != null && availabilityStatus.isNotEmpty && availabilityStatus != 'all') {
      list = list.where((i) => i.availabilityStatus == availabilityStatus).toList();
    }
    if (categorySlug != null && categorySlug.isNotEmpty && categorySlug != 'all') {
      list = list.where((item) => _matchesCategorySlug(item.vehicleType, categorySlug)).toList();
    }
    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final q = searchQuery.toLowerCase().trim();
      list = list.where((item) {
        return item.driverName.toLowerCase().contains(q) ||
            item.vehicleType.toLowerCase().contains(q) ||
            item.vehicleModel.toLowerCase().contains(q) ||
            (item.locationText ?? '').toLowerCase().contains(q);
      }).toList();
    }
    return list;
  }

  bool _matchesCategorySlug(String vehicleType, String slug) {
    final t = vehicleType.toLowerCase();
    switch (slug) {
      case 'car':
        return t.contains('कार') || t.contains('car');
      case 'taxi':
        return t.contains('टॅक्सी') || t.contains('taxi');
      case 'ertiga':
        return t.contains('अर्टिगा') || t.contains('ertiga');
      case 'innova':
        return t.contains('इनोव्हा') || t.contains('innova');
      case 'pickup':
        return t.contains('पिकअप') || t.contains('हत्ती') || t.contains('pickup');
      case 'tempo':
        return t.contains('टेम्पो') || t.contains('tempo');
      case 'tractor':
        return t.contains('ट्रॅक्टर') || t.contains('tractor');
      case 'jcb':
        return t.contains('जेसीबी') || t.contains('jcb');
      case 'truck':
        return t.contains('ट्रक') || t.contains('truck');
      case 'bus':
        return t.contains('बस') || t.contains('ट्रॅव्हलर') || t.contains('bus');
      default:
        return true;
    }
  }

  /// Submit new vehicle listing (requires Admin approval)
  Future<bool> submitListing(VehicleListingModel listing) async {
    try {
      final map = listing.toMap();
      map.remove('id');
      map['approval_status'] = 'pending'; // Requires admin verification
      map['is_active'] = true;

      await SupabaseService.client.from('vehicle_listings').insert(map);
      return true;
    } catch (e) {
      debugPrint('[VehicleService] submitListing error: $e');
      return false;
    }
  }

  /// Update availability status (e.g., driver marks 'available' or 'busy')
  Future<bool> updateAvailability(String listingId, String status) async {
    try {
      await SupabaseService.client
          .from('vehicle_listings')
          .update({'availability_status': status, 'updated_at': DateTime.now().toIso8601String()})
          .eq('id', listingId);
      return true;
    } catch (e) {
      debugPrint('[VehicleService] updateAvailability error: $e');
      return false;
    }
  }

  /// Report a listing
  Future<bool> reportListing({
    required String listingId,
    required String reason,
    String? details,
  }) async {
    try {
      await SupabaseService.client.from('vehicle_reports').insert({
        'listing_id': listingId,
        'reason': reason,
        'details': details,
        'status': 'pending',
      });
      return true;
    } catch (e) {
      debugPrint('[VehicleService] reportListing error: $e');
      return false;
    }
  }
}
