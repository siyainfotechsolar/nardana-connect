import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nardana_connect/core/constants/app_colors.dart';
import 'package:nardana_connect/core/localization/locale_provider.dart';
import 'package:nardana_connect/core/navigation/back_button_handler.dart';
import 'package:nardana_connect/core/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen> {
  bool _isGoogleLoading = false;

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isGoogleLoading = true);
    try {
      // Supabase OAuth Google Sign-In
      await SupabaseService.client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'in.nardana.connect://login-callback',
      );
      if (mounted) {
        context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        // Fallback for emulator / web without OAuth setup
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'गुगल लॉगिन सुरू करण्यात आले. आपण थेट पाहुणा किंवा ईमेल लॉगिनही वापरू शकता.',
              style: GoogleFonts.mukta(),
            ),
            backgroundColor: AppColors.primaryBlue,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isGoogleLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentLocale = ref.watch(localeProvider);
    final isMr = currentLocale.languageCode == 'mr';

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await BackButtonHandler.handleHomeBackPress(context, isMr: isMr);
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(flex: 1),

                // Logo & Village Identity
                Center(
                  child: Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryBlue.withValues(alpha: 0.22),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Image.asset(
                        'assets/images/app_logo.png',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: AppColors.primaryBlue,
                          child: Center(
                            child: Text(
                              'NC',
                              style: GoogleFonts.mukta(
                                fontSize: 36,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                Text(
                  'नरडाणा कनेक्ट',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.mukta(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryBlue,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 6),

                Text(
                  'आपलं गाव, आपली डिजिटल ओळख!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.mukta(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondaryGreen,
                  ),
                ),
                const SizedBox(height: 4),

                Text(
                  'केवळ नरडाणा गाव (पिन: ४२५४०४) अधिकृत नागरिक मंच',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.mukta(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 28),

                // Features
                _buildFeatureRow(
                  icon: Icons.store_rounded,
                  title: 'स्थानिक सेवा व दुकाने',
                  desc: 'इलेक्ट्रिशियन, प्लंबर, किराणा व शेती अवजारे थेट संपर्क',
                ),
                const SizedBox(height: 14),
                _buildFeatureRow(
                  icon: Icons.campaign_rounded,
                  title: 'ग्रामपंचायत सूचना व पाणी/वीज अलर्ट',
                  desc: 'पाणी पुरवठा वेळापत्रक व अधिकृत गाव सूचना तात्काळ मिळवा',
                ),
                const SizedBox(height: 14),
                _buildFeatureRow(
                  icon: Icons.handshake_rounded,
                  title: 'स्थानिक बाजारपेठ व रोजगार',
                  desc: 'खरेदी-विक्री आणि गावपातळीवरील नोकऱ्यांची माहिती',
                ),

                const Spacer(flex: 2),

                // Button 1: Google Login
                OutlinedButton(
                  onPressed: _isGoogleLoading ? null : _handleGoogleSignIn,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    side: BorderSide(color: Colors.grey.shade300, width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    backgroundColor: Colors.white,
                  ),
                  child: _isGoogleLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.g_mobiledata_rounded, size: 28, color: Colors.red),
                            const SizedBox(width: 8),
                            Text(
                              'गुगलने सुरू करा (Continue with Google)',
                              style: GoogleFonts.mukta(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                ),
                const SizedBox(height: 10),

                // Button 2: Email Login
                ElevatedButton.icon(
                  onPressed: () => context.push('/login'),
                  icon: const Icon(Icons.email_outlined, size: 20),
                  label: Text(
                    'ईमेलद्वारे लॉगिन (Continue with Email)',
                    style: GoogleFonts.mukta(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
                const SizedBox(height: 10),

                // Button 3: Continue as Guest
                TextButton.icon(
                  onPressed: () => context.go('/home'),
                  icon: const Icon(Icons.person_outline_rounded, size: 18, color: AppColors.secondaryGreen),
                  label: Text(
                    'पाहुणा म्हणून पुढे जा (Continue as Guest)',
                    style: GoogleFonts.mukta(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.secondaryGreen,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    minimumSize: const Size.fromHeight(44),
                  ),
                ),
                const SizedBox(height: 8),

                Center(
                  child: Text(
                    'टीप: एसएमएस किंवा मोबाईल ओटीपीची आवश्यकता नाही.',
                    style: GoogleFonts.mukta(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
              ],
            ),
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
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            color: AppColors.primaryBlue.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.primaryBlue, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.mukta(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                desc,
                style: GoogleFonts.mukta(
                  fontSize: 12,
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
