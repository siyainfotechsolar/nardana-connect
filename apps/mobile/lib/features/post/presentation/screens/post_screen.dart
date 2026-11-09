import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nardana_connect/core/constants/app_colors.dart';
import 'package:nardana_connect/core/localization/app_localizations.dart';

class PostScreen extends ConsumerStatefulWidget {
  const PostScreen({super.key});

  @override
  ConsumerState<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends ConsumerState<PostScreen> {
  int _selectedPostType = 0;
  final _phoneController = TextEditingController();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _ownerController = TextEditingController();
  final _addressController = TextEditingController();
  bool _otpSent = false;
  final _otpController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    _titleController.dispose();
    _descController.dispose();
    _ownerController.dispose();
    _addressController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _submitListing() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.check_circle_rounded,
                color: AppColors.secondaryGreen),
            const SizedBox(width: 8),
            Text(
              'नोंदणी स्वीकारली',
              style: GoogleFonts.mukta(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(
          'आपली माहिती यशस्वीरीत्या सबमिट झाली आहे. व्यवस्थापक (Admin) पडताळणीनंतर ही नोंदणी २ तासांत ॲपवर प्रसिद्ध केली जाईल.',
          style: GoogleFonts.mukta(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _titleController.clear();
              _descController.clear();
              _addressController.clear();
            },
            child: Text(
              'समजले',
              style: GoogleFonts.mukta(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text(l10n.translate('post')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  _buildTypeTab(0, 'व्यवसाय / सेवा'),
                  _buildTypeTab(1, 'रोजगार / नोकरी'),
                  _buildTypeTab(2, 'खरेदी - विक्री'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      _selectedPostType == 0
                          ? 'स्थानिक व्यवसाय / दुकान नोंदणी'
                          : _selectedPostType == 1
                              ? 'नवीन नोकरी / कामगार भरती'
                              : 'बाजारपेठ वस्तू विक्री',
                      style: GoogleFonts.mukta(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'गावकऱ्यांच्या सोयीसाठी खरी व अचूक माहिती भरा. पडताळणीनंतर थेट प्रसिद्ध होईल.',
                      style: GoogleFonts.mukta(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 18),
                    TextField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: _selectedPostType == 0
                            ? 'व्यवसायाचे / दुकानाचे नाव'
                            : _selectedPostType == 1
                                ? 'पदाचे नाव (उदा. ट्रॅक्टर चालक)'
                                : 'वस्तूचे नाव (उदा. रोटाव्हेटर)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _ownerController,
                      decoration: InputDecoration(
                        labelText: 'आपले पूर्ण नाव',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: 'मोबाईल नंबर (१० अंकी)',
                        prefixText: '+91 ',
                        suffixIcon: _otpSent
                            ? const Icon(Icons.check_circle_rounded,
                                color: AppColors.secondaryGreen)
                            : TextButton(
                                onPressed: () {
                                  if (_phoneController.text.length >= 10) {
                                    setState(() => _otpSent = true);
                                  }
                                },
                                child: Text(
                                  'OTP पाठवा',
                                  style: GoogleFonts.mukta(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                      ),
                    ),
                    if (_otpSent) ...[
                      const SizedBox(height: 14),
                      TextField(
                        controller: _otpController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'मिळालेला OTP टाका (Verification Code)',
                          hintText: 'उदा. 123456',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                        ),
                      ),
                    ],
                    const SizedBox(height: 14),
                    TextField(
                      controller: _addressController,
                      decoration: InputDecoration(
                        labelText: 'पत्ता व गाव (उदा. स्टेशन रोड, नरडाणा)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _descController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'तपशील / वर्णन',
                        hintText: 'सेवा किंवा वस्तूची अधिक माहिती द्या...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _submitListing,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'माहिती सबमिट करा (Submit Listing)',
                        style: GoogleFonts.mukta(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeTab(int index, String label) {
    final isSelected = _selectedPostType == index;

    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedPostType = index),
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
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
