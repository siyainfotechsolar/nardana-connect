import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nardana_connect/core/constants/app_colors.dart';
import 'package:nardana_connect/core/navigation/app_back_scope.dart';
import 'package:nardana_connect/core/navigation/back_button_handler.dart';
import '../../services/village_updates_service.dart';

class SubmitUpdateScreen extends StatefulWidget {
  const SubmitUpdateScreen({super.key});

  @override
  State<SubmitUpdateScreen> createState() => _SubmitUpdateScreenState();
}

class _SubmitUpdateScreenState extends State<SubmitUpdateScreen> {
  final _formKey = GlobalKey<FormState>();

  String _selectedCategory = 'kirtan_bhajan';
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  final _venueController = TextEditingController();
  final _organizerNameController = TextEditingController();
  final _organizerContactController = TextEditingController();
  final _posterUrlController = TextEditingController();

  bool _isSubmitting = false;

  final List<Map<String, String>> _categories = const [
    {'key': 'kirtan_bhajan', 'label': 'कीर्तन / भजन', 'icon': '🚩'},
    {'key': 'festival', 'label': 'ग्रामोत्सव व जत्रा', 'icon': '🎪'},
    {'key': 'cultural', 'label': 'सांस्कृतिक कार्यक्रम', 'icon': '🎭'},
    {'key': 'health_camp', 'label': 'आरोग्य शिबीर', 'icon': '🏥'},
    {'key': 'school_education', 'label': 'शाळा व शिक्षण प्रवेश', 'icon': '🏫'},
    {'key': 'shop_opening', 'label': 'दुकान / व्यवसाय उद्घाटन', 'icon': '🎉'},
    {'key': 'announcement', 'label': 'जाहीर सूचना व बैठका', 'icon': '📢'},
    {'key': 'village_news', 'label': 'गावच्या बातम्या', 'icon': '📰'},
    {'key': 'invitation', 'label': 'निमंत्रण सोहळा', 'icon': '💌'},
    {'key': 'advertisement', 'label': 'जाहिरात व प्रसिद्धी', 'icon': '🌟'},
    {'key': 'other', 'label': 'इतर घडामोडी', 'icon': '📌'},
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _venueController.dispose();
    _organizerNameController.dispose();
    _organizerContactController.dispose();
    _posterUrlController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now.subtract(const Duration(days: 30)),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) {
      final yyyy = picked.year.toString().padLeft(4, '0');
      final mm = picked.month.toString().padLeft(2, '0');
      final dd = picked.day.toString().padLeft(2, '0');
      setState(() {
        _dateController.text = '$yyyy-$mm-$dd';
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final success = await VillageUpdatesService.instance.submitUpdate(
      category: _selectedCategory,
      titleMr: _titleController.text.trim(),
      descriptionMr: _descriptionController.text.trim(),
      eventDate: _dateController.text.trim().isEmpty ? null : _dateController.text.trim(),
      eventTime: _timeController.text.trim().isEmpty ? null : _timeController.text.trim(),
      venueMr: _venueController.text.trim().isEmpty ? null : _venueController.text.trim(),
      organizerName: _organizerNameController.text.trim().isEmpty ? null : _organizerNameController.text.trim(),
      organizerContact: _organizerContactController.text.trim().isEmpty ? null : _organizerContactController.text.trim(),
      posterUrl: _posterUrlController.text.trim().isEmpty ? null : _posterUrlController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (success) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.green, size: 28),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'नोंदणी यशस्वी!',
                  style: GoogleFonts.mukta(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
            ],
          ),
          content: Text(
            'आपली घडामोड / निमंत्रण ॲडमिन मंजुरीसाठी पाठवण्यात आले आहे. पडताळणीनंतर हे सर्व नागरिकांना दिसेल.',
            style: GoogleFonts.mukta(fontSize: 14, height: 1.4),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                BackButtonHandler.safePop(context, fallbackRoute: '/village-updates');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text('ठीक आहे', style: GoogleFonts.mukta(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'नोंदणी पाठवताना त्रुटी आली. कृपया पुन्हा प्रयत्न करा.',
            style: GoogleFonts.mukta(),
          ),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBackScope(
      fallbackRoute: '/village-updates',
      child: Scaffold(
        backgroundColor: AppColors.surface,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => BackButtonHandler.safePop(context, fallbackRoute: '/village-updates'),
          ),
          title: Text(
            'नवीन घडामोड / निमंत्रण पाठवा',
            style: GoogleFonts.mukta(fontWeight: FontWeight.bold),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Info Box
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.info_outline_rounded, color: AppColors.primaryBlue, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'नरडाणा गावातील कोणताही कार्यक्रम, कीर्तन, आरोग्य शिबीर, दुकानाचे उद्घाटन किंवा जाहीर सूचना येथे नोंदवा. ॲडमिन मंजुरीनंतर ती प्रसिद्ध केली जाईल.',
                          style: GoogleFonts.mukta(fontSize: 12.5, color: Colors.blue.shade900, height: 1.35),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // Category Dropdown
                Text(
                  'कार्यक्रमाचा प्रकार / प्रवर्ग *',
                  style: GoogleFonts.mukta(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  initialValue: _selectedCategory,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  items: _categories.map((cat) {
                    return DropdownMenuItem<String>(
                      value: cat['key'],
                      child: Text(
                        '${cat['icon']} ${cat['label']}',
                        style: GoogleFonts.mukta(fontSize: 14),
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedCategory = val);
                  },
                ),

                const SizedBox(height: 14),

                // Title Input
                Text(
                  'कार्यक्रमाचे नाव / शीर्षक *',
                  style: GoogleFonts.mukta(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    hintText: 'उदा. अखंड हरिनाम सप्ताह, मोफत आरोग्य शिबीर...',
                    hintStyle: GoogleFonts.mukta(color: Colors.grey.shade400, fontSize: 13),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'कृपया कार्यक्रमाचे नाव टाका';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 14),

                // Description Input
                Text(
                  'सविस्तर माहिती / तपशील *',
                  style: GoogleFonts.mukta(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'कार्यक्रमाबद्दल सविस्तर माहिती, वेळ, वैशिष्ट्ये व गावकऱ्यांना निमंत्रण...',
                    hintStyle: GoogleFonts.mukta(color: Colors.grey.shade400, fontSize: 13),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'कृपया सविस्तर माहिती टाका';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 14),

                // Date & Time Row
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('दिनांक (Date)', style: GoogleFonts.mukta(fontWeight: FontWeight.bold, fontSize: 14)),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _dateController,
                            readOnly: true,
                            onTap: _pickDate,
                            decoration: InputDecoration(
                              hintText: 'YYYY-MM-DD',
                              hintStyle: GoogleFonts.mukta(color: Colors.grey.shade400, fontSize: 13),
                              suffixIcon: const Icon(Icons.calendar_today_rounded, size: 18),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('वेळ (Time)', style: GoogleFonts.mukta(fontWeight: FontWeight.bold, fontSize: 14)),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _timeController,
                            decoration: InputDecoration(
                              hintText: 'उदा. सायं. ६:०० वाजता',
                              hintStyle: GoogleFonts.mukta(color: Colors.grey.shade400, fontSize: 13),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Venue Input
                Text(
                  'स्थळ / ठिकाण (Venue)',
                  style: GoogleFonts.mukta(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _venueController,
                  decoration: InputDecoration(
                    hintText: 'उदा. श्री विठ्ठल मंदिर प्रांगण, नरडाणा',
                    hintStyle: GoogleFonts.mukta(color: Colors.grey.shade400, fontSize: 13),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),

                const SizedBox(height: 14),

                // Organizer Name & Phone
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('आयोजकाचे नाव', style: GoogleFonts.mukta(fontWeight: FontWeight.bold, fontSize: 14)),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _organizerNameController,
                            decoration: InputDecoration(
                              hintText: 'उदा. उत्सव समिती / नागरिक',
                              hintStyle: GoogleFonts.mukta(color: Colors.grey.shade400, fontSize: 13),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('संपर्क मोबाईल', style: GoogleFonts.mukta(fontWeight: FontWeight.bold, fontSize: 14)),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _organizerContactController,
                            keyboardType: TextInputType.phone,
                            maxLength: 10,
                            decoration: InputDecoration(
                              counterText: '',
                              hintText: '१० अंकी मोबाईल नंबर',
                              hintStyle: GoogleFonts.mukta(color: Colors.grey.shade400, fontSize: 13),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Poster URL (Optional)
                Text(
                  'पोस्टर / फोटो लिंक (ऐच्छिक)',
                  style: GoogleFonts.mukta(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _posterUrlController,
                  decoration: InputDecoration(
                    hintText: 'https://... (इमेज किंवा पोस्टर लिंक)',
                    hintStyle: GoogleFonts.mukta(color: Colors.grey.shade400, fontSize: 13),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),

                const SizedBox(height: 24),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : Text(
                            'घडामोड पाठवा (मंजुरीसाठी)',
                            style: GoogleFonts.mukta(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

