import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nardana_connect/core/constants/app_colors.dart';
import 'package:nardana_connect/core/navigation/app_back_scope.dart';
import 'package:nardana_connect/features/vehicles/models/vehicle_listing_model.dart';
import 'package:nardana_connect/features/vehicles/services/vehicle_service.dart';

class SubmitVehicleScreen extends StatefulWidget {
  const SubmitVehicleScreen({super.key});

  @override
  State<SubmitVehicleScreen> createState() => _SubmitVehicleScreenState();
}

class _SubmitVehicleScreenState extends State<SubmitVehicleScreen> {
  final _formKey = GlobalKey<FormState>();

  final _driverNameCtrl = TextEditingController();
  final _modelCtrl = TextEditingController();
  final _numberCtrl = TextEditingController();
  final _seatingCtrl = TextEditingController();
  final _loadCtrl = TextEditingController();
  final _rateCtrl = TextEditingController();
  final _contactCtrl = TextEditingController();
  final _whatsappCtrl = TextEditingController();
  final _locationCtrl = TextEditingController(text: 'नरडाणा');
  final _photoUrlCtrl = TextEditingController();

  String _selectedCategory = 'अर्टिगा (७ सीटर)';
  bool _acAvailable = false;
  bool _consentGiven = false;
  bool _isSubmitting = false;

  final List<String> _categoryOptions = [
    'कार',
    'टॅक्सी',
    'अर्टिगा (७ सीटर)',
    'इनोव्हा',
    'पिकअप / छोटा हत्ती',
    'टेम्पो',
    'ट्रॅक्टर',
    'जेसीबी (JCB)',
    'ट्रक',
    'बस / ट्रॅव्हलर',
    'इतर वाहने',
  ];

