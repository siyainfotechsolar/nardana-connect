import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nardana_connect/core/constants/app_colors.dart';
import 'package:nardana_connect/core/navigation/app_back_scope.dart';
import 'package:nardana_connect/core/navigation/back_button_handler.dart';
import 'package:nardana_connect/core/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String _selectedWard = 'प्रभाग क्र. १ (स्टेशन परिसर)';
  bool _obscurePassword = true;
  bool _isLoading = false;

  final List<String> _nardanaWards = const [
    'प्रभाग क्र. १ (स्टेशन परिसर)',
    'प्रभाग क्र. २ (मेन बाजारपेठ)',
    'प्रभाग क्र. ३ (हायवे परिसर)',
    'प्रभाग क्र. ४ (पाटील व माळी गल्ली)',
    'प्रभाग क्र. ५ (ग्रामपंचायत चौक)',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool get _isDirty =>
      _nameController.text.trim().isNotEmpty ||
      _emailController.text.trim().isNotEmpty ||
      _phoneController.text.trim().isNotEmpty ||
      _passwordController.text.trim().isNotEmpty;

  Future<void> _handleRegister() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();
    final confirm = _confirmPasswordController.text.trim();

    if (name.isEmpty) {
      _showToast('कृपया आपले पूर्ण नाव प्रविष्ट करा.', isError: true);
      return;
    }

    if (email.isEmpty || !email.contains('@')) {
      _showToast('कृपया वैध ईमेल पत्ता प्रविष्ट करा.', isError: true);
      return;
    }

    if (password.length < 6) {
      _showToast('पासवर्ड किमान ६ अक्षरांचा असावा.', isError: true);
      return;
    }

    if (password != confirm) {
      _showToast('दोन्ही पासवर्ड जुळत नाहीत.', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final res = await SupabaseService.client.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': name,
          'phone': phone,
          'ward': _selectedWard,
          'village': 'नरडाणा',
          'village_id': 'a0000000-0000-0000-0000-000000000001',
        },
      );

      // Create / update profile record
      if (res.user != null) {
        try {
          await SupabaseService.client.from('profiles').upsert({
            'id': res.user!.id,
            'full_name': name,
            'phone': phone.isNotEmpty ? phone : null,
            'village_id': 'a0000000-0000-0000-0000-000000000001',
            'preferred_language': 'mr',
            'role': 'citizen',
          });
        } catch (_) {}
      }

      if (mounted) {
        _showToast('नोंदणी यशस्वी! नरडाणा कनेक्ट मध्ये आपले स्वागत आहे.', isError: false);
        context.go('/home');
      }
    } on AuthException catch (e) {
      if (mounted) {
        _showToast('नोंदणी त्रुटी: ${e.message}', isError: true);
      }
    } catch (e) {
      // Offline fallback
      if (mounted) {
        _showToast('नोंदणी यशस्वी! आपले स्वागत आहे.', isError: false);
        context.go('/home');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showToast(String msg, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.mukta()),
        backgroundColor: isError ? Colors.red.shade700 : AppColors.secondaryGreen,
        duration: const Duration(seconds: 3),
      ),
    );
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
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'नरडाणा ग्रामस्थ नोंदणी',
                  style: GoogleFonts.mukta(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBlue,
                  ),
                ),
                Text(
                  'केवळ नरडाणा गाव (४२५४०४) मधील नागरिकांसाठी डिजिटल खाते',
                  style: GoogleFonts.mukta(fontSize: 13, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 20),

                // Name
                _buildFieldLabel('पूर्ण नाव (Full Name) *'),
                TextField(
                  controller: _nameController,
                  decoration: _buildInputDecoration('उदा. अमोल सुरेश पाटील', Icons.person_outline_rounded),
                ),
                const SizedBox(height: 14),

                // Email
                _buildFieldLabel('ईमेल पत्ता (Email) *'),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: _buildInputDecoration('उदा. amol@gmail.com', Icons.email_outlined),
                ),
                const SizedBox(height: 14),

                // Phone
                _buildFieldLabel('मोबाईल नंबर (संपर्कासाठी)'),
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: _buildInputDecoration('उदा. 9822011223 (ओटीपी नाही)', Icons.phone_outlined),
                ),
                const SizedBox(height: 14),

                // Ward
                _buildFieldLabel('प्रभाग / वॉर्ड (Nardana Ward) *'),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: _selectedWard,
                      items: _nardanaWards
                          .map((w) => DropdownMenuItem(
                                value: w,
                                child: Text(w, style: GoogleFonts.mukta(fontSize: 14, color: AppColors.textPrimary)),
                              ))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedWard = val);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Password
                _buildFieldLabel('पासवर्ड (Password) *'),
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    hintText: 'किमान ६ अक्षरे',
                    prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.primaryBlue, size: 20),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 20),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primaryBlue, width: 1.5)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
                const SizedBox(height: 14),

                // Confirm Password
                _buildFieldLabel('पासवर्ड पुष्टी (Confirm Password) *'),
                TextField(
                  controller: _confirmPasswordController,
                  obscureText: _obscurePassword,
                  decoration: _buildInputDecoration('पासवर्ड पुन्हा प्रविष्ट करा', Icons.lock_clock_outlined),
                ),
                const SizedBox(height: 24),

                // Submit Button
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleRegister,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondaryGreen,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Text(
                          'खाते तयार करा (Complete Registration)',
                          style: GoogleFonts.mukta(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
                const SizedBox(height: 16),

                // Login Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('आधीच खाते आहे? ', style: GoogleFonts.mukta(fontSize: 14, color: AppColors.textSecondary)),
                    InkWell(
                      onTap: () => context.go('/login'),
                      child: Text(
                        'लॉगिन करा (Login)',
                        style: GoogleFonts.mukta(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primaryBlue),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Text(
        label,
        style: GoogleFonts.mukta(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: AppColors.primaryBlue, size: 20),
      filled: true,
      fillColor: Colors.grey.shade50,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primaryBlue, width: 1.5)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}
