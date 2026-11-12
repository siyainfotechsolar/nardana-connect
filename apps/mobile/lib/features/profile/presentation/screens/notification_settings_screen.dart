import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nardana_connect/core/constants/app_colors.dart';
import 'package:nardana_connect/core/localization/locale_provider.dart';
import 'package:nardana_connect/core/navigation/app_back_scope.dart';
import 'package:nardana_connect/core/navigation/back_button_handler.dart';
import 'package:nardana_connect/core/services/notification_service.dart';

class NotificationSettingsScreen extends ConsumerStatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  ConsumerState<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends ConsumerState<NotificationSettingsScreen> {
  bool _isTesting = false;
  String? _testSuccessMsg;

  Future<void> _handleTestNotification() async {
    setState(() {
      _isTesting = true;
      _testSuccessMsg = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'कृपया लगेच फोन लॉक करा! ३ सेकंदात लॉक स्क्रीनवर नोटिफिकेशन येईल.',
          style: GoogleFonts.mukta(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primaryBlue,
        duration: const Duration(seconds: 3),
      ),
    );

    await NotificationService.instance.triggerLockScreenTestNotification(
      title: 'NARDANA CONNECT • पाणी पुरवठा अलर्ट',
      body: 'उद्या सकाळी ७ ते ९ दरम्यान मेन बाजारपेठ व स्टेशन भागात पाणीपुरवठा राहील.',
    );

    if (mounted) {
      setState(() {
        _isTesting = false;
        _testSuccessMsg = 'चाचणी नोटिफिकेशन पाठवले गेले! स्क्रीन लॉक करून तपासा.';
      });
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
            isMr ? 'नोटिफिकेशन्स व लॉक स्क्रीन' : 'Notification Settings',
            style: GoogleFonts.mukta(fontWeight: FontWeight.bold),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () =>
                BackButtonHandler.safePop(context, fallbackRoute: '/settings'),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Status Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.secondaryGreen.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.screen_lock_portrait_rounded,
                          color: AppColors.secondaryGreen,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isMr
                                  ? 'लॉक स्क्रीन अलर्ट्स सक्षम (Active)'
                                  : 'Lock Screen Alerts Active',
                              style: GoogleFonts.mukta(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              'चॅनेल: nardana_connect_alerts (High Priority)',
                              style: GoogleFonts.mukta(
                                fontSize: 11.5,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                  _buildStatusRow(
                    isMr ? 'ध्वनी (Sound)' : 'Sound',
                    isMr ? 'सिस्टीम डीफॉल्ट रिंगटोन' : 'Default',
                    Icons.volume_up_rounded,
                  ),
                  _buildStatusRow(
                    isMr ? 'कंपन (Vibration)' : 'Vibration',
                    isMr ? 'सक्रिय (Enabled)' : 'Enabled',
                    Icons.vibration_rounded,
                  ),
                  _buildStatusRow(
                    isMr ? 'लॉक स्क्रीन दृश्यमानता' : 'Lock Screen Visibility',
                    isMr ? 'सार्वजनिक (Public - पूर्ण मजकूर)' : 'Public (Full Content)',
                    Icons.visibility_rounded,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Live Test Button Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.blue.shade100),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryBlue.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    isMr
                        ? '🧪 लॉक स्क्रीन चाचणी (Test Lock Screen)'
                        : 'Test Lock Screen Notification',
                    style: GoogleFonts.mukta(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isMr
                        ? 'खालील बटण दाबल्यावर ३ सेकंदात फोन लॉक करा, फोनवर वाजून नोटिफिकेशन दिसेल.'
                        : 'Tap the button below and immediately lock your phone to verify lock screen delivery.',
                    style: GoogleFonts.mukta(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_testSuccessMsg != null) ...[
                    Container(
                      padding: const EdgeInsets.all(10),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Text(
                        _testSuccessMsg!,
                        style: GoogleFonts.mukta(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade800,
                        ),
                      ),
                    ),
                  ],
                  ElevatedButton.icon(
                    onPressed: _isTesting ? null : _handleTestNotification,
                    icon: _isTesting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.notifications_active_rounded, size: 18),
                    label: Text(
                      _isTesting
                          ? (isMr ? 'तयार करत आहे...' : 'Sending...')
                          : (isMr
                              ? 'चाचणी लॉक-स्क्रीन नोटिफिकेशन पाठवा'
                              : 'Send Test Lock-Screen Notification'),
                      style: GoogleFonts.mukta(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Manufacturer Settings Guide
            Text(
              isMr
                  ? '📱 मोबाईल ब्रँडनुसार लॉक स्क्रीन सेटिंग्ज (Settings Guide)'
                  : 'Device Settings Guide',
              style: GoogleFonts.mukta(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),

            _buildBrandGuide(
              'Samsung (One UI)',
              'Settings > Notifications > Lock screen notifications > "Show content" निवडा.',
              Icons.phone_android_rounded,
            ),
            _buildBrandGuide(
              'Xiaomi / Redmi / POCO (HyperOS / MIUI)',
              'Settings > Notifications > Lock screen > "Show notification and content" निवडा. तसेच Apps > Nardana Connect > Autostart ON करा.',
              Icons.smartphone_rounded,
            ),
            _buildBrandGuide(
              'Vivo / iQOO (Funtouch OS)',
              'Settings > Notifications > Lock screen > "Display all notification content" चालू ठेवा व Battery मध्ये High background usage ऑन करा.',
              Icons.mobile_friendly_rounded,
            ),
            _buildBrandGuide(
              'Oppo / Realme (ColorOS / Realme UI)',
              'Settings > Notification & Status Bar > Lock Screen > "Show title and body" निवडा व Background Activity सुरु ठेवा.',
              Icons.devices_other_rounded,
            ),
            _buildBrandGuide(
              'OnePlus (OxygenOS)',
              'Settings > Notification & status bar > Lock screen > "Show all notifications" निवडा.',
              Icons.phone_iphone_rounded,
            ),

            const SizedBox(height: 16),

            // Important Note
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline_rounded,
                      color: Colors.amber.shade900, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isMr
                          ? 'टीप: फोनमधील Do Not Disturb (DND) किंवा ॲप फोर्स-स्टॉप केलेले असल्यास Android सिस्टीम कोणत्याही ॲपचे नोटिफिकेशन ब्लॉक करते.'
                          : 'Note: Do Not Disturb mode or Force Stopping the app will cause Android OS to suppress all notifications.',
                      style: GoogleFonts.mukta(
                        fontSize: 11.5,
                        color: Colors.amber.shade900,
                        height: 1.35,
                      ),
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

  Widget _buildStatusRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.primaryBlue),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.mukta(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.mukta(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrandGuide(String brand, String steps, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0.5,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: AppColors.primaryBlue),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    brand,
                    style: GoogleFonts.mukta(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    steps,
                    style: GoogleFonts.mukta(
                      fontSize: 11.5,
                      color: AppColors.textSecondary,
                      height: 1.35,
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

