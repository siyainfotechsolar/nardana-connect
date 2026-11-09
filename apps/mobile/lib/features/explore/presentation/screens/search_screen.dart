import 'package:flutter/material.dart';
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
    },
    {
      'title': 'महालक्ष्मी सुपर किराणा स्टोअर्स',
      'category': 'किराणा दुकान',
      'owner': 'प्रमोद महाजन',
      'phone': '9422054321',
      'village': 'नरडाणा',
    },
    {
      'title': 'धनवंतरी मेडिकल स्टोअर्स',
      'category': 'मेडिकल',
      'owner': 'डॉ. भूषण पाटील',
      'phone': '9890123456',
      'village': 'नरडाणा',
    },
    {
      'title': 'किसान ट्रॅक्टर सर्व्हिसेस',
      'category': 'ट्रॅक्टर भाड्याने',
      'owner': 'दिनेश चौधरी',
      'phone': '9765432100',
      'village': 'नरडाणा',
    },
    {
      'title': 'आपले सरकार सेवा केंद्र व झेरॉक्स',
      'category': 'महा-ई-सेवा',
      'owner': 'योगेश पवार',
      'phone': '9970112233',
      'village': 'नरडाणा',
    },
    {
      'title': 'गजानन सुतारकाम व फर्निचर',
      'category': 'सुतार / कारपेंटर',
      'owner': 'अमोल सुतार',
      'phone': '9822334455',
      'village': 'वाघाळी',
    },
    {
      'title': 'साई प्लंबिंग सर्व्हिसेस',
      'category': 'प्लंबर',
      'owner': 'कैलास माळी',
      'phone': '9421889900',
      'village': 'होळ',
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
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.08),
                      child: const Icon(Icons.store_rounded,
                          color: AppColors.primaryBlue, size: 20),
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
                    trailing: IconButton(
                      icon: const Icon(Icons.call_rounded,
                          color: AppColors.primaryBlue),
                      onPressed: () => _call(r['phone']!),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
