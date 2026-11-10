import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nardana_connect/core/constants/app_colors.dart';
import 'package:nardana_connect/core/localization/locale_provider.dart';
import 'package:nardana_connect/features/app_update/models/app_update_config_model.dart';
import 'package:nardana_connect/features/app_update/providers/app_update_provider.dart';

class MaintenanceScreen extends ConsumerStatefulWidget {
  final AppUpdateConfigModel config;

  const MaintenanceScreen({super.key, required this.config});

  @override
  ConsumerState<MaintenanceScreen> createState() => _MaintenanceScreenState();
}

class _MaintenanceScreenState extends ConsumerState<MaintenanceScreen> {
  bool _isChecking = false;

  Future<void> _refreshStatus() async {
    setState(() => _isChecking = true);
    await ref.read(appUpdateNotifierProvider.notifier).checkUpdates(forceRefresh: true);
    if (mounted) {
      setState(() => _isChecking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentLocale = ref.watch(localeProvider);
    final lang = currentLocale.languageCode;
    final isMr = lang == 'mr';

    final message = widget.config.localizedMaintenanceMessage(lang);

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(28.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.amber.shade200, width: 2),
                      ),
                      child: Icon(
                        Icons.engineering_rounded,
                        size: 56,
                        color: Colors.amber.shade800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    isMr ? 'नियोजित तांत्रिक देखभाल' : 'Scheduled Maintenance',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.mukta(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isMr ? 'नरडाणा कनेक्ट (केवळ नरडाणा गाव)' : 'Nardana Connect Platform',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.mukta(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Text(
                      message,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.mukta(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  ElevatedButton.icon(
                    onPressed: _isChecking ? null : _refreshStatus,
                    icon: _isChecking
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.refresh_rounded, size: 20),
                    label: Text(
                      _isChecking
                          ? (isMr ? 'तपासत आहे...' : 'Checking...')
                          : (isMr ? 'स्थिती रिफ्रेश करा (Refresh)' : 'Refresh Status'),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      textStyle: GoogleFonts.mukta(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
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

