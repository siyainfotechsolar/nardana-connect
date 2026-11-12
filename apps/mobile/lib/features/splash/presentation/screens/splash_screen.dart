import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nardana_connect/core/constants/app_colors.dart';
import 'package:nardana_connect/core/services/app_info_service.dart';
import 'package:nardana_connect/features/app_update/services/app_update_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String _version = '';
  String _buildNumber = '';

  @override
  void initState() {
    super.initState();
    _loadVersion();
    _checkNextScreen();
  }

  Future<void> _loadVersion() async {
    final info = await AppInfoService.instance.getPackageInfo();
    if (mounted) {
      setState(() {
        _version = info.version;
        _buildNumber = info.buildNumber;
      });
    }
  }

  Future<void> _checkNextScreen() async {
    // Give splash branding visual time, while checking update status concurrently
    final checkFuture = AppUpdateService.instance.checkUpdateStatus();
    await Future.wait([
      Future.delayed(const Duration(milliseconds: 1600)),
      checkFuture,
    ]);

    if (!mounted) return;

    final updateResult = await checkFuture;

    if (updateResult.status == AppUpdateStatus.maintenanceMode && updateResult.config != null) {
      if (mounted) {
        context.go('/maintenance', extra: updateResult.config);
      }
      return;
    }

    if (updateResult.status == AppUpdateStatus.forceUpdateRequired && updateResult.config != null) {
      if (mounted) {
        context.go('/force-update', extra: {
          'config': updateResult.config,
          'installedVersion': updateResult.installedVersion,
          'installedBuildNumber': updateResult.installedBuildNumber,
        });
      }
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final hasChosenLang = prefs.getBool('language_selected') ?? false;

    if (!mounted) return;
    if (!hasChosenLang) {
      context.go('/language');
    } else {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBlue,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 108,
              height: 108,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 22,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: Image.asset(
                  'assets/images/app_logo.png',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.white,
                    child: Center(
                      child: Text(
                        'NC',
                        style: GoogleFonts.mukta(
                          fontSize: 42,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'नरडाणा कनेक्ट',
              style: GoogleFonts.mukta(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'NARDANA CONNECT',
              style: GoogleFonts.mukta(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.accentYellow,
                letterSpacing: 2.0,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'आपलं गाव, आपली डिजिटल ओळख!',
              style: GoogleFonts.mukta(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),
            const SizedBox(height: 36),
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.accentYellow),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'विकसित: सिया इन्फोटेक (नरडाणा)',
              style: GoogleFonts.mukta(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),
            Text(
              'Developed by Siya Infotech (Nardana)',
              style: GoogleFonts.mukta(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.accentYellow,
                letterSpacing: 0.5,
              ),
            ),
            if (_version.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Version $_version • Build $_buildNumber • Android',
                  style: GoogleFonts.mukta(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.95),
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
