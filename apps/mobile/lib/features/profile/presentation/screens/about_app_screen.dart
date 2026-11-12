import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nardana_connect/core/constants/app_colors.dart';
import 'package:nardana_connect/core/localization/locale_provider.dart';
import 'package:nardana_connect/core/navigation/app_back_scope.dart';
import 'package:nardana_connect/core/navigation/back_button_handler.dart';
import 'package:nardana_connect/core/services/app_info_service.dart';
import 'package:nardana_connect/features/app_update/services/app_update_service.dart';

class AboutAppScreen extends ConsumerStatefulWidget {
  const AboutAppScreen({super.key});

  @override
  ConsumerState<AboutAppScreen> createState() => _AboutAppScreenState();
}

class _AboutAppScreenState extends ConsumerState<AboutAppScreen> {
  String _version = '...';
  String _buildNumber = '...';
  bool _isCheckingUpdate = false;
  String? _updateMessage;

  @override
  void initState() {
    super.initState();
    _loadVersionInfo();
  }

  Future<void> _loadVersionInfo() async {
    final info = await AppInfoService.instance.getPackageInfo();
    if (mounted) {
      setState(() {
        _version = info.version;
        _buildNumber = info.buildNumber;
      });
    }
  }

  Future<void> _checkForUpdates() async {
    setState(() {
      _isCheckingUpdate = true;
      _updateMessage = null;
    });

    try {
      final result = await AppUpdateService.instance.checkUpdateStatus(forceRefresh: true);
      if (!mounted) return;

      if (result.status == AppUpdateStatus.forceUpdateRequired) {
        setState(() {
          _updateMessage = '⚠️ नवीन सक्तीचे अपडेट आवश्यक आहे: v${result.config?.latestVersion} (Build ${result.config?.latestBuildNumber})';
        });
      } else if (result.status == AppUpdateStatus.optionalUpdateAvailable) {
        setState(() {
          _updateMessage = '✨ नवीन अपडेट उपलब्ध आहे: v${result.config?.latestVersion} (Build ${result.config?.latestBuildNumber})';
        });
      } else {
        setState(() {
          _updateMessage = '✅ आपले ॲप अद्ययावत (Up to Date) आहे!';
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _updateMessage = 'अपडेट माहिती तपासताना अडचण आली.';
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isCheckingUpdate = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentLocale = ref.watch(localeProvider);
    final isMr = currentLocale.languageCode == 'mr';

    return AppBackScope(
      fallbackRoute: '/settings',
      child: Scaffold(
        backgroundColor: AppColors.surface,
        appBar: AppBar(
          title: Text(
            isMr ? 'ॲप माहिती (About App)' : 'About App',
            style: GoogleFonts.mukta(fontWeight: FontWeight.bold),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => BackButtonHandler.safePop(context, fallbackRoute: '/settings'),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(20.0),
          children: [
            // Top App Identity Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryBlue.withValues(alpha: 0.2),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(22),
                      child: Image.asset(
                        'assets/images/app_logo.png',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: AppColors.primaryBlue,
                          child: const Icon(Icons.location_city_rounded, color: Colors.white, size: 40),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'NARDANA CONNECT',
                    style: GoogleFonts.mukta(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryBlue,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    'नरडाणा कनेक्ट • आपलं गाव, आपली डिजिटल ओळख!',
                    style: GoogleFonts.mukta(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Version $_version • Build $_buildNumber',
                      style: GoogleFonts.mukta(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Installed Version Details Card
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isMr ? 'इन्स्टॉल केलेली ॲप माहिती (Installed App Info)' : 'Installed App Details',
                      style: GoogleFonts.mukta(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Divider(height: 20),
                    _buildInfoRow('App Name (ॲप नाव)', 'NARDANA CONNECT'),
                    _buildInfoRow('App Version (आवृत्ती)', 'Version $_version'),
                    _buildInfoRow('Build Number (बिल्ड)', 'Build $_buildNumber'),
                    _buildInfoRow('Platform (प्लॅटफॉर्म)', 'Android'),
                    _buildInfoRow('Package Name (आयडी)', 'in.nardana.connect.nardana_connect'),
                    _buildInfoRow('Coverage (भौगोलिक क्षेत्र)', 'केवळ नरडाणा गाव (४२५४०४)'),
                    _buildInfoRow('Developer (विकसित)', 'Siya Infotech (Nardana)'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Update Check & Actions Card
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      isMr ? 'ॲप अद्ययावत नियंत्रण (Version Management)' : 'Update Management',
                      style: GoogleFonts.mukta(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (_updateMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _updateMessage!.contains('✅')
                              ? Colors.green.shade50
                              : Colors.amber.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _updateMessage!.contains('✅')
                                ? Colors.green.shade200
                                : Colors.amber.shade200,
                          ),
                        ),
                        child: Text(
                          _updateMessage!,
                          style: GoogleFonts.mukta(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: _updateMessage!.contains('✅')
                                ? Colors.green.shade800
                                : Colors.amber.shade900,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    ElevatedButton.icon(
                      onPressed: _isCheckingUpdate ? null : _checkForUpdates,
                      icon: _isCheckingUpdate
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.sync_rounded, size: 18),
                      label: Text(
                        _isCheckingUpdate
                            ? (isMr ? 'तपासत आहे...' : 'Checking...')
                            : (isMr ? 'नवीन आवृत्ती तपासा (Check Update)' : 'Check for Updates'),
                        style: GoogleFonts.mukta(fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      onPressed: () => AppUpdateService.instance.launchDirectApkDownload(),
                      icon: const Icon(Icons.download_rounded, size: 18),
                      label: Text(
                        isMr ? 'नवीन APK थेट डाऊनलोड करा' : 'Download Latest APK',
                        style: GoogleFonts.mukta(fontWeight: FontWeight.bold),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.secondaryGreen,
                        side: const BorderSide(color: AppColors.secondaryGreen, width: 1.5),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            Center(
              child: Text(
                '© 2026 Siya Infotech (Nardana) • All Rights Reserved',
                style: GoogleFonts.mukta(fontSize: 12, color: AppColors.textMuted),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: GoogleFonts.mukta(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 6,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: GoogleFonts.mukta(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
