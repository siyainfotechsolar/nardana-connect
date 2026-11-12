import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:nardana_connect/core/constants/app_colors.dart';
import 'package:nardana_connect/core/localization/locale_provider.dart';
import 'package:nardana_connect/core/navigation/app_back_scope.dart';
import 'package:nardana_connect/core/navigation/back_button_handler.dart';
import 'package:nardana_connect/features/app_update/services/app_update_service.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  String _version = '1.0.0';
  String _buildNumber = '1';

  @override
  void initState() {
    super.initState();
    _loadPackageInfo();
  }

  Future<void> _loadPackageInfo() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() {
          _version = info.version;
          _buildNumber = info.buildNumber;
        });
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final currentLocale = ref.watch(localeProvider);
    final isMr = currentLocale.languageCode == 'mr';

    return AppBackScope(
      fallbackRoute: '/home',
      child: Scaffold(
        backgroundColor: AppColors.surface,
        appBar: AppBar(
          title: Text(isMr ? 'ॲप सेटिंग्ज (Settings)' : 'App Settings', style: GoogleFonts.mukta(fontWeight: FontWeight.bold)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => BackButtonHandler.safePop(context, fallbackRoute: '/home'),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.translate_rounded, color: AppColors.primaryBlue),
                    title: Text('भाषा बदला (Change Language)', style: GoogleFonts.mukta(fontWeight: FontWeight.w600)),
                    subtitle: Text(isMr ? 'मराठी (सक्रिय)' : 'English (Active)', style: GoogleFonts.mukta(fontSize: 12, color: AppColors.secondaryGreen)),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => context.push('/language'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.notifications_active_outlined, color: AppColors.primaryBlue),
                    title: Text('पुश नोटिफिकेशन्स (Push Notifications)', style: GoogleFonts.mukta(fontWeight: FontWeight.w600)),
                    subtitle: Text('गाव सूचना व पाणी पुरवठा अलर्ट', style: GoogleFonts.mukta(fontSize: 12, color: AppColors.textSecondary)),
                    trailing: Switch(
                      value: true,
                      activeThumbColor: AppColors.secondaryGreen,
                      onChanged: (val) {},
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.location_city_rounded, color: AppColors.primaryBlue),
                    title: Text('अधिकृत भौगोलिक कव्हरेज', style: GoogleFonts.mukta(fontWeight: FontWeight.w600)),
                    subtitle: Text('केवळ नरडाणा गाव (पिन: ४२५४०४, ता. शिंदखेडा)', style: GoogleFonts.mukta(fontSize: 12, color: AppColors.secondaryGreen, fontWeight: FontWeight.bold)),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.system_update_rounded, color: AppColors.primaryBlue),
                    title: Text('ॲप आवृत्ती (App Version)', style: GoogleFonts.mukta(fontWeight: FontWeight.w600)),
                    subtitle: Text('v$_version (Build $_buildNumber) • नवीन APK डाऊनलोड करण्यासाठी क्लिक करा', style: GoogleFonts.mukta(fontSize: 12, color: AppColors.textSecondary)),
                    trailing: ElevatedButton.icon(
                      onPressed: () => AppUpdateService.instance.launchDirectApkDownload(),
                      icon: const Icon(Icons.download_rounded, size: 14),
                      label: Text('डाऊनलोड', style: GoogleFonts.mukta(fontSize: 11, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondaryGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    onTap: () => AppUpdateService.instance.launchDirectApkDownload(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Center(
              child: Column(
                children: [
                  Text(
                    'आपलं गाव, आपली डिजिटल ओळख!',
                    style: GoogleFonts.mukta(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primaryBlue),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Developed with ❤️ by Siya Infotech (Nardana)',
                    style: GoogleFonts.mukta(fontSize: 12, color: AppColors.textMuted),
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