  @override
  void dispose() {
    _driverNameCtrl.dispose();
    _modelCtrl.dispose();
    _numberCtrl.dispose();
    _seatingCtrl.dispose();
    _loadCtrl.dispose();
    _rateCtrl.dispose();
    _contactCtrl.dispose();
    _whatsappCtrl.dispose();
    _locationCtrl.dispose();
    _photoUrlCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_consentGiven) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'कृपया संपर्क माहिती प्रदर्शित करण्यासाठी संमती बॉक्सवर टिक करा.',
            style: GoogleFonts.mukta(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.red.shade700,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final listing = VehicleListingModel(
      id: '',
      driverName: _driverNameCtrl.text.trim(),
      vehicleType: _selectedCategory,
      vehicleModel: _modelCtrl.text.trim(),
      vehicleNumber: _numberCtrl.text.trim().isEmpty ? null : _numberCtrl.text.trim(),
      seatingCapacity: int.tryParse(_seatingCtrl.text.trim()),
      loadCapacity: _loadCtrl.text.trim().isEmpty ? null : _loadCtrl.text.trim(),
      acAvailable: _acAvailable,
      rentalRateOptional: _rateCtrl.text.trim().isEmpty ? null : _rateCtrl.text.trim(),
      contactNumber: _contactCtrl.text.trim(),
      whatsappNumber: _whatsappCtrl.text.trim().isEmpty ? _contactCtrl.text.trim() : _whatsappCtrl.text.trim(),
      locationText: _locationCtrl.text.trim().isEmpty ? 'नरडाणा' : _locationCtrl.text.trim(),
      photoUrl: _photoUrlCtrl.text.trim().isEmpty ? null : _photoUrlCtrl.text.trim(),
      availabilityStatus: 'available',
      approvalStatus: 'pending', // Awaiting Admin verification
      verificationStatus: 'unverified',
      isActive: true,
    );

    final success = await VehicleService.instance.submitListing(listing);

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (success) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: AppColors.secondaryGreen, size: 28),
                const SizedBox(width: 8),
                Text('नोंदणी यशस्वी!', style: GoogleFonts.mukta(fontWeight: FontWeight.bold)),
              ],
            ),
            content: Text(
              'आपल्या गाडीची माहिती ॲडमिनकडे पडताळणीसाठी पाठवली आहे. सुरक्षेसाठी व खातरजमा झाल्यावर ही नोंद ॲपमध्ये सर्वांना दिसेल.\n\nधन्यवाद!',
              style: GoogleFonts.mukta(fontSize: 14, height: 1.5),
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  context.pop(true);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text('समजले', style: GoogleFonts.mukta(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'नोंदणी जतन करताना त्रुटी आली. कृपया इंटरनेट तपासून पुन्हा प्रयत्न करा.',
              style: GoogleFonts.mukta(),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBackScope(
      fallbackRoute: '/vehicles',
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F8FA),
        appBar: AppBar(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/vehicles');
              }
            },
          ),
          title: Text(
            'आपली गाडी नोंदवा (Add Vehicle)',
            style: GoogleFonts.mukta(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Notice banner
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
                    const Icon(Icons.privacy_tip_outlined, size: 20, color: Color(0xFFB45309)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'केवळ नरडाणा गाव (पिन ४२५४०४) मधील चालक व मालकांसाठी. गाडी क्रमांक सुरक्षेसाठी गोपनीय ठेवला जातो.',
                        style: GoogleFonts.mukta(fontSize: 12, color: const Color(0xFF78350F)),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Card 1: Vehicle & Driver Info
              _buildFormSection(
                title: '१. चालक व गाडीची प्राथमिक माहिती',
                children: [
                  // Driver Name
                  TextFormField(
                    controller: _driverNameCtrl,
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'कृपया चालक / मालकाचे नाव प्रविष्ट करा' : null,
                    decoration: _inputDeco(
                      label: 'चालक / मालकाचे पूर्ण नाव *',
                      hint: 'उदा. कैलास निवृत्ती पाटील',
                      icon: Icons.person_rounded,
                    ),
                    style: GoogleFonts.mukta(fontSize: 14),
                  ),
                  const SizedBox(height: 14),

                  // Category Selector Dropdown
                  DropdownButtonFormField<String>(
                    initialValue: _selectedCategory,
                    items: _categoryOptions
                        .map((c) => DropdownMenuItem(value: c, child: Text(c, style: GoogleFonts.mukta(fontSize: 14))))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedCategory = val);
                    },
                    decoration: _inputDeco(
                      label: 'वाहन प्रकार (Category) *',
                      hint: 'वाहन प्रकार निवडा',
                      icon: Icons.category_rounded,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Vehicle Model
                  TextFormField(
                    controller: _modelCtrl,
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'कृपया गाडीचे मॉडेल प्रविष्ट करा' : null,
                    decoration: _inputDeco(
                      label: 'गाडीचे नाव / मॉडेल *',
                      hint: 'उदा. Maruti Ertiga VXi / Mahindra Bolero',
                      icon: Icons.directions_car_rounded,
                    ),
                    style: GoogleFonts.mukta(fontSize: 14),
                  ),
                  const SizedBox(height: 14),

                  // Vehicle Number (Optional / Private)
                  TextFormField(
                    controller: _numberCtrl,
                    decoration: _inputDeco(
                      label: 'गाडी क्रमांक (गोपनीय / ॲडमिनसाठी)',
                      hint: 'उदा. MH 18 BX 4412',
                      icon: Icons.numbers_rounded,
                    ),
                    style: GoogleFonts.mukta(fontSize: 14),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Card 2: Capacity & Specifications
              _buildFormSection(
                title: '२. बैठक / वजन क्षमता व दर',
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _seatingCtrl,
                          keyboardType: TextInputType.number,
                          decoration: _inputDeco(
                            label: 'बैठक क्षमता (व्यक्ती)',
                            hint: 'उदा. ७',
                            icon: Icons.event_seat_rounded,
                          ),
                          style: GoogleFonts.mukta(fontSize: 14),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _loadCtrl,
                          decoration: _inputDeco(
                            label: 'वजन क्षमता',
                            hint: 'उदा. १.५ टन',
                            icon: Icons.line_weight_rounded,
                          ),
                          style: GoogleFonts.mukta(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // AC Switch
                  SwitchListTile(
                    value: _acAvailable,
                    onChanged: (v) => setState(() => _acAvailable = v),
                    title: Text('वातानुकूलित (AC उपलब्ध)', style: GoogleFonts.mukta(fontSize: 14, fontWeight: FontWeight.w600)),
                    subtitle: Text('गाडीत वातानुकूलन यंत्रणा (AC) चालू आहे का?', style: GoogleFonts.mukta(fontSize: 12, color: Colors.blueGrey)),
                    activeThumbColor: AppColors.primaryBlue,
                    contentPadding: EdgeInsets.zero,
                  ),
                  const Divider(height: 12),

                  // Rental Rate (Optional)
                  TextFormField(
                    controller: _rateCtrl,
                    decoration: _inputDeco(
                      label: 'अंदाजे भाडे / दर (ऐच्छिक)',
                      hint: 'उदा. ₹१२/किमी किंवा स्थानिक दरानुसार',
                      icon: Icons.currency_rupee_rounded,
                    ),
                    style: GoogleFonts.mukta(fontSize: 14),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Card 3: Contact Details & Location
              _buildFormSection(
                title: '३. संपर्क क्रमांक व नरडाणा पत्ता',
                children: [
                  TextFormField(
                    controller: _contactCtrl,
                    keyboardType: TextInputType.phone,
                    maxLength: 10,
                    validator: (v) {
                      if (v == null || v.trim().length != 10) {
                        return '१० अंकी मोबाईल नंबर प्रविष्ट करा';
                      }
                      return null;
                    },
                    decoration: _inputDeco(
                      label: 'कॉलसाठी मोबाईल नंबर *',
                      hint: '९४२१८८९९०१',
                      icon: Icons.phone_rounded,
                    ),
                    style: GoogleFonts.mukta(fontSize: 14),
                  ),
                  const SizedBox(height: 10),

                  TextFormField(
                    controller: _whatsappCtrl,
                    keyboardType: TextInputType.phone,
                    maxLength: 10,
                    decoration: _inputDeco(
                      label: 'WhatsApp नंबर (मोबाईल नंबरसारखाच असल्यास रिकामा ठेवा)',
                      hint: '९४२१८८९९०१',
                      icon: Icons.chat_rounded,
                    ),
                    style: GoogleFonts.mukta(fontSize: 14),
                  ),
                  const SizedBox(height: 10),

                  TextFormField(
                    controller: _locationCtrl,
                    decoration: _inputDeco(
                      label: 'गाडी थांबण्याचे ठिकाण (नरडाणा) *',
                      hint: 'उदा. स्टेशन परिसर, हायवे चौक, मेन बाजारपेठ',
                      icon: Icons.location_on_rounded,
                    ),
                    style: GoogleFonts.mukta(fontSize: 14),
                  ),
                  const SizedBox(height: 14),

                  TextFormField(
                    controller: _photoUrlCtrl,
                    decoration: _inputDeco(
                      label: 'गाडीचा फोटो लिंक / URL (ऐच्छिक)',
                      hint: 'https://...',
                      icon: Icons.image_rounded,
                    ),
                    style: GoogleFonts.mukta(fontSize: 14),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Card 4: Consent
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: CheckboxListTile(
                  value: _consentGiven,
                  onChanged: (v) => setState(() => _consentGiven = v ?? false),
                  contentPadding: EdgeInsets.zero,
                  activeColor: AppColors.primaryBlue,
                  title: Text(
                    'मी नरडाणा येथील रहिवासी असून, ॲपमध्ये माझा संपर्क क्रमांक व गाडीची माहिती नागरिकांच्या सोयीसाठी प्रदर्शित करण्यास माझी पूर्ण संमती आहे.',
                    style: GoogleFonts.mukta(fontSize: 12.5, fontWeight: FontWeight.w600, color: const Color(0xFF1E293B)),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 1,
                  ),
                  child: _isSubmitting
                      ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                      : Text(
                          'गाडीची माहिती नोंदवा (Submit)',
                          style: GoogleFonts.mukta(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormSection({required String title, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.mukta(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  InputDecoration _inputDeco({
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.mukta(fontSize: 13, color: Colors.blueGrey),
      hintText: hint,
      hintStyle: GoogleFonts.mukta(fontSize: 12.5, color: Colors.grey.shade400),
      prefixIcon: Icon(icon, size: 20, color: AppColors.primaryBlue),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.primaryBlue, width: 1.5)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      isDense: true,
    );
  }
}
