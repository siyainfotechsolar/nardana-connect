import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nardana_connect/core/constants/app_colors.dart';
import 'package:nardana_connect/core/navigation/app_back_scope.dart';
import 'package:nardana_connect/features/legal/models/disclaimer_model.dart';
import 'package:nardana_connect/features/legal/services/disclaimer_service.dart';
import 'package:url_launcher/url_launcher.dart';

class DisclaimerScreen extends StatefulWidget {
  const DisclaimerScreen({super.key});

  @override
  State<DisclaimerScreen> createState() => _DisclaimerScreenState();
}

class _DisclaimerScreenState extends State<DisclaimerScreen> {
  DisclaimerDocumentModel? _document;
  List<DisclaimerSectionModel> _sections = [];
  List<DisclaimerVersionHistoryModel> _history = [];
  bool _isLoading = true;
  String _selectedLanguage = 'mr'; // 'mr' | 'en'
  bool _hasAccepted = false;
  bool _isAccepting = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final doc = await DisclaimerService.instance.fetchDocument();
    final sections = await DisclaimerService.instance.fetchSections();
    final history = await DisclaimerService.instance.fetchVersionHistory();
    final accepted = await DisclaimerService.instance.hasAcceptedLatestVersion(doc.currentVersion);

    if (mounted) {
      setState(() {
        _document = doc;
        _sections = sections;
        _history = history;
        _hasAccepted = accepted;
        _isLoading = false;
      });
    }
  }

  Future<void> _acceptDisclaimer() async {
    if (_document == null) return;
    setState(() => _isAccepting = true);
    final ok = await DisclaimerService.instance.recordAcceptance(
      versionNumber: _document!.currentVersion,
    );

    if (mounted) {
      setState(() {
        _isAccepting = false;
        _hasAccepted = ok;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _selectedLanguage == 'mr'
                ? 'कायदेशीर अस्वीकरण यशस्वीरित्या मान्य केले.'
                : 'Legal Disclaimer accepted successfully.',
            style: GoogleFonts.mukta(fontWeight: FontWeight.bold),
          ),
          backgroundColor: AppColors.secondaryGreen,
        ),
      );
    }
  }

  void _showHistoryModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.55,
        maxChildSize: 0.85,
        minChildSize: 0.4,
        expand: false,
        builder: (_, scrollController) => Padding(
          padding: const EdgeInsets.all(20),
          child: ListView(
            controller: scrollController,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.history_rounded, color: AppColors.primaryBlue),
                  const SizedBox(width: 8),
                  Text(
                    _selectedLanguage == 'mr' ? 'अस्वीकरण आवृत्ती इतिहास' : 'Disclaimer Version History',
                    style: GoogleFonts.mukta(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ..._history.map(
                (h) => Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.primaryBlue,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'v${h.versionNumber}',
                              style: GoogleFonts.mukta(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Text(
                            h.effectiveDate,
                            style: GoogleFonts.mukta(fontSize: 12, color: Colors.blueGrey),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _selectedLanguage == 'mr' ? h.changelogMr : h.changelogEn,
                        style: GoogleFonts.mukta(fontSize: 13, color: const Color(0xFF1E293B)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final doc = _document;
    final isMr = _selectedLanguage == 'mr';

    return AppBackScope(
      fallbackRoute: '/settings',
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
                context.go('/settings');
              }
            },
          ),
          title: Text(
            isMr ? 'कायदेशीर अस्वीकरण' : 'Legal Disclaimer',
            style: GoogleFonts.mukta(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.history_rounded),
              tooltip: isMr ? 'आवृत्ती इतिहास' : 'Version History',
              onPressed: _showHistoryModal,
            ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue))
            : Column(
                children: [
                  // Language & Version Strip
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Row(
                      children: [
                        // Language Toggle
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Row(
                            children: [
                              _buildLangButton('mr', 'मराठी'),
                              _buildLangButton('en', 'English'),
                            ],
                          ),
                        ),
                        const Spacer(),
                        // Version Badge
                        InkWell(
                          onTap: _showHistoryModal,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: AppColors.primaryBlue.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.2)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.verified_outlined, size: 14, color: AppColors.primaryBlue),
                                const SizedBox(width: 4),
                                Text(
                                  'v${doc?.currentVersion ?? "1.0.0"}',
                                  style: GoogleFonts.mukta(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryBlue,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: Color(0xFFE2E8F0)),

                  // Sections List
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        // Hero Header Box
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF123B66), Color(0xFF0F2B48)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(Icons.gavel_rounded, color: AppColors.accentYellow, size: 24),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'NARDANA CONNECT',
                                          style: GoogleFonts.mukta(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w800,
                                            color: Colors.white,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                        Text(
                                          isMr ? 'आपलं गाव, आपली डिजिटल ओळख!' : 'Our Village, Our Digital Identity!',
                                          style: GoogleFonts.mukta(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.accentYellow,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                isMr
                                    ? 'केवळ नरडाणा गाव (पिन: ४२५४०४) मधील माहिती व सेवांसाठी अधिकृत कायदेशीर नियमावली व अस्वीकरण.'
                                    : 'Official Legal Disclaimer and Terms of Use for Nardana Village community services.',
                                style: GoogleFonts.mukta(fontSize: 12.5, color: const Color(0xFFCBD5E1)),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.calendar_today_outlined, size: 12, color: Colors.white70),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${isMr ? "प्रभावी दिनांक" : "Effective Date"}: ${doc?.effectiveDate ?? "2026-11-12"}',
                                    style: GoogleFonts.mukta(fontSize: 11, color: Colors.white70),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Render 14 Sections
                        ..._sections.map((sec) => _buildSectionCard(sec, isMr)),

                        const SizedBox(height: 12),

                        // Mandatory Agreement Note
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFFDE68A)),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.info_rounded, color: Color(0xFF92400E), size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  isMr
                                      ? 'NARDANA CONNECT ॲप वापरून, आपण हे अस्वीकरण वाचले, समजले आणि मान्य केले आहे असे मानले जाईल.'
                                      : 'By using NARDANA CONNECT, users acknowledge that they have read and understood this Disclaimer.',
                                  style: GoogleFonts.mukta(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF78350F),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 90),
                      ],
                    ),
                  ),
                ],
              ),
        bottomSheet: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 10,
                offset: const Offset(0, -3),
              ),
            ],
          ),
          child: SafeArea(
            child: _hasAccepted
                ? Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF86EFAC)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check_circle_rounded, color: Color(0xFF16A34A), size: 18),
                        const SizedBox(width: 8),
                        Text(
                          isMr
                              ? 'आपण ही अधिकृत आवृत्ती (v${doc?.currentVersion ?? "1.0.0"}) मान्य केली आहे'
                              : 'You have accepted this version (v${doc?.currentVersion ?? "1.0.0"})',
                          style: GoogleFonts.mukta(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF15803D),
                          ),
                        ),
                      ],
                    ),
                  )
                : SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: _isAccepting ? null : _acceptDisclaimer,
                      icon: _isAccepting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.check_circle_outline_rounded, size: 20),
                      label: Text(
                        isMr
                            ? 'मी हे अस्वीकरण वाचले व मला मान्य आहे'
                            : 'I Have Read & Accept This Disclaimer',
                        style: GoogleFonts.mukta(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: Colors.white,
                        elevation: 1,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildLangButton(String code, String label) {
    final isSelected = _selectedLanguage == code;
    return InkWell(
      onTap: () => setState(() => _selectedLanguage = code),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryBlue : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: GoogleFonts.mukta(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : const Color(0xFF475569),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard(DisclaimerSectionModel sec, bool isMr) {
    final title = isMr ? sec.titleMr : sec.titleEn;
    final content = isMr ? sec.contentMr : sec.contentEn;
    final isContact = sec.sectionKey == 'contact_support';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.mukta(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                ),
                if (sec.isMaterial)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'महत्वाचे',
                      style: GoogleFonts.mukta(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primaryBlue),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              content,
              style: GoogleFonts.mukta(
                fontSize: 13.5,
                color: const Color(0xFF334155),
                height: 1.5,
              ),
            ),
            if (isContact) ...[
              const SizedBox(height: 12),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => launchUrl(Uri.parse('tel:9421889901')),
                      icon: const Icon(Icons.phone_in_talk_rounded, size: 16),
                      label: Text('कॉल करा', style: GoogleFonts.mukta(fontSize: 12.5, fontWeight: FontWeight.bold)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primaryBlue,
                        side: const BorderSide(color: AppColors.primaryBlue),
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => launchUrl(Uri.parse('mailto:siyainfotechsolar@gmail.com')),
                      icon: const Icon(Icons.email_outlined, size: 16),
                      label: Text('ईमेल करा', style: GoogleFonts.mukta(fontSize: 12.5, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
