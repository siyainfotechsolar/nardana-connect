import 'dart:developer' as developer;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nardana_connect/features/advertisements/models/advertisement_model.dart';

class AdvertisementService {
  static final AdvertisementService instance = AdvertisementService._internal();
  AdvertisementService._internal();

  final Set<String> _trackedImpressions = {};
  final Set<String> _trackedClicks = {};

  // Sample Nardana-specific advertisements for offline fallback
  static final List<AdvertisementModel> _fallbackAds = [
    AdvertisementModel(
      id: 'a2fa1a90-8f65-409d-b50c-6508856db8bc',
      villageId: 'a0000000-0000-0000-0000-000000000001',
      titleMr: 'श्री गजानन कृषी सेवा केंद्र, नरडाणा - दर्जेदार बियाणे व खते',
      titleEn: 'Shri Gajanan Krishi Seva Kendra, Nardana - Quality Seeds & Fertilizers',
      descriptionMr: 'रब्बी व खरीप हंगामासाठी सर्व नामांकित कंपन्यांचे बियाणे, सेंद्रिय खते व कीटकनाशके वाजवी दरात उपलब्ध. नरडाणा हायवे चौक.',
      descriptionEn: 'Top quality certified seeds, fertilizers and crop protection chemicals at best rates. Highway Chowk, Nardana.',
      imageUrl: 'https://images.unsplash.com/photo-1592982537447-7440770cbfc9?w=800&auto=format&fit=crop&q=80',
      placement: 'home_carousel',
      targetType: 'phone',
      phone: '9823012345',
      whatsapp: '9823012345',
      startDate: DateTime.now().subtract(const Duration(days: 1)),
      endDate: DateTime.now().add(const Duration(days: 60)),
      isActive: true,
      priority: 10,
      advertiserName: 'अशोक पाटील (Ashok Patil)',
      advertiserContact: '9823012345',
      createdAt: DateTime.now(),
    ),
    AdvertisementModel(
      id: '9a9fcba8-78b0-4320-8040-5d36903054bb',
      villageId: 'a0000000-0000-0000-0000-000000000001',
      titleMr: 'सुयोग इलेक्ट्रॉनिक्स व होम अप्लायन्सेस, नरडाणा - भव्य सवलत!',
      titleEn: 'Suyog Electronics & Home Appliances, Nardana - Grand Offer!',
      descriptionMr: 'स्मार्ट टीव्ही, फ्रिज, कुलर व घरगुती उपकरणांवर खास सवलत व सुलभ ईएमआय (EMI) सुविधा. स्टेशन रोड, नरडाणा.',
      descriptionEn: 'Special festive discounts on Smart TVs, Refrigerators, Coolers with zero downpayment EMI. Station Road, Nardana.',
      imageUrl: 'https://images.unsplash.com/photo-1550009158-9ebf69173e03?w=800&auto=format&fit=crop&q=80',
      placement: 'home_carousel',
      targetType: 'whatsapp',
      phone: '9422054321',
      whatsapp: '9422054321',
      startDate: DateTime.now().subtract(const Duration(days: 1)),
      endDate: DateTime.now().add(const Duration(days: 45)),
      isActive: true,
      priority: 9,
      advertiserName: 'सुयोग महाजन (Suyog Mahajan)',
      advertiserContact: '9422054321',
      createdAt: DateTime.now(),
    ),
    AdvertisementModel(
      id: '6e100757-3e62-4ef4-9811-02eaf7c8883b',
      villageId: 'a0000000-0000-0000-0000-000000000001',
      titleMr: 'नरडाणा ऑटोमोबाईल व गॅरेज - २४ तास हायवे ब्रेकडाऊन सर्व्हिस',
      titleEn: 'Nardana Automobile & Garage - 24/7 Highway Breakdown Service',
      descriptionMr: 'सर्व प्रकारच्या चारचाकी व ट्रॅक्टरचे मेकॅनिकल काम, ऑईल चेंज व तातडीची हायवे मदत. संपर्क करा: नरडाणा बायपास.',
      descriptionEn: 'Full car and tractor repair, computer wheel balancing, emergency roadside assistance on NH-52 Nardana bypass.',
      imageUrl: 'https://images.unsplash.com/photo-1486006920555-c77dce18193b?w=800&auto=format&fit=crop&q=80',
      placement: 'sponsored_card',
      targetType: 'phone',
      phone: '9890123456',
      whatsapp: '9890123456',
      startDate: DateTime.now().subtract(const Duration(days: 2)),
      endDate: DateTime.now().add(const Duration(days: 90)),
      isActive: true,
      priority: 8,
      advertiserName: 'संजय मिस्त्री (Sanjay Mistry)',
      advertiserContact: '9890123456',
      createdAt: DateTime.now(),
    ),
  ];

  /// Fetch active, non-expired advertisements for Nardana
  Future<List<AdvertisementModel>> getActiveAdvertisements({
    String? placement,
    String? categoryId,
  }) async {
    try {
      final nowIso = DateTime.now().toIso8601String();
      var filter = Supabase.instance.client
          .from('advertisements')
          .select('*')
          .eq('is_active', true)
          .lte('start_date', nowIso)
          .gte('end_date', nowIso);

      if (placement != null && placement.isNotEmpty) {
        filter = filter.eq('placement', placement);
      }
      if (categoryId != null && categoryId.isNotEmpty) {
        filter = filter.eq('category_id', categoryId);
      }

      final response = await filter
          .order('priority', ascending: false)
          .order('created_at', ascending: false);
      final List<dynamic> data = response as List<dynamic>;

      if (data.isEmpty) {
        // Filter fallback ads matching placement
        return _filterFallback(placement, categoryId);
      }

      return data.map((item) => AdvertisementModel.fromJson(item as Map<String, dynamic>)).toList();
    } catch (e) {
      developer.log('Error fetching advertisements from Supabase: $e');
      return _filterFallback(placement, categoryId);
    }
  }

  List<AdvertisementModel> _filterFallback(String? placement, String? categoryId) {
    return _fallbackAds.where((ad) {
      if (placement != null && ad.placement != placement) return false;
      if (categoryId != null && ad.categoryId != categoryId) return false;
      return ad.isCurrentlyActive;
    }).toList();
  }

  /// Track advertisement impression safely (de-duplicated per session)
  Future<void> trackImpression(String adId) async {
    if (_trackedImpressions.contains(adId)) return;
    _trackedImpressions.add(adId);

    try {
      await Supabase.instance.client.rpc('track_ad_impression', params: {
        'ad_id': adId,
        'p_device': 'Android Mobile App',
      });
      developer.log('Recorded ad impression: $adId');
    } catch (e) {
      developer.log('Failed to track ad impression: $e');
    }
  }

  /// Track advertisement click safely
  Future<void> trackClick(String adId) async {
    _trackedClicks.add(adId);
    try {
      await Supabase.instance.client.rpc('track_ad_click', params: {
        'ad_id': adId,
        'p_device': 'Android Mobile App',
      });
      developer.log('Recorded ad click: $adId');
    } catch (e) {
      developer.log('Failed to track ad click: $e');
    }
  }
}
