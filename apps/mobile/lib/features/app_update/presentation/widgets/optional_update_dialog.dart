import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nardana_connect/core/constants/app_colors.dart';
import 'package:nardana_connect/core/localization/locale_provider.dart';
import 'package:nardana_connect/features/app_update/models/app_update_config_model.dart';
import 'package:nardana_connect/features/app_update/providers/app_update_provider.dart';

class OptionalUpdateDialog extends ConsumerWidget {
  final AppUpdateConfigModel config;
  final String installedVersion;
  final int installedBuildNumber;

  const OptionalUpdateDialog({
    super.key,
    required this.config,
    required this.installedVersion,
    required this.installedBuildNumber,
  });

  static Future<void> show(
    BuildContext context, {
    required AppUpdateConfigModel config,
    required String installedVersion,
    required int installedBuildNumber,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => OptionalUpdateDialog(
        config: config,
        installedVersion: installedVersion,
        installedBuildNumber: installedBuildNumber,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider);
    final lang = currentLocale.languageCode;
    final isMr = lang == 'mr';

    final title = config.localizedTitle(lang);
    final message = config.localizedMessage(lang);
    final releaseNotes = config.localizedReleaseNotes(lang);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      actionsPadding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.secondaryGreen.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.rocket_launch_rounded, color: AppColors.secondaryGreen, size: 22),
          ),
          const SizedBox(width: 12),
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
                    height: 1.2,
                  ),
                ),
                Text(
                  'v${config.latestVersion} (${config.latestBuildNumber})',
                  style: GoogleFonts.mukta(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBlue,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              message,
              style: GoogleFonts.mukta(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.blue.shade100),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isMr ? 'सध्याचे: v$installedVersion ($installedBuildNumber)' : 'Current: v$installedVersion ($installedBuildNumber)',
                    style: GoogleFonts.mukta(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                  ),
                  const Icon(Icons.arrow_forward_rounded, size: 14, color: AppColors.primaryBlue),
                  Text(
                    isMr ? 'नवीन: v${config.latestVersion} (${config.latestBuildNumber})' : 'Latest: v${config.latestVersion} (${config.latestBuildNumber})',
                    style: GoogleFonts.mukta(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.secondaryGreen),
                  ),
                ],
              ),
            ),
            if (releaseNotes.trim().isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isMr ? 'नवीन वैशिष्ट्ये:' : 'What is New:',
                      style: GoogleFonts.mukta(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      releaseNotes,
                      style: GoogleFonts.mukta(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            ref.read(appUpdateNotifierProvider.notifier).dismissOptional();
            Navigator.of(context).pop();
          },
          child: Text(
            isMr ? 'नंतर करा' : 'Later',
            style: GoogleFonts.mukta(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textMuted,
            ),
          ),
        ),
        ElevatedButton.icon(
          onPressed: () {
            Navigator.of(context).pop();
            ref.read(appUpdateServiceProvider).launchUpdateUrl(config);
          },
          icon: const Icon(Icons.download_rounded, size: 18),
          label: Text(isMr ? 'नवीन APK डाऊनलोड करा' : 'Download APK'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.secondaryGreen,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            textStyle: GoogleFonts.mukta(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
