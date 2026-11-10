import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:nardana_connect/core/constants/app_colors.dart';
import 'package:nardana_connect/core/localization/locale_provider.dart';
import 'package:nardana_connect/features/advertisements/providers/advertisement_provider.dart';
import 'package:nardana_connect/features/advertisements/services/advertisement_service.dart';

class HomeAdCarousel extends ConsumerStatefulWidget {
  const HomeAdCarousel({super.key});

  @override
  ConsumerState<HomeAdCarousel> createState() => _HomeAdCarouselState();
}

class _HomeAdCarouselState extends ConsumerState<HomeAdCarousel> {
  late final PageController _pageController;
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.92);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startTimer(int totalPages) {
    if (totalPages <= 1) return;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!mounted) return;
      if (_pageController.hasClients) {
        final nextPage = (_currentPage + 1) % totalPages;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final adsAsync = ref.watch(homeCarouselAdsProvider);
    final locale = ref.watch(localeProvider);

    return adsAsync.when(
      data: (ads) {
        if (ads.isEmpty) return const SizedBox.shrink();

        // Start timer once data is loaded
        _startTimer(ads.length);

        // Track impression of first page if loaded
        if (ads.isNotEmpty && _currentPage == 0) {
          AdvertisementService.instance.trackImpression(ads[0].id);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 175,
              child: PageView.builder(
                controller: _pageController,
                itemCount: ads.length,
                onPageChanged: (idx) {
                  setState(() {
                    _currentPage = idx;
                  });
                  // Track impression for current active ad in carousel
                  AdvertisementService.instance.trackImpression(ads[idx].id);
                },
                itemBuilder: (context, index) {
                  final ad = ads[index];
                  final title = ad.localizedTitle(locale.languageCode);

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: InkWell(
                      onTap: () {
                        AdvertisementService.instance.trackClick(ad.id);
                        context.push('/advertisement-detail', extra: ad);
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              // Background Banner Image
                              CachedNetworkImage(
                                imageUrl: ad.imageUrl,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  color: Colors.grey.shade200,
                                  child: const Center(
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  color: AppColors.primaryBlue.withValues(alpha: 0.1),
                                  child: const Center(
                                    child: Icon(Icons.broken_image_rounded, color: Colors.grey),
                                  ),
                                ),
                              ),

                              // Bottom Dark Gradient Overlay for text legibility
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                height: 90,
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.transparent,
                                        Colors.black.withValues(alpha: 0.85),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              // Top Sponsored Pill
                              Positioned(
                                top: 10,
                                left: 10,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.7),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: AppColors.accentYellow.withValues(alpha: 0.7)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.campaign_rounded, size: 12, color: AppColors.accentYellow),
                                      const SizedBox(width: 4),
                                      Text(
                                        'प्रायोजित • नरडाणा',
                                        style: GoogleFonts.mukta(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              // Bottom Title & CTA Info
                              Positioned(
                                bottom: 10,
                                left: 12,
                                right: 12,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            title,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.mukta(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                              shadows: const [
                                                Shadow(
                                                  color: Colors.black,
                                                  blurRadius: 4,
                                                ),
                                              ],
                                            ),
                                          ),
                                          if (ad.advertiserName != null) ...[
                                            Text(
                                              ad.advertiserName!,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: GoogleFonts.mukta(
                                                fontSize: 11,
                                                color: AppColors.accentYellow,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppColors.secondaryGreen,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        'पहा →',
                                        style: GoogleFonts.mukta(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Indicator Dots
            if (ads.length > 1) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(ads.length, (idx) {
                  final isCurrent = idx == _currentPage;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 2.5),
                    width: isCurrent ? 18 : 6,
                    height: 5,
                    decoration: BoxDecoration(
                      color: isCurrent ? AppColors.primaryBlue : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  );
                }),
              ),
            ],
          ],
        );
      },
      loading: () => Container(
        height: 175,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      error: (e, s) => const SizedBox.shrink(),
    );
  }
}
