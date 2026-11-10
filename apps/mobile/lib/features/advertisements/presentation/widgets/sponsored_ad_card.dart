import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:nardana_connect/core/constants/app_colors.dart';
import 'package:nardana_connect/core/localization/locale_provider.dart';
import 'package:nardana_connect/features/advertisements/models/advertisement_model.dart';
import 'package:nardana_connect/features/advertisements/services/advertisement_service.dart';
import 'package:url_launcher/url_launcher.dart';

class SponsoredAdCard extends ConsumerStatefulWidget {
  final AdvertisementModel ad;

  const SponsoredAdCard({super.key, required this.ad});

  @override
  ConsumerState<SponsoredAdCard> createState() => _SponsoredAdCardState();
}

class _SponsoredAdCardState extends ConsumerState<SponsoredAdCard> {
  @override
  void initState() {
    super.initState();
    AdvertisementService.instance.trackImpression(widget.ad.id);
  }

  Future<void> _makeCall(String phone) async {
    AdvertisementService.instance.trackClick(widget.ad.id);
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _openWhatsApp(String phone, String title) async {
    AdvertisementService.instance.trackClick(widget.ad.id);
    final cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
    final fullPhone = cleanPhone.length == 10 ? '91$cleanPhone' : cleanPhone;
    final message = Uri.encodeComponent('नमस्कार, नरडाणा कनेक्ट ॲपवरील आपली जाहिरात ($title) पाहून संपर्क करत आहे.');
    final uri = Uri.parse('https://wa.me/$fullPhone?text=$message');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ad = widget.ad;
    final locale = ref.watch(localeProvider);
    final title = ad.localizedTitle(locale.languageCode);
    final desc = ad.localizedDescription(locale.languageCode);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.accentYellow.withValues(alpha: 0.4), width: 1.2),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          AdvertisementService.instance.trackClick(ad.id);
          context.push('/advertisement-detail', extra: ad);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner Image with Sponsored Badge
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 8,
                  child: CachedNetworkImage(
                    imageUrl: ad.imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey.shade200,
                      child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: AppColors.primaryBlue.withValues(alpha: 0.1),
                      child: const Center(child: Icon(Icons.broken_image_rounded, color: Colors.grey)),
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.accentYellow),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star_rounded, size: 12, color: AppColors.accentYellow),
                        const SizedBox(width: 4),
                        Text(
                          'प्रायोजित जाहिरात • नरडाणा',
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
              ],
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.mukta(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      height: 1.2,
                    ),
                  ),
                  if (desc.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      desc,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.mukta(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        height: 1.3,
                      ),
                    ),
                  ],

                  const SizedBox(height: 12),

                  // Actions row
                  Row(
                    children: [
                      if (ad.phone != null && ad.phone!.isNotEmpty) ...[
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _makeCall(ad.phone!),
                            icon: const Icon(Icons.call_rounded, size: 15),
                            label: Text(
                              'कॉल करा',
                              style: GoogleFonts.mukta(fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryBlue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],

                      if (ad.whatsapp != null && ad.whatsapp!.isNotEmpty) ...[
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _openWhatsApp(ad.whatsapp!, title),
                            icon: const Icon(Icons.chat_rounded, size: 15, color: AppColors.secondaryGreen),
                            label: Text(
                              'व्हॉट्सॲप',
                              style: GoogleFonts.mukta(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.secondaryGreen,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppColors.secondaryGreen),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],

                      InkWell(
                        onTap: () {
                          AdvertisementService.instance.trackClick(ad.id);
                          context.push('/advertisement-detail', extra: ad);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Text(
                            'तपशील →',
                            style: GoogleFonts.mukta(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryBlue,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

