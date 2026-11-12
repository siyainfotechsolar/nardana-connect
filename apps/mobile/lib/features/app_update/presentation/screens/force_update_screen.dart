import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nardana_connect/core/constants/app_colors.dart';
import 'package:nardana_connect/core/localization/locale_provider.dart';
import 'package:nardana_connect/features/app_update/models/app_update_config_model.dart';
import 'package:nardana_connect/features/app_update/providers/app_update_provider.dart';
import 'package:nardana_connect/features/app_update/services/app_update_service.dart';

class ForceUpdateScreen extends ConsumerStatefulWidget {
  final AppUpdateConfigModel config;
  final String installedVersion;
  final int installedBuildNumber;

  const ForceUpdateScreen({
    super.key,
    required this.config,
    required this.installedVersion,
    required this.installedBuildNumber,
  });

  @override
  ConsumerState<ForceUpdateScreen> createState() => _ForceUpdateScreenState();
}

class _ForceUpdateScreenState extends ConsumerState<ForceUpdateScreen>
    with WidgetsBindingObserver {
  bool _isChecking = false;
  String? _statusNotice;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Re-verify version when returning from Play Store or browser
      _recheckVersion(fromResume: true);
    }
  }

  Future<void> _recheckVersion({bool fromResume = false}) async {
    setState(() {
      _isChecking = true;
      _statusNotice = null;
    });

    final service = ref.read(appUpdateServiceProvider);
    final result = await service.checkUpdateStatus(forceRefresh: true);

    if (!mounted) return;

    setState(() {
      _isChecking = false;
    });

    if (result.status != AppUpdateStatus.forceUpdateRequired) {
      // Version was updated! Recheck notifier so router or shell advances
      await ref.read(appUpdateNotifierProvider.notifier).checkUpdates(forceRefresh: true);
    } else if (fromResume) {
      // User returned from Play Store without updating
      setState(() {
        _statusNotice = 'ॲप अद्याप अपडेट झालेले नाही. कृपया प्ले स्टोअरवर "Update" वर क्लिक करा.';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'ॲप अद्याप जुन्या व्हर्जनवर आहे (${widget.installedVersion}). कृपया नवीन व्हर्जन अपडेट करा.',
            style: GoogleFonts.mukta(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.amber.shade900,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  Future<void> _handleUpdateClick() async {
    final service = ref.read(appUpdateServiceProvider);
    final launched = await service.launchUpdateUrl(widget.config);
    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'APK डाऊनलोड लिंक उघडताना अडचण आली. कृपया डाऊनलोड पोर्टलवरून APK मिळवा.',
            style: GoogleFonts.mukta(),
          ),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  Future<void> _handleOpenPortal() async {
    final service = ref.read(appUpdateServiceProvider);
    await service.launchDownloadPortal();
  }

  @override
  Widget build(BuildContext context) {
    final currentLocale = ref.watch(localeProvider);
    final lang = currentLocale.languageCode;
    final isMr = lang == 'mr';

    final title = widget.config.localizedTitle(lang);
    final message = widget.config.localizedMessage(lang);
    final releaseNotes = widget.config.localizedReleaseNotes(lang);

    return PopScope(
      canPop: false, // Locked: cannot pop or skip
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 28.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // App Icon with Update Badge
                  Center(
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(22),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryBlue.withValues(alpha: 0.25),
                                blurRadius: 18,
                                offset: const Offset(0, 8),
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
                                child: const Center(
                                  child: Icon(Icons.apps_rounded, color: Colors.white, size: 40),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade600,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2.5),
                          ),
                          child: const Icon(
                            Icons.system_update_rounded,
                            size: 18,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Heading
                  Text(
                    title.trim().isNotEmpty
                        ? title
                        : (isMr ? 'ॲप अपडेट करणे आवश्यक आहे!' : 'Mandatory Update Required!'),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.mukta(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isMr ? 'नरडाणा कनेक्ट (Nardana Connect)' : 'Nardana Connect Platform',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.mukta(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryBlue,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Version Comparison Card
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'NARDANA CONNECT • Platform: Android',
                          style: GoogleFonts.mukta(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryBlue,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                        Column(
                          children: [
                            Text(
                              isMr ? 'सध्याचे व्हर्जन' : 'Current Version',
                              style: GoogleFonts.mukta(
                                fontSize: 11,
                                color: AppColors.textMuted,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: Colors.red.shade200),
                              ),
                              child: Text(
                                'v${widget.installedVersion} (${widget.installedBuildNumber})',
                                style: GoogleFonts.mukta(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red.shade800,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Icon(Icons.arrow_forward_rounded, color: Colors.grey.shade400, size: 20),
                        Column(
                          children: [
                            Text(
                              isMr ? 'नवीन आवश्यक व्हर्जन' : 'Required Version',
                              style: GoogleFonts.mukta(
                                fontSize: 11,
                                color: AppColors.textMuted,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: Colors.green.shade200),
                              ),
                              child: Text(
                                'v${widget.config.latestVersion} (${widget.config.latestBuildNumber})',
                                style: GoogleFonts.mukta(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade800,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Message Text
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.mukta(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      height: 1.45,
                    ),
                  ),

                  if (_statusNotice != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.amber.shade300),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline_rounded, size: 18, color: Colors.amber.shade900),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _statusNotice!,
                              style: GoogleFonts.mukta(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.amber.shade900,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),

                  // Release Notes
                  if (releaseNotes.trim().isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.12)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.new_releases_outlined, size: 16, color: AppColors.primaryBlue),
                              const SizedBox(width: 6),
                              Text(
                                isMr ? 'नवीन सुधारणा (Release Notes):' : 'What is New:',
                                style: GoogleFonts.mukta(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryBlue,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            releaseNotes,
                            style: GoogleFonts.mukta(
                              fontSize: 12,
                              color: AppColors.textPrimary,
                              height: 1.45,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Update Now Button (Primary CTA - Direct APK Download)
                  ElevatedButton.icon(
                    onPressed: _handleUpdateClick,
                    icon: const Icon(Icons.download_rounded, size: 22),
                    label: Text(
                      isMr ? 'नवीन APK थेट डाऊनलोड करा (Download APK)' : 'Download APK Update',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondaryGreen,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      textStyle: GoogleFonts.mukta(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      elevation: 2,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Open Web Download Portal Button
                  OutlinedButton.icon(
                    onPressed: _handleOpenPortal,
                    icon: const Icon(Icons.open_in_browser_rounded, size: 18),
                    label: Text(
                      isMr ? 'अधिकृत डाऊनलोड पोर्टल उघडा (Web Portal)' : 'Open Web Download Portal',
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryBlue,
                      minimumSize: const Size.fromHeight(46),
                      side: const BorderSide(color: AppColors.primaryBlue),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      textStyle: GoogleFonts.mukta(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Recheck Status Button
                  TextButton.icon(
                    onPressed: _isChecking ? null : () => _recheckVersion(fromResume: false),
                    icon: _isChecking
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.refresh_rounded, size: 18),
                    label: Text(
                      _isChecking
                          ? (isMr ? 'तपासत आहे...' : 'Checking...')
                          : (isMr ? 'इन्स्टॉल केल्यावर तपासा (Verify Installation)' : 'Verify Installation'),
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                      minimumSize: const Size.fromHeight(42),
                      textStyle: GoogleFonts.mukta(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Help / Portal info
                  Text(
                    isMr
                        ? 'टीप: वरील बटणावर क्लिक करताच नवीन APK डाऊनलोड सुरू होईल. डाऊनलोड झाल्यावर फाईलवर क्लिक करून ॲप इन्स्टॉल करा.'
                        : 'Note: Tapping the button starts downloading the new APK. Once downloaded, tap the file to install.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.mukta(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
