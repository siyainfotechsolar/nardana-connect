import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nardana_connect/core/constants/app_colors.dart';
import 'package:nardana_connect/core/navigation/app_back_scope.dart';
import 'package:nardana_connect/core/navigation/back_button_handler.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _wardController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _wardController.dispose();
    super.dispose();
  }

  bool get _isDirty =>
      _nameController.text.trim().isNotEmpty ||
      _phoneController.text.trim().isNotEmpty ||
      _wardController.text.trim().isNotEmpty;

  void _handleRegister() {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();

    if (name.isEmpty || phone.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('कृपया आपले पूर्ण नाव आणि १० अंकी मोबाईल नंबर प्रविष्ट करा.', style: GoogleFonts.mukta()),
          backgroundColor: Colors.red.shade700,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('नोंदणी यशस्वी! नरडाणा कनेक्ट मध्ये आपले स्वागत आहे.', style: GoogleFonts.mukta()),
            backgroundColor: AppColors.secondaryGreen,
          ),
        );
        context.go('/home');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppBackScope(
      fallbackRoute: '/login',
      onWillPop: () async {
        if (_isDirty) {
          final shouldDiscard = await BackButtonHandler.confirmDiscardChanges(context, isMr: true);
          return shouldDiscard;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text('नागरिक नोंदणी (Registration)', style: GoogleFonts.mukta(fontWeight: FontWeight.bold)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () async {
              if (_isDirty) {
                final discard = await BackButtonHandler.confirmDiscardChanges(context, isMr: true);
                if (discard && context.mounted) {
                  context.go('/login');
                }
              } else {
                context.go('/login');
              }
            },
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      color: AppColors.secondaryGreen.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.person_add_alt_1_rounded, size: 36, color: AppColors.secondaryGreen),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'नरडाणा नागरिक नोंदणी',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.mukta(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'केवळ नरडाणा गाव (पिन: ४२५४०४) येथील नागरिकांसाठी',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.mukta(
                    fontSize: 13,
                    color: AppColors.secondaryGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 28),

                // Full Name
                Text(
                  'पूर्ण नाव (Full Name)',
                  style: GoogleFonts.mukta(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _nameController,
                  style: GoogleFonts.mukta(fontSize: 15),
                  decoration: InputDecoration(
                    hintText: 'उदा. सागर पाटील',
                    prefixIcon: const Icon(Icons.person_outline_rounded, color: AppColors.primaryBlue),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),

                // Phone
                Text(
                  'मोबाईल नंबर (Mobile Number)',
                  style: GoogleFonts.mukta(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  style: GoogleFonts.mukta(fontSize: 15),
                  decoration: InputDecoration(
                    prefixIcon: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      child: Text('+91', style: GoogleFonts.mukta(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                    prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                    hintText: '98XXXXXXXX',
                    counterText: '',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),

                // Ward / Mohalla in Nardana
                Text(
                  'नरडाणा पत्ता / गल्ली (Street / Ward in Nardana)',
                  style: GoogleFonts.mukta(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _wardController,
                  style: GoogleFonts.mukta(fontSize: 15),
                  decoration: InputDecoration(
                    hintText: 'उदा. स्टेशन रोड / कुंभार गल्ली / मेन बाजार',
                    prefixIcon: const Icon(Icons.home_work_outlined, color: AppColors.primaryBlue),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),

                // Fixed Village Badge
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on_rounded, color: AppColors.secondaryGreen, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'कार्यक्षेत्र: नरडाणा (पिन: ४२५४०४, ता. शिंदखेडा, जि. धुळे)',
                          style: GoogleFonts.mukta(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                ElevatedButton(
                  onPressed: _isLoading ? null : _handleRegister,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondaryGreen,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text('नोंदणी पूर्ण करा (Register)', style: GoogleFonts.mukta(fontSize: 16, fontWeight: FontWeight.bold)),
                ),

                const SizedBox(height: 20),
                Center(
                  child: GestureDetector(
                    onTap: () => context.go('/login'),
                    child: Text(
                      'आधीच खाते आहे? लॉगिन करा',
                      style: GoogleFonts.mukta(
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
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
}
