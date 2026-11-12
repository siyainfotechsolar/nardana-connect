import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nardana_connect/core/constants/app_colors.dart';
import 'package:nardana_connect/core/navigation/app_back_scope.dart';
import 'package:nardana_connect/core/services/supabase_service.dart';

class ElectionScreen extends StatefulWidget {
  const ElectionScreen({super.key});

  @override
  State<ElectionScreen> createState() => _ElectionScreenState();
}

class _ElectionScreenState extends State<ElectionScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _candidates = [];
  bool _isLoading = true;

  final List<Map<String, dynamic>> _fallbackCandidates = const [
    {
      'id': '1',
      'name': 'दिलीप आनंदा पाटील',
      'ward': 'प्रभाग क्र. १ (स्टेशन परिसर)',
      'symbol': 'कमळ / चिन्ह अ',
      'education': 'बी.ए. (B.A.)',
      'age': '४६ वर्ष',
      'agenda': 'नरडाणा गावातील पाणी पुरवठा योजना नियमित करणे व नवीन सिमेंट रस्ते बांधणे.',
      'phone': '9822011223',
    },
    {
      'id': '2',
      'name': 'अनिता सुनील चौधरी',
      'ward': 'प्रभाग क्र. २ (मेन बाजारपेठ)',
      'symbol': 'शिट्टी / चिन्ह ब',
      'education': '१२ वी उत्तीर्ण',
      'age': '३८ वर्ष',
      'agenda': 'महिला बचत गटांना बळकटी देणे आणि प्राथमिक आरोग्य केंद्रात २४ तास रुग्णवाहिका सेवा सुरू करणे.',
      'phone': '9421556677',
    },
    {
      'id': '3',
      'name': 'सुरेश काशिनाथ माळी',
      'ward': 'प्रभाग क्र. ३ (हायवे परिसर)',
      'symbol': 'विमान / चिन्ह क',
      'education': 'डी.एड. (D.Ed.)',
      'age': '५२ वर्ष',
      'agenda': 'गावातील सांडपाणी व्यवस्थापन, कचरा व्यवस्थापन व शेतकरी सेवा केंद्र सक्षम करणे.',
      'phone': '9890887766',
    },
  ];

  final List<Map<String, dynamic>> _wards = const [
    {'ward': 'प्रभाग १', 'name': 'स्टेशन परिसर व जुने गाव', 'voters': '१,२५०', 'res': 'खुला (General)'},
    {'ward': 'प्रभाग २', 'name': 'मेन बाजारपेठ व कुंभार गल्ली', 'voters': '१,४२०', 'res': 'नागरिकांचा मागास प्रवर्ग (OBC)'},
    {'ward': 'प्रभाग ३', 'name': 'हायवे परिसर व नवीन वसाहत', 'voters': '१,१८०', 'res': 'महिला (खुला - Women)'},
    {'ward': 'प्रभाग ४', 'name': 'पाटील गल्ली व माळी गल्ली', 'voters': '१,३१०', 'res': 'अनुसूचित जमाती (ST)'},
    {'ward': 'प्रभाग ५', 'name': 'ग्रामपंचायत चौक व शाळा परिसर', 'voters': '१,२९०', 'res': 'महिला (मागास प्रवर्ग)'},
  ];

  final List<Map<String, String>> _schedule = const [
    {'date': '२५ नोव्हेंबर २०२६', 'title': 'नामनिर्देशन पत्र सादर करणे सुरू'},
    {'date': '०२ डिसेंबर २०२६', 'title': 'नामनिर्देशन पत्रांची छाननी'},
    {'date': '०५ डिसेंबर २०२६', 'title': 'अर्ज मागे घेण्याची अंतिम मुदत व चिन्ह वाटप'},
    {'date': '१५ डिसेंबर २०२६', 'title': 'मतदान (सकाळी ७:३० ते संध्याकाळी ५:३०)'},
    {'date': '१७ डिसेंबर २०२६', 'title': 'मतमोजणी व निकाल घोषणा'},
  ];

  final List<Map<String, String>> _stations = const [
    {'num': '१', 'name': 'जिल्हा परिषद प्राथमिक शाळा (उत्तर बाजू), नरडाणा', 'voters': '८००'},
    {'num': '२', 'name': 'जिल्हा परिषद प्राथमिक शाळा (दक्षिण बाजू), नरडाणा', 'voters': '८५०'},
    {'num': '३', 'name': 'ग्रामपंचायत कार्यालय सभागृह, नरडाणा', 'voters': '७५०'},
    {'num': '४', 'name': 'नवीन हायस्कूल इमारत, स्टेशन रोड, नरडाणा', 'voters': '९००'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _fetchCandidates();
  }

  Future<void> _fetchCandidates() async {
    try {
      final res = await SupabaseService.client
          .from('election_candidates')
          .select('*, election_wards(ward_name_mr)')
          .eq('is_active', true)
          .order('candidate_name_mr');

      if (res.isNotEmpty) {
        final mapped = (res as List).map((row) {
          final wardName = row['election_wards'] != null ? row['election_wards']['ward_name_mr'] : 'नरडाणा प्रभाग';
          return {
            'id': row['id'],
            'name': row['candidate_name_mr'] ?? '',
            'ward': wardName,
            'symbol': row['symbol_name_mr'] ?? '',
            'education': row['education_mr'] ?? 'माहिती नाही',
            'age': '${row['age'] ?? 40} वर्ष',
            'agenda': row['manifesto_summary_mr'] ?? 'गावाच्या सर्वांगीण विकासासाठी कटिबद्ध.',
            'phone': row['phone'] ?? '',
          };
        }).toList();

        if (mounted) {
          setState(() {
            _candidates = mapped;
            _isLoading = false;
          });
          return;
        }
      }
    } catch (_) {}

    if (mounted) {
      setState(() {
        _candidates = _fallbackCandidates;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppBackScope(
      fallbackRoute: '/home',
      child: Scaffold(
        backgroundColor: AppColors.surface,
        appBar: AppBar(
          title: Text('ग्रामपंचायत निवडणूक पोर्टल', style: GoogleFonts.mukta(fontWeight: FontWeight.bold)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => context.go('/home'),
          ),
          bottom: TabBar(
            controller: _tabController,
            isScrollable: true,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: AppColors.accentYellow,
            labelStyle: GoogleFonts.mukta(fontWeight: FontWeight.bold, fontSize: 13),
            tabs: const [
              Tab(text: 'उमेदवार निर्देशिका'),
              Tab(text: 'प्रभाग व मतदार'),
              Tab(text: 'वेळापत्रक'),
              Tab(text: 'मतदान केंद्र'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildCandidatesTab(),
            _buildWardsTab(),
            _buildScheduleTab(),
            _buildStationsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildCandidatesTab() {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // Non-partisan awareness banner
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.primaryBlue.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              const Icon(Icons.how_to_vote_rounded, color: AppColors.primaryBlue, size: 26),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'समान सादरीकरण • कोणतीही क्रमवारी नाही',
                      style: GoogleFonts.mukta(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primaryBlue),
                    ),
                    Text(
                      'सर्व उमेदवारांची माहिती अधिकृतपणे मतदारांच्या सोयीसाठी एकाच स्वरूपात प्रदर्शित केली आहे.',
                      style: GoogleFonts.mukta(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        if (_isLoading)
          const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()))
        else
          ..._candidates.map((c) => Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(14),
                  leading: CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.1),
                    child: const Icon(Icons.person_rounded, color: AppColors.primaryBlue, size: 28),
                  ),
                  title: Text(
                    c['name'] as String,
                    style: GoogleFonts.mukta(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 2),
                      Text(
                        c['ward'] as String,
                        style: GoogleFonts.mukta(fontSize: 13, color: AppColors.secondaryGreen, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'चिन्ह: ${c['symbol']}',
                        style: GoogleFonts.mukta(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
                  onTap: () {
                    context.push('/candidate-detail', extra: c);
                  },
                ),
              )),

        // Legal restriction disclaimer
        Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.only(top: 8),
          decoration: BoxDecoration(
            color: Colors.amber.shade50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.amber.shade200),
          ),
          child: Text(
            'सूचना: निवडणूक आयोगाच्या नियमांनुसार राजकीय जाहिरात आणि पेमेंट स्वीकारणे बंद आहे. वैयक्तिक मत पसंती गोळा केली जात नाही.',
            textAlign: TextAlign.center,
            style: GoogleFonts.mukta(fontSize: 11, color: Colors.amber.shade900),
          ),
        ),
      ],
    );
  }

  Widget _buildWardsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('नरडाणा ग्रामपंचायत प्रभाग माहिती', style: GoogleFonts.mukta(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
        const SizedBox(height: 10),
        ..._wards.map((w) => Card(
              margin: const EdgeInsets.only(bottom: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(w['ward']!, style: GoogleFonts.mukta(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(color: AppColors.secondaryGreen.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                          child: Text('${w['voters']} मतदार', style: GoogleFonts.mukta(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.secondaryGreen)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(w['name']!, style: GoogleFonts.mukta(fontSize: 13, color: AppColors.textPrimary)),
                    const SizedBox(height: 2),
                    Text('आरक्षण: ${w['res']}', style: GoogleFonts.mukta(fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
              ),
            )),
      ],
    );
  }

  Widget _buildScheduleTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('निवडणूक वेळापत्रक २०२६', style: GoogleFonts.mukta(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
        const SizedBox(height: 10),
        ..._schedule.map((s) => Card(
              margin: const EdgeInsets.only(bottom: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.1),
                  child: const Icon(Icons.calendar_month_rounded, color: AppColors.primaryBlue, size: 20),
                ),
                title: Text(s['title']!, style: GoogleFonts.mukta(fontSize: 14, fontWeight: FontWeight.bold)),
                subtitle: Text(s['date']!, style: GoogleFonts.mukta(fontSize: 12, color: AppColors.secondaryGreen, fontWeight: FontWeight.w600)),
              ),
            )),
      ],
    );
  }

  Widget _buildStationsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('अधिकृत मतदान केंद्रे (Polling Stations)', style: GoogleFonts.mukta(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
        const SizedBox(height: 10),
        ..._stations.map((st) => Card(
              margin: const EdgeInsets.only(bottom: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.secondaryGreen.withValues(alpha: 0.12),
                  child: Text(st['num']!, style: GoogleFonts.mukta(fontWeight: FontWeight.bold, color: AppColors.secondaryGreen)),
                ),
                title: Text(st['name']!, style: GoogleFonts.mukta(fontSize: 14, fontWeight: FontWeight.bold)),
                subtitle: Text('नोंदणीकृत मतदार संख्या: अंदाजे ${st['voters']}', style: GoogleFonts.mukta(fontSize: 12, color: AppColors.textSecondary)),
              ),
            )),
      ],
    );
  }
}
