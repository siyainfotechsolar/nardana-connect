import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nardana_connect/features/advertisements/models/advertisement_model.dart';
import 'package:nardana_connect/features/advertisements/services/advertisement_service.dart';

final homeCarouselAdsProvider = FutureProvider<List<AdvertisementModel>>((ref) async {
  return AdvertisementService.instance.getActiveAdvertisements(placement: 'home_carousel');
});

final sponsoredAdsProvider = FutureProvider<List<AdvertisementModel>>((ref) async {
  return AdvertisementService.instance.getActiveAdvertisements(placement: 'sponsored_card');
});

final categoryAdsProvider = FutureProvider.family<List<AdvertisementModel>, String?>((ref, categoryId) async {
  return AdvertisementService.instance.getActiveAdvertisements(
    placement: 'category_banner',
    categoryId: categoryId,
  );
});

