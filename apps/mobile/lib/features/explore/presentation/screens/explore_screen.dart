import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nardana_connect/core/constants/app_colors.dart';
import 'package:nardana_connect/core/localization/app_localizations.dart';
import 'package:nardana_connect/core/services/supabase_service.dart';
import 'package:nardana_connect/features/advertisements/presentation/widgets/sponsored_ad_card.dart';
import 'package:nardana_connect/features/advertisements/providers/advertisement_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  String _selectedGroup = 'all';
  List<Map<String, dynamic>> _businesses = [];
  bool _isLoading = true;

  final List<Map<String, dynamic>> _fallbackServices = const [
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
      'opening_hours': 'सकाळी ९:०० ते रात्री ८:००',
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
      'opening_hours': 'सकाळी ७:०० ते रात्री ९:००',
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
      'address': 'हायवे चौक, नरडाणा',
      'desc': 'नांगरणी, रोटाव्हेटर आणि पेरणीसाठी महिंद्रा ट्रॅक्टर वेळेवर उपलब्ध.',
      'opening_hours': '२४ तास सेवा',
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
      'desc': 'सर्व ॲलोपॅथिक, व्हेटरनरी व लहान मुलांची औषधे वाजवी दरात उपलब्ध.',
      'opening_hours': 'सकाळी ८:०० ते रात्री १०:००',
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
      'opening_hours': 'सकाळी ९:०० ते संध्याकाळी ७:००',
      'group': 'digital',
    },
    {
      'id': '6',
      'name_mr': 'गजानन सुतारकाम व फर्निचर',
      'name_en': 'Gajanan Carpentry & Furniture',
      'category': 'सुतारकाम / कारपेंटर',
      'owner': 'अमोल सुतार',
      'phone': '9822334455',
      'whatsapp': '9822334455',
      'village': 'नरडाणा',
      'address': 'कुंभार गल्ली, नरडाणा',
      'desc': 'सर्व प्रकारचे लाकडी दरवाजे, खिडक्या व कपाट बनवणे व दुरुस्तीचे काम.',
      'opening_hours': 'सकाळी ८:३० ते संध्याकाळी ६:३०',
      'group': 'home_services',
    },
    {
      'id': '7',
      'name_mr': 'साई प्लंबिंग सर्व्हिसेस',
      'name_en': 'Sai Plumbing Services',
      'category': 'प्लंबर व पाणी फिटिंग',
      'owner': 'कैलास माळी',
      'phone': '9421889900',
      'whatsapp': '9421889900',
      'village': 'नरडाणा',
      'address': 'स्टेशन परिसर, नरडाणा',
      'desc': 'घरगुती व शेतातील पाईपलाईन लीकेज दुरुस्ती व नवीन नळ जोडणी.',
      'opening_hours': 'सकाळी ८:०० ते संध्याकाळी ८:००',
      'group': 'home_services',
    },
  ];

  @override
  void initState() {
    super.initState();
    _fetchBusinesses();
  }

  Future<void> _fetchBusinesses() async {
    try {
      final res = await SupabaseService.client
          .from('businesses')
          .select('*, villages(name_mr), categories(name_mr, group_type)')
          .eq('status', 'approved')
          .order('created_at', ascending: false);

      if (res.isNotEmpty) {
        final List<Map<String, dynamic>> mapped = (res as List).map((row) {
          final vil = row['villages'] != null ? row['villages']['name_mr'] : 'नरडाणा';
          final cat = row['categories'] != null ? row['categories']['name_mr'] : 'सेवा';
          final grp = row['categories'] != null ? row['categories']['group_type'] : 'home_services';

          return {
            'id': row['id'],
            'name_mr': row['business_name_mr'] ?? '',
            'name_en': row['business_name_en'] ?? '',
            'category': cat,
            'owner': row['owner_name'] ?? '',
            'phone': row['phone'] ?? '',
            'whatsapp': row['whatsapp'] ?? row['phone'] ?? '',
            'village': vil,
            'address': row['address'] ?? '',
            'desc': row['description'] ?? '',
            'opening_hours': row['opening_hours'] ?? 'सकाळी ९:०० ते रात्री ८:००',
            'group': grp,
          };
        }).toList();

        setState(() {
          _businesses = mapped;
          _isLoading = false;
        });
        return;
      }
    } catch (e) {
      // Fallback gracefully
    }

    setState(() {
      _businesses = _fallbackServices;
      _isLoading = false;
    });
  }

  Future<void> _call(String number) async {
    final uri = Uri.parse('tel:$number');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _openWhatsApp(String number, String name) async {
    final cleanNum = number.replaceAll(RegExp(r'\D'), '');
    final fullNum = cleanNum.startsWith('91') ? cleanNum : '91$cleanNum';
    final msg = Uri.encodeComponent('नमस्कार $name, मी नरडाणा कनेक्ट ॲपवरून संपर्क करत आहे.');
    final uri = Uri.parse('https://wa.me/$fullNum?text=$msg');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  void _openDetails(Map<String, dynamic> item) {
    context.push('/business-detail', extra: item);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final filtered = _selectedGroup == 'all'
        ? _businesses
        : _businesses.where((s) {
            final grp = s['group'] ?? '';
            if (_selectedGroup == 'shops') return grp == 'shops' || grp == 'दुकाने';
            if (_selectedGroup == 'home_services') return grp == 'home_services' || grp == 'services' || grp == 'सेवा';
            if (_selectedGroup == 'agriculture') return grp == 'agriculture' || grp == 'शेती';
            if (_selectedGroup == 'health') return grp == 'health' || grp == 'आरोग्य';
            if (_selectedGroup == 'digital') return grp == 'digital' || grp == 'education';
            return grp == _selectedGroup;
          }).toList();

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text(
          'स्थानिक व्यवसाय व सेवा',
          style: GoogleFonts.mukta(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            tooltip: 'शोधा',
            onPressed: () => context.push('/search'),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Container(
            color: Colors.white,
            height: 56,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              children: [
                _buildFilterChip('all', 'सर्व सेवा (${_businesses.length})'),
                _buildFilterChip('shops', 'दुकाने'),
                _buildFilterChip('home_services', 'घरगुती सेवा'),
                _buildFilterChip('agriculture', 'शेती व कृषी'),
                _buildFilterChip('health', 'आरोग्य व मेडिकल'),
                _buildFilterChip('digital', 'डिजिटल सेवा'),
              ],
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Category-specific Advertisement Banner
                Consumer(
                  builder: (context, ref, child) {
                    final catAdsAsync = ref.watch(categoryAdsProvider(null));
                    return catAdsAsync.when(
                      data: (ads) {
                        if (ads.isEmpty) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                          child: SponsoredAdCard(ad: ads.first),
                        );
                      },
                      loading: () => const SizedBox.shrink(),
                      error: (e, s) => const SizedBox.shrink(),
                    );
                  },
                ),
                Expanded(
                  child: filtered.isEmpty
                      ? Center(
                          child: Text(
                            'या प्रवर्गात सध्या व्यवसाय उपलब्ध नाहीत.',
                            style: GoogleFonts.mukta(color: AppColors.textSecondary, fontSize: 14),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: filtered.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                    final s = filtered[index];
                    return Card(
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(color: AppColors.border),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () => _openDetails(s),
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
                                    child: const Icon(
                                      Icons.storefront_rounded,
                                      color: AppColors.primaryBlue,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          s['name_mr'] ?? '',
                                          style: GoogleFonts.mukta(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.textPrimary,
                                            height: 1.2,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          s['category'] ?? '',
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
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryBlue.withValues(alpha: 0.08),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.location_on_rounded, size: 11, color: AppColors.primaryBlue),
                                        const SizedBox(width: 2),
                                        Text(
                                          s['village'] ?? '',
                                          style: GoogleFonts.mukta(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primaryBlue,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              if (s['desc'] != null && (s['desc'] as String).isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Text(
                                  s['desc'],
                                  style: GoogleFonts.mukta(
                                    fontSize: 13,
                                    color: AppColors.textSecondary,
                                    height: 1.35,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textMuted),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      s['address'] ?? '',
                                      style: GoogleFonts.mukta(
                                        fontSize: 12,
                                        color: AppColors.textMuted,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Text(
                                    'तपशील पहा →',
                                    style: GoogleFonts.mukta(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primaryBlue,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () => _call(s['phone'] ?? ''),
                                      icon: const Icon(Icons.call_rounded, size: 16),
                                      label: Text(l10n.translate('call_now')),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primaryBlue,
                                        foregroundColor: Colors.white,
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
                                      onPressed: () => _openWhatsApp(s['whatsapp'] ?? s['phone'] ?? '', s['name_mr'] ?? ''),
                                      icon: const Icon(Icons.chat_rounded, size: 16, color: AppColors.secondaryGreen),
                                      label: Text(
                                        l10n.translate('whatsapp'),
                                        style: GoogleFonts.mukta(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.secondaryGreen,
                                        ),
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(color: AppColors.secondaryGreen),
                                        padding: const EdgeInsets.symmetric(vertical: 8),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildFilterChip(String key, String label) {
    final isSelected = _selectedGroup == key;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        selected: isSelected,
        label: Text(label),
        labelStyle: GoogleFonts.mukta(
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Colors.white : AppColors.textPrimary,
        ),
        backgroundColor: Colors.grey.shade100,
        selectedColor: AppColors.primaryBlue,
        checkmarkColor: Colors.white,
        showCheckmark: false,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected ? AppColors.primaryBlue : Colors.grey.shade300,
          ),
        ),
        onSelected: (val) {
          setState(() {
            _selectedGroup = key;
          });
        },
      ),
    );
  }
}
