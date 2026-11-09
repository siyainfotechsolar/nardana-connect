import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nardana_connect/core/constants/app_colors.dart';
import 'package:nardana_connect/core/localization/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  String _selectedGroup = 'all';

  final List<Map<String, dynamic>> _sampleServices = const [
    {
      'id': '1',
      'name_mr': 'जय भवानी इलेक्ट्रिकल वर्क्स',
      'name_en': 'Jai Bhavani Electrical Works',
      'category': 'इलेक्ट्रिशियन',
      'owner': 'सचिन पाटील',
      'phone': '9823012345',
      'whatsapp': '9823012345',
      'village': 'नरडाणा',
      'address': 'स्टेशन रोड, नरडाणा',
      'desc': 'घरगुती व शेती पंपाचे सर्व प्रकारचे वायरिंग व दुरुस्ती काम योग्य दरात करून मिळेल.',
      'group': 'home_services',
    },
    {
      'id': '2',
      'name_mr': 'महालक्ष्मी सुपर किराणा स्टोअर्स',
      'name_en': 'Mahalaxmi Super Grocery',
      'category': 'किराणा दुकान',
      'owner': 'प्रमोद महाजन',
      'phone': '9422054321',
      'whatsapp': '9422054321',
      'village': 'नरडाणा',
      'address': 'मेन बाजारपेठ, नरडाणा',
      'desc': 'सर्व प्रकारचा दर्जेदार किराणा, कडधान्ये व घरगुती वस्तू वाजवी दरात उपलब्ध.',
      'group': 'shops',
    },
    {
      'id': '3',
      'name_mr': 'किसान ट्रॅक्टर सर्व्हिसेस',
      'name_en': 'Kisan Tractor Services',
      'category': 'ट्रॅक्टर भाड्याने',
      'owner': 'दिनेश चौधरी',
      'phone': '9765432100',
      'whatsapp': '9765432100',
      'village': 'नरडाणा',
      'address': 'वाघाळी फाटा, नरडाणा',
      'desc': 'नांगरणी, रोटाव्हेटर आणि पेरणीसाठी महिंद्रा ट्रॅक्टर वेळेवर उपलब्ध.',
      'group': 'agriculture',
    },
    {
      'id': '4',
      'name_mr': 'धनवंतरी मेडिकल स्टोअर्स',
      'name_en': 'Dhanvantari Medical Stores',
      'category': 'मेडिकल स्टोअर्स',
      'owner': 'डॉ. भूषण पाटील',
      'phone': '9890123456',
      'whatsapp': '9890123456',
      'village': 'नरडाणा',
      'address': 'ग्रामीण रुग्णालयासमोर, नरडाणा',
      'desc': 'सर्व ॲलोपॅथिक व व्हेटरनरी औषधे उपलब्ध.',
      'group': 'health',
    },
    {
      'id': '5',
      'name_mr': 'आपले सरकार सेवा केंद्र व झेरॉक्स',
      'name_en': 'Aaple Sarkar Seva Kendra',
      'category': 'महा-ई-सेवा व झेरॉक्स',
      'owner': 'योगेश पवार',
      'phone': '9970112233',
      'whatsapp': '9970112233',
      'village': 'नरडाणा',
      'address': 'बस स्टँड जवळ, नरडाणा',
      'desc': '७/१२, ८-अ, आधार कार्ड, पॅन कार्ड, उत्पन्नाचा दाखला सर्व ऑनलाईन फॉर्म भरून मिळतील.',
      'group': 'digital',
    },
  ];

  Future<void> _call(String number) async {
    final uri = Uri.parse('tel:$number');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _openWhatsApp(String number) async {
    final cleanNum = number.replaceAll(RegExp(r'\D'), '');
    final fullNum = cleanNum.startsWith('91') ? cleanNum : '91$cleanNum';
    final uri = Uri.parse('https://wa.me/$fullNum');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final filtered = _selectedGroup == 'all'
        ? _sampleServices
        : _sampleServices.where((s) => s['group'] == _selectedGroup).toList();

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text(l10n.translate('categories')),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Container(
            color: Colors.white,
            height: 56,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              children: [
                _buildFilterChip('all', 'सर्व सेवा (All)'),
                _buildFilterChip('home_services', 'घरगुती सेवा'),
                _buildFilterChip('shops', 'दुकाने'),
                _buildFilterChip('agriculture', 'शेती व कृषी'),
                _buildFilterChip('transport', 'वाहतूक'),
                _buildFilterChip('health', 'आरोग्य'),
                _buildFilterChip('digital', 'डिजिटल व सायबर'),
              ],
            ),
          ),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: filtered.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final s = filtered[index];
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.08),
                        child: const Icon(Icons.store_rounded,
                            color: AppColors.primaryBlue, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              s['name_mr'],
                              style: GoogleFonts.mukta(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              s['category'],
                              style: GoogleFonts.mukta(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.secondaryGreen,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          s['village'],
                          style: GoogleFonts.mukta(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    s['desc'],
                    style: GoogleFonts.mukta(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 14, color: AppColors.textMuted),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          s['address'],
                          style: GoogleFonts.mukta(
                            fontSize: 12,
                            color: AppColors.textMuted,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _call(s['phone']),
                          icon: const Icon(Icons.call_rounded, size: 16),
                          label: Text(l10n.translate('call_now')),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBlue,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            textStyle: GoogleFonts.mukta(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _openWhatsApp(s['whatsapp']),
                          icon: const Icon(Icons.chat_rounded,
                              size: 16, color: AppColors.secondaryGreen),
                          label: Text(
                            l10n.translate('whatsapp'),
                            style: GoogleFonts.mukta(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.secondaryGreen,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                                color: AppColors.secondaryGreen),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterChip(String group, String title) {
    final isSelected = _selectedGroup == group;

    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        selected: isSelected,
        label: Text(title),
        labelStyle: GoogleFonts.mukta(
          fontSize: 13,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          color: isSelected ? Colors.white : AppColors.textPrimary,
        ),
        backgroundColor: Colors.white,
        selectedColor: AppColors.primaryBlue,
        showCheckmark: false,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected ? AppColors.primaryBlue : AppColors.border,
          ),
        ),
        onSelected: (val) {
          setState(() {
            _selectedGroup = group;
          });
        },
      ),
    );
  }
}
