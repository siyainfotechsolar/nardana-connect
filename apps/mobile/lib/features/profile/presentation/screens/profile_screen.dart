import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nardana_connect/core/constants/app_colors.dart';
import 'package:nardana_connect/core/localization/app_localizations.dart';
import 'package:nardana_connect/core/localization/locale_provider.dart';
import 'package:nardana_connect/features/village/providers/village_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final currentVillage = ref.watch(selectedVillageProvider);
    final currentLocale = ref.watch(localeProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text(l10n.translate('profile')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.1),
                      child: const Icon(Icons.person_rounded,
                          size: 36, color: AppColors.primaryBlue),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'गावकरी नागरिक (Citizen)',
                            style: GoogleFonts.mukta(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Icon(Icons.location_on_rounded,
                                  size: 14, color: AppColors.secondaryGreen),
                              const SizedBox(width: 4),
                              Text(
                                '${currentVillage.nameMr} (${currentVillage.taluka})',
                                style: GoogleFonts.mukta(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.secondaryGreen.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'सत्यापित गावकरी',
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
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.bookmark_border_rounded,
                        color: AppColors.primaryBlue),
                    title: Text(
                      l10n.translate('favorites'),
                      style: GoogleFonts.mukta(fontWeight: FontWeight.w600),
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => context.push('/favorites'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.translate_rounded,
                        color: AppColors.primaryBlue),
                    title: Text(
                      l10n.translate('change_language'),
                      style: GoogleFonts.mukta(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      currentLocale.languageCode == 'mr' ? 'मराठी' : 'English',
                      style: GoogleFonts.mukta(
                          fontSize: 12, color: AppColors.secondaryGreen),
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => context.push('/language'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.location_city_rounded,
                        color: AppColors.primaryBlue),
                    title: Text(
                      'माझे गाव बदला',
                      style: GoogleFonts.mukta(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      currentVillage.nameMr,
                      style: GoogleFonts.mukta(fontSize: 12),
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => context.push('/search'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.help_outline_rounded,
                        color: AppColors.primaryBlue),
                    title: Text(
                      l10n.translate('help_support'),
                      style: GoogleFonts.mukta(fontWeight: FontWeight.w600),
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () {
                      showAboutDialog(
                        context: context,
                        applicationName: 'नरडाणा कनेक्ट (Nardana Connect)',
                        applicationVersion: '1.0.0 (Community Edition)',
                        applicationLegalese:
                            'नरडाणा व परिसरातील सर्व गावांसाठी मोफत सामाजिक मंच.\nआपलं गाव, आपली डिजिटल ओळख!',
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.verified_user_rounded,
                          color: AppColors.secondaryGreen, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        'स्वतंत्र ग्राम समुदाय मंच',
                        style: GoogleFonts.mukta(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'या ॲप्लिकेशनमध्ये कोणत्याही प्रकारची व्यावसायिक विक्री किंवा जाहिरातबाजी केली जात नाही.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.mukta(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
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
