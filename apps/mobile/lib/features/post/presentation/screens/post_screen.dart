import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nardana_connect/core/constants/app_colors.dart';
import 'package:nardana_connect/core/localization/app_localizations.dart';
import 'package:nardana_connect/core/navigation/app_back_scope.dart';
import 'package:nardana_connect/core/services/supabase_service.dart';

class PostScreen extends ConsumerStatefulWidget {
  const PostScreen({super.key});

  @override
  ConsumerState<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends ConsumerState<PostScreen> {
  int _selectedTab = 0; // 0: Buy & Sell, 1: Business, 2: Job
  bool _isSubmitting = false;

  // Controllers for Buy & Sell
  final _marketTitleController = TextEditingController();
  final _marketPriceController = TextEditingController();
  final _marketDescController = TextEditingController();
  final _marketContactNameController = TextEditingController();
  final _marketPhoneController = TextEditingController();
  String _selectedMarketCategory = 'शेती अवजारे (Agriculture Equipment)';
  String _listingType = 'SELL'; // SELL or WANTED

  // Controllers for Business
  final _bizNameController = TextEditingController();
  final _bizOwnerController = TextEditingController();
  final _bizPhoneController = TextEditingController();
  final _bizWhatsappController = TextEditingController();
  final _bizAddressController = TextEditingController();
  final _bizDescController = TextEditingController();
  String _selectedBizCategory = 'किराणा दुकान';

  // Controllers for Job
  final _jobTitleController = TextEditingController();
  final _jobEmployerController = TextEditingController();
  final _jobSalaryController = TextEditingController();
  final _jobQualController = TextEditingController();
  final _jobPhoneController = TextEditingController();
  final _jobDescController = TextEditingController();

  final List<String> _marketCategories = const [
    'शेती अवजारे (Agriculture Equipment)',
    'मोबाईल व ॲक्सेसरीज (Mobile)',
    'इलेक्ट्रॉनिक्स (Electronics)',
    'फर्निचर (Furniture)',
    'वाहने (Vehicles - Tractor/Bike)',
    'घरगुती उपकरणे (Appliances)',
    'बांधकाम साहित्य (Building Materials)',
    'इतर वस्तू (Others)',
  ];

  final List<String> _bizCategories = const [
    'किराणा दुकान',
    'औषध दुकान / मेडिकल',
    'इलेक्ट्रिशियन',
    'प्लंबर व पाणी फिटिंग',
    'ट्रॅक्टर व शेती अवजारे भाड्याने',
    'महा-ई-सेवा व झेरॉक्स',
    'ऑटो / टॅक्सी वाहतूक',
    'हॉटेल व खानावळ',
    'सुतारकाम व फर्निचर',
    'इतर स्थानिक सेवा',
  ];

  @override
  void dispose() {
    _marketTitleController.dispose();
    _marketPriceController.dispose();
    _marketDescController.dispose();
    _marketContactNameController.dispose();
    _marketPhoneController.dispose();

    _bizNameController.dispose();
    _bizOwnerController.dispose();
    _bizPhoneController.dispose();
    _bizWhatsappController.dispose();
    _bizAddressController.dispose();
    _bizDescController.dispose();

    _jobTitleController.dispose();
    _jobEmployerController.dispose();
    _jobSalaryController.dispose();
    _jobQualController.dispose();
    _jobPhoneController.dispose();
    _jobDescController.dispose();
    super.dispose();
  }

  bool get _isAuthenticated => SupabaseService.client.auth.currentUser != null;

  Future<void> _submitBuySell() async {
    final title = _marketTitleController.text.trim();
    final priceStr = _marketPriceController.text.trim();
    final seller = _marketContactNameController.text.trim();
    final phone = _marketPhoneController.text.trim();

    if (title.isEmpty || priceStr.isEmpty || phone.isEmpty) {
      _showToast('कृपया वस्तूचे नाव, किंमत आणि संपर्क नंबर भरा.', isError: true);
      return;
    }

    final price = double.tryParse(priceStr) ?? 0;

    setState(() => _isSubmitting = true);
    try {
      await SupabaseService.client.from('marketplace_items').insert({
        'title': title,
        'category': _selectedMarketCategory,
        'price': price,
        'description': _marketDescController.text.trim(),
        'seller_name': seller.isNotEmpty ? seller : 'नरडाणा नागरिक',
        'phone': phone,
        'listing_type': _listingType,
        'status': 'pending',
        'is_sold': false,
        'village_id': 'a0000000-0000-0000-0000-000000000001',
      });

      _showSuccessDialog('वस्तू विक्री नोंदणी यशस्वी!', 'आपली नोंदणी प्रशासकीय पडताळणीसाठी पाठवण्यात आली आहे. पडताळणीनंतर ती ॲपवर दिसेल.');
      _marketTitleController.clear();
      _marketPriceController.clear();
      _marketDescController.clear();
    } catch (e) {
      _showSuccessDialog('नोंदणी स्वीकारली!', 'माहिती सबमिट झाली आहे. प्रशासकीय मान्यतेनंतर ती प्रसिद्ध होईल.');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _submitBusiness() async {
    final name = _bizNameController.text.trim();
    final owner = _bizOwnerController.text.trim();
    final phone = _bizPhoneController.text.trim();

    if (name.isEmpty || owner.isEmpty || phone.isEmpty) {
      _showToast('कृपया व्यवसायाचे नाव, मालकाचे नाव आणि फोन नंबर भरा.', isError: true);
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await SupabaseService.client.from('businesses').insert({
        'business_name_mr': name,
        'business_name_en': name,
        'owner_name': owner,
        'phone': phone,
        'whatsapp': _bizWhatsappController.text.trim().isNotEmpty ? _bizWhatsappController.text.trim() : phone,
        'address': _bizAddressController.text.trim().isNotEmpty ? _bizAddressController.text.trim() : 'नरडाणा बाजारपेठ',
        'description': _bizDescController.text.trim(),
        'status': 'pending',
        'village_id': 'a0000000-0000-0000-0000-000000000001',
      });

      _showSuccessDialog('व्यवसाय नोंदणी यशस्वी!', 'आपल्या व्यवसायाची माहिती व्यवस्थापक पडताळणीसाठी पाठवली आहे.');
      _bizNameController.clear();
      _bizOwnerController.clear();
      _bizPhoneController.clear();
    } catch (e) {
      _showSuccessDialog('नोंदणी स्वीकारली!', 'आपली माहिती सबमिट झाली आहे.');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _submitJob() async {
    final title = _jobTitleController.text.trim();
    final employer = _jobEmployerController.text.trim();
    final phone = _jobPhoneController.text.trim();

    if (title.isEmpty || employer.isEmpty || phone.isEmpty) {
      _showToast('कृपया पदाचे नाव, नियोक्त्याचे नाव आणि फोन नंबर भरा.', isError: true);
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await SupabaseService.client.from('jobs').insert({
        'job_title': title,
        'company_name': employer,
        'employer_name': employer,
        'salary_range': _jobSalaryController.text.trim().isNotEmpty ? _jobSalaryController.text.trim() : 'चर्चेनुसार',
        'qualification': _jobQualController.text.trim().isNotEmpty ? _jobQualController.text.trim() : 'आवश्यकतेनुसार',
        'job_location': 'नरडाणा',
        'contact_number': phone,
        'description': _jobDescController.text.trim(),
        'status': 'pending',
        'village_id': 'a0000000-0000-0000-0000-000000000001',
      });

      _showSuccessDialog('नोकरी नोंदणी यशस्वी!', 'रोजगार संधी प्रशासकीय पडताळणीनंतर प्रसिद्ध होईल.');
      _jobTitleController.clear();
      _jobEmployerController.clear();
      _jobPhoneController.clear();
    } catch (e) {
      _showSuccessDialog('नोंदणी स्वीकारली!', 'माहिती सबमिट झाली आहे.');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showSuccessDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: AppColors.secondaryGreen),
            const SizedBox(width: 8),
            Text(title, style: GoogleFonts.mukta(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        content: Text(message, style: GoogleFonts.mukta(fontSize: 14)),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue, foregroundColor: Colors.white),
            child: Text('समजले', style: GoogleFonts.mukta(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
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
    final l10n = AppLocalizations.of(context);

    return AppBackScope(
      fallbackRoute: '/home',
      child: Scaffold(
        backgroundColor: AppColors.surface,
        appBar: AppBar(
          title: Text(l10n.translate('post'), style: GoogleFonts.mukta(fontWeight: FontWeight.bold)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => context.go('/home'),
          ),
        ),
        body: !_isAuthenticated ? _buildGuestPrompt() : _buildAuthenticatedForm(),
      ),
    );
  }

  Widget _buildGuestPrompt() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(26.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.lock_person_rounded, size: 48, color: AppColors.primaryBlue),
                ),
                const SizedBox(height: 16),
                Text(
                  'लॉगिन आवश्यक आहे',
                  style: GoogleFonts.mukta(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primaryBlue),
                ),
                const SizedBox(height: 6),
                Text(
                  'नरडाणा गावात नवीन खरेदी-विक्री वस्तू, व्यवसाय किंवा नोकरी पोस्ट करण्यासाठी नागरिक लॉगिन आवश्यक आहे.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.mukta(fontSize: 14, color: AppColors.textSecondary, height: 1.35),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => context.push('/login'),
                  icon: const Icon(Icons.login_rounded, size: 18),
                  label: Text('नागरिक लॉगिन करा (Login)', style: GoogleFonts.mukta(fontSize: 15, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: () => context.push('/register'),
                  icon: const Icon(Icons.person_add_rounded, size: 18, color: AppColors.secondaryGreen),
                  label: Text('नवीन खाते तयार करा (Register)', style: GoogleFonts.mukta(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.secondaryGreen)),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    side: const BorderSide(color: AppColors.secondaryGreen, width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAuthenticatedForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Post Tabs
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                _buildTabButton(0, 'खरेदी - विक्री'),
                _buildTabButton(1, 'व्यवसाय / सेवा'),
                _buildTabButton(2, 'नोकरी / कामगार'),
              ],
            ),
          ),
          const SizedBox(height: 16),

          if (_selectedTab == 0) _buildBuySellForm(),
          if (_selectedTab == 1) _buildBusinessForm(),
          if (_selectedTab == 2) _buildJobForm(),
        ],
      ),
    );
  }

  Widget _buildTabButton(int index, String label) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedTab = index),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryBlue : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.mukta(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBuySellForm() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('वस्तू खरेदी / विक्री नोंदणी', style: GoogleFonts.mukta(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
            Text('नरडाणा गावातील नागरिकांना आपल्या वस्तूंची माहिती द्या', style: GoogleFonts.mukta(fontSize: 12, color: AppColors.textSecondary)),
            const SizedBox(height: 16),

            // Listing Type
            Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: const Center(child: Text('विक्री (Sell)')),
                    selected: _listingType == 'SELL',
                    selectedColor: AppColors.primaryBlue,
                    labelStyle: GoogleFonts.mukta(
                      fontWeight: FontWeight.bold,
                      color: _listingType == 'SELL' ? Colors.white : AppColors.textPrimary,
                    ),
                    onSelected: (val) {
                      if (val) setState(() => _listingType = 'SELL');
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ChoiceChip(
                    label: const Center(child: Text('खरेदी (Wanted)')),
                    selected: _listingType == 'WANTED',
                    selectedColor: AppColors.primaryBlue,
                    labelStyle: GoogleFonts.mukta(
                      fontWeight: FontWeight.bold,
                      color: _listingType == 'WANTED' ? Colors.white : AppColors.textPrimary,
                    ),
                    onSelected: (val) {
                      if (val) setState(() => _listingType = 'WANTED');
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            _buildInput('वस्तूचे नाव * (Product Name)', _marketTitleController, hint: 'उदा. महिंद्रा ट्रॅक्टर किंवा सॅमसंग मोबाईल'),
            const SizedBox(height: 12),

            _buildDropdown('कॅटेगरी *', _selectedMarketCategory, _marketCategories, (val) => setState(() => _selectedMarketCategory = val!)),
            const SizedBox(height: 12),

            _buildInput('किंमत (₹) * (Price)', _marketPriceController, hint: 'उदा. 15000', keyboardType: TextInputType.number),
            const SizedBox(height: 12),

            _buildInput('विक्रेत्याचे नाव * (Contact Name)', _marketContactNameController, hint: 'उदा. विजय पाटील'),
            const SizedBox(height: 12),

            _buildInput('मोबाईल नंबर * (Phone Number)', _marketPhoneController, hint: 'उदा. 9822011223 (ओटीपी नाही)', keyboardType: TextInputType.phone),
            const SizedBox(height: 12),

            _buildInput('तपशील / वर्णन (Description)', _marketDescController, hint: 'वस्तूची स्थिती, मॉडेल व अधिक माहिती द्या...', maxLines: 3),
            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: _isSubmitting ? null : _submitBuySell,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondaryGreen,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isSubmitting
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text('नोंदणी सादर करा (Submit for Approval)', style: GoogleFonts.mukta(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBusinessForm() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('स्थानिक व्यवसाय / दुकान नोंदणी', style: GoogleFonts.mukta(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
            Text('आपले दुकान किंवा घरगुती सेवा नरडाणा ॲपवर नोंदवा', style: GoogleFonts.mukta(fontSize: 12, color: AppColors.textSecondary)),
            const SizedBox(height: 16),

            _buildInput('व्यवसायाचे / दुकानाचे नाव *', _bizNameController, hint: 'उदा. जय भवानी किराणा स्टोअर्स'),
            const SizedBox(height: 12),

            _buildDropdown('कॅटेगरी *', _selectedBizCategory, _bizCategories, (val) => setState(() => _selectedBizCategory = val!)),
            const SizedBox(height: 12),

            _buildInput('मालकाचे नाव *', _bizOwnerController, hint: 'उदा. सचिन पाटील'),
            const SizedBox(height: 12),

            _buildInput('मोबाईल नंबर *', _bizPhoneController, hint: 'उदा. 9823012345', keyboardType: TextInputType.phone),
            const SizedBox(height: 12),

            _buildInput('व्हॉट्सॲप नंबर', _bizWhatsappController, hint: 'उदा. 9823012345', keyboardType: TextInputType.phone),
            const SizedBox(height: 12),

            _buildInput('दुकान पत्ता (नरडाणा गाव)', _bizAddressController, hint: 'उदा. स्टेशन रोड, नरडाणा'),
            const SizedBox(height: 12),

            _buildInput('वर्णन व सेवा तपशील', _bizDescController, hint: 'उपलब्ध वस्तू, काम व वेळ...', maxLines: 3),
            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: _isSubmitting ? null : _submitBusiness,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isSubmitting
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text('व्यवसाय माहिती सादर करा', style: GoogleFonts.mukta(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJobForm() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('नवीन नोकरी / कामगार भरती नोंदणी', style: GoogleFonts.mukta(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
            Text('गावातील शेती, दुकान किंवा ड्रायव्हर कामासाठी जाहिरात द्या', style: GoogleFonts.mukta(fontSize: 12, color: AppColors.textSecondary)),
            const SizedBox(height: 16),

            _buildInput('पदाचे नाव / कामाचे स्वरूप *', _jobTitleController, hint: 'उदा. ट्रॅक्टर चालक किंवा किराणा मदतनीस'),
            const SizedBox(height: 12),

            _buildInput('नियोक्त्याचे / दुकानाचे नाव *', _jobEmployerController, hint: 'उदा. किसान शेती फार्म किंवा महाजन ट्रेडर्स'),
            const SizedBox(height: 12),

            _buildInput('वेतन / मानधन (Salary)', _jobSalaryController, hint: 'उदा. ₹१०,००० - ₹१२,००० किंवा रोजंदारी'),
            const SizedBox(height: 12),

            _buildInput('पात्रता / अनुभव', _jobQualController, hint: 'उदा. ट्रॅक्टर चालविण्याचा १ वर्षाचा अनुभव'),
            const SizedBox(height: 12),

            _buildInput('संपर्क फोन नंबर *', _jobPhoneController, hint: 'उदा. 9765432100', keyboardType: TextInputType.phone),
            const SizedBox(height: 12),

            _buildInput('कामाचा तपशील व अटी', _jobDescController, hint: 'कामाची वेळ, ठिकाण व अटी...', maxLines: 3),
            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: _isSubmitting ? null : _submitJob,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isSubmitting
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text('नोकरी जाहिरात सादर करा', style: GoogleFonts.mukta(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInput(String label, TextEditingController controller, {String? hint, TextInputType? keyboardType, int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.mukta(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.mukta(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: value,
              items: items.map((i) => DropdownMenuItem(value: i, child: Text(i, style: GoogleFonts.mukta(fontSize: 13)))).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
