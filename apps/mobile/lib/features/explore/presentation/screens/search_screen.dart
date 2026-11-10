import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:nardana_connect/core/constants/app_colors.dart';
import 'package:nardana_connect/core/localization/app_localizations.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  final List<Map<String, String>> _allDirectory = const [
    {
      'title': 'जय भवानी इलेक्ट्रिकल वर्क्स',
      'category': 'इलेक्ट्रिशियन',
      'owner': 'सचिन पाटील',
      'phone': '9823012345',
      'village': 'नरडाणा',
      'address': 'स्टेशन रोड, नरडाणा',
      'desc': 'घरगुती व शेती पंपाचे सर्व प्रकारचे वायरिंग व दुरुस्ती काम योग्य दरात करून मिळेल.',
      'opening_hours': 'सकाळी ९:०० ते रात्री ८:००',
    },
    {
      'title': 'महालक्ष्मी सुपर किराणा स्टोअर्स',
      'category': 'किराणा दुकान',
      'owner': 'प्रमोद महाजन',
      'phone': '9422054321',
      'village': 'नरडाणा',
      'address': 'मेन बाजारपेठ, नरडाणा',
      'desc': 'सर्व प्रकारचा दर्जेदार किराणा, कडधान्ये व घरगुती वस्तू वाजवी दरात उपलब्ध.',
      'opening_hours': 'सकाळी ७:०० ते रात्री ९:००',
    },
    {
      'title': 'धनवंतरी मेडिकल स्टोअर्स',
      'category': 'मेडिकल',
      'owner': 'डॉ. भूषण पाटील',
      'phone': '9890123456',
      'village': 'नरडाणा',
      'address': 'ग्रामीण रुग्णालयासमोर, नरडाणा',
      'desc': 'सर्व ॲलोपॅथिक, व्हेटरनरी व लहान मुलांची औषधे वाजवी दरात उपलब्ध.',
      'opening_hours': 'सकाळी ८:०० ते रात्री १०:००',
    },
    {
      'title': 'किसान ट्रॅक्टर सर्व्हिसेस',
      'category': 'ट्रॅक्टर भाड्याने',
      'owner': 'दिनेश चौधरी',
      'phone': '9765432100',
      'village': 'नरडाणा',
      'address': 'हायवे चौक, नरडाणा',
      'desc': 'नांगरणी, रोटाव्हेटर आणि पेरणीसाठी महिंद्रा ट्रॅक्टर वेळेवर उपलब्ध.',
      'opening_hours': '२४ तास सेवा',
    },
    {
      'title': 'आपले सरकार सेवा केंद्र व झेरॉक्स',
      'category': 'महा-ई-सेवा',
      'owner': 'योगेश पवार',
      'phone': '9970112233',
      'village': 'नरडाणा',
      'address': 'बस स्टँड जवळ, नरडाणा',
      'desc': '७/१२, ८-अ, आधार कार्ड, पॅन कार्ड, उत्पन्नाचा दाखला सर्व ऑनलाईन फॉर्म भरून मिळतील.',
      'opening_hours': 'सकाळी ९:०० ते संध्याकाळी ७:००',
    },
    {
      'title': 'गजानन सुतारकाम व फर्निचर',
      'category': 'सुतार / कारपेंटर',
      'owner': 'अमोल सुतार',
      'phone': '9822334455',
      'village': 'नरडाणा',
      'address': 'कुंभार गल्ली, नरडाणा',
      'desc': 'सर्व प्रकारचे लाकडी दरवाजे, खिडक्या व कपाट बनवणे व दुरुस्तीचे काम.',
      'opening_hours': 'सकाळी ८:३० ते संध्याकाळी ६:३०',
    },
    {
      'title': 'साई प्लंबिंग सर्व्हिसेस',
      'category': 'प्लंबर',
      'owner': 'कैलास माळी',
      'phone': '9421889900',
      'village': 'नरडाणा',
      'address': 'स्टेशन परिसर, नरडाणा',
      'desc': 'घरगुती व शेतातील पाईपलाईन लीकेज दुरुस्ती व नवीन नळ जोडणी.',
      'opening_hours': 'सकाळी ८:०० ते संध्याकाळी ८:००',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _call(String number) async {
    final uri = Uri.parse('tel:$number');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final results = _query.isEmpty
        ? _allDirectory
        : _allDirectory.where((item) {
            final q = _query.toLowerCase();
            return item['title']!.toLowerCase().contains(q) ||
                item['category']!.toLowerCase().contains(q) ||
                item['village']!.toLowerCase().contains(q);
          }).toList();

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          style: GoogleFonts.mukta(color: Colors.white, fontSize: 16),
          cursorColor: AppColors.accentYellow,
          decoration: InputDecoration(
            hintText: l10n.translate('search_hint'),
            hintStyle: GoogleFonts.mukta(color: Colors.white.withValues(alpha: 0.6)),
            border: InputBorder.none,
          ),
          onChanged: (val) {
            setState(() {
              _query = val;
            });
          },
        ),
        actions: [
          if (_query.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear_rounded, color: Colors.white),
              onPressed: () {
                _searchController.clear();
                setState(() => _query = '');
              },
            ),
        ],
      ),
      body: results.isEmpty
          ? Center(
              child: Text(
                'कोणतेही परिणाम सापडले नाहीत.',
                style: GoogleFonts.mukta(
                  fontSize: 15,
                  color: AppColors.textSecondary,
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: results.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final r = results[index];
                return Card(
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: const BorderSide(color: AppColors.border),
                  ),
                  child: ListTile(
                    onTap: () {
                      context.push('/business-detail', extra: {
                        'name_mr': r['title'],
                        'category': r['category'],
                        'owner': r['owner'],
                        'phone': r['phone'],
                        'village': r['village'],
                        'address': r['address'] ?? 'मुख्य बाजारपेठ, नरडाणा',
                        'desc': r['desc'] ?? 'विश्वसनीय स्थानिक सेवा',
                        'opening_hours': r['opening_hours'] ?? 'सकाळी ९:०० ते रात्री ८:००',
                      });
                    },
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.08),
                      child: const Icon(
                        Icons.store_rounded,
                        color: AppColors.primaryBlue,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      r['title']!,
                      style: GoogleFonts.mukta(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    subtitle: Text(
                      '${r['category']} • ${r['village']} (मालक: ${r['owner']})',
                      style: GoogleFonts.mukta(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.call_rounded, color: AppColors.primaryBlue),
                          tooltip: 'कॉल करा',
                          onPressed: () => _call(r['phone']!),
                        ),
                        const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted, size: 20),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
