import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:nardana_connect/core/constants/app_colors.dart';
import 'package:nardana_connect/core/localization/locale_provider.dart';
import 'package:nardana_connect/core/navigation/app_back_scope.dart';
import 'package:nardana_connect/core/navigation/back_button_handler.dart';
import 'package:nardana_connect/features/advertisements/models/advertisement_model.dart';
import 'package:nardana_connect/features/advertisements/services/advertisement_service.dart';
import 'package:url_launcher/url_launcher.dart';

class AdvertisementDetailScreen extends ConsumerStatefulWidget {
  final AdvertisementModel ad;

  const AdvertisementDetailScreen({super.key, required this.ad});

  @override
  ConsumerState<AdvertisementDetailScreen> createState() => _AdvertisementDetailScreenState();
}

class _AdvertisementDetailScreenState extends ConsumerState<AdvertisementDetailScreen> {
  @override
  void initState() {
    super.initState();
    // Track impression when detail page is opened
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
    final message = Uri.encodeComponent('नमस्कार, मी नरडाणा कनेक्ट ॲपवर आपली जाहिरात ($title) पाहिली. अधिक माहिती हवी आहे.');
    final uri = Uri.parse('https://wa.me/$fullPhone?text=$message');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _openUrl(String url) async {
    AdvertisementService.instance.trackClick(widget.ad.id);
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ad = widget.ad;
    final locale = ref.watch(localeProvider);
    final title = ad.localizedTitle(locale.languageCode);
    final description = ad.localizedDescription(locale.languageCode);

    return AppBackScope(
      fallbackRoute: '/home',
      child: Scaffold(
        backgroundColor: AppColors.surface,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => BackButtonHandler.safePop(context, fallbackRoute: '/home'),
          ),
        title: Text(
          'जाहिरात तपशील',
          style: GoogleFonts.mukta(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded),
            tooltip: 'शेअर करा',
            onPressed: () {
              final shareText = '$title\n\n$description\n\nनरडाणा कनेक्ट ॲपवरून पाहिले.';
              _openWhatsApp('919823012345', shareText);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Responsive Hero Banner
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: ad.imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey.shade200,
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: AppColors.primaryBlue.withValues(alpha: 0.1),
                      child: const Center(
                        child: Icon(Icons.broken_image_rounded, size: 48, color: Colors.grey),
                      ),
                    ),
                  ),

                  // Top Gradient Badge
                  Positioned(
                    top: 14,
                    left: 14,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.75),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.accentYellow.withValues(alpha: 0.8)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.campaign_rounded, size: 14, color: AppColors.accentYellow),
                          const SizedBox(width: 4),
                          Text(
                            'प्रायोजित • नरडाणा',
                            style: GoogleFonts.mukta(
                              fontSize: 11,
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
            ),

            // Content Body
            Padding(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    title,
                    style: GoogleFonts.mukta(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // English Secondary Title if Marathi primary
                  if (locale.languageCode == 'mr' && ad.titleEn.isNotEmpty && ad.titleEn != ad.titleMr) ...[
                    Text(
                      ad.titleEn,
                      style: GoogleFonts.mukta(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 14),
                  ] else ...[
                    const SizedBox(height: 12),
                  ],

                  // Action Buttons Card
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            if (ad.phone != null && ad.phone!.isNotEmpty) ...[
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () => _makeCall(ad.phone!),
                                  icon: const Icon(Icons.call_rounded, size: 18),
                                  label: Text(
                                    'कॉल करा',
                                    style: GoogleFonts.mukta(fontSize: 14, fontWeight: FontWeight.bold),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryBlue,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 11),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                            ],

                            if (ad.whatsapp != null && ad.whatsapp!.isNotEmpty) ...[
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () => _openWhatsApp(ad.whatsapp!, title),
                                  icon: const Icon(Icons.chat_rounded, size: 18),
                                  label: Text(
                                    'व्हॉट्सॲप',
                                    style: GoogleFonts.mukta(fontSize: 14, fontWeight: FontWeight.bold),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.secondaryGreen,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 11),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),

                        if (ad.targetUrl != null && ad.targetUrl!.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () => _openUrl(ad.targetUrl!),
                              icon: const Icon(Icons.language_rounded, size: 18, color: AppColors.primaryBlue),
                              label: Text(
                                'अधिकृत वेबसाईट पहा (Open Link)',
                                style: GoogleFonts.mukta(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryBlue,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: AppColors.primaryBlue),
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Description Section
                  if (description.isNotEmpty) ...[
                    Text(
                      'ऑफर व जाहिरात माहिती (Details):',
                      style: GoogleFonts.mukta(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Text(
                        description,
                        style: GoogleFonts.mukta(
                          fontSize: 14,
                          color: AppColors.textPrimary,
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Advertiser Details Card
                  if (ad.advertiserName != null && ad.advertiserName!.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.15)),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.1),
                            child: const Icon(Icons.store_rounded, color: AppColors.primaryBlue),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'जाहिरातदार (Advertiser)',
                                  style: GoogleFonts.mukta(
                                    fontSize: 11,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                Text(
                                  ad.advertiserName!,
                                  style: GoogleFonts.mukta(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.secondaryGreen.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'सत्यापित',
                              style: GoogleFonts.mukta(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.secondaryGreen,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Exclusive Village Policy Notice
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.verified_user_rounded, color: AppColors.secondaryGreen, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'नरडाणा कनेक्ट धोरण: ही जाहिरात केवळ नरडाणा गाव परिसरातील नागरिकांसाठी प्रदर्शित करण्यात आली आहे.',
                            style: GoogleFonts.mukta(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
}

