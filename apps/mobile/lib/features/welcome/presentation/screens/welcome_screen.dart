import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nardana_connect/core/constants/app_colors.dart';
import 'package:nardana_connect/core/localization/app_localizations.dart';

class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),

              Center(
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryBlue.withValues(alpha: 0.25),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      'NC',
                      style: GoogleFonts.mukta(
                        fontSize: 38,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              Text(
                l10n.translate('welcome_title'),
                textAlign: TextAlign.center,
                style: GoogleFonts.mukta(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryBlue,
                ),
              ),
              const SizedBox(height: 10),

              Text(
                l10n.translate('welcome_subtitle'),
                textAlign: TextAlign.center,
                style: GoogleFonts.mukta(
                  fontSize: 15,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 36),

              _buildFeatureRow(
                icon: Icons.store_rounded,
                title: 'स्थानिक सेवा व दुकाने',
                desc: 'इलेक्ट्रिशियन, प्लंबर, किराणा व कृषी सेवा थेट संपर्क',
              ),
              const SizedBox(height: 16),
              _buildFeatureRow(
                icon: Icons.campaign_rounded,
                title: 'ग्रामपंचायत सूचना व पाणी/वीज अपडेट',
                desc: 'गावातील अधिकृत माहिती व पाणी पुरवठ्याची वेळ त्वरित मिळवा',
              ),
              const SizedBox(height: 16),
              _buildFeatureRow(
                icon: Icons.handshake_rounded,
                title: 'रोजगार आणि स्थानिक बाजारपेठ',
                desc: 'स्थानिक पातळीवर खरेदी, विक्री व नोकऱ्यांचे मोफत व्यासपीठ',
              ),

              const Spacer(),

              ElevatedButton(
                onPressed: () => context.go('/home'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondaryGreen,
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      l10n.translate('skip_for_now'),
                      style: GoogleFonts.mukta(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward_rounded, size: 20),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle_rounded,
                        color: AppColors.secondaryGreen, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      l10n.translate('free_citizen_access'),
                      style: GoogleFonts.mukta(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.secondaryGreen,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureRow({
    required IconData icon,
    required String title,
    required String desc,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primaryBlue.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.primaryBlue, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.mukta(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                desc,
                style: GoogleFonts.mukta(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.25,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
