import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nardana_connect/core/constants/app_colors.dart';
import 'package:nardana_connect/core/localization/app_localizations.dart';
import 'package:nardana_connect/core/localization/locale_provider.dart';
import 'package:nardana_connect/core/services/supabase_service.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  String? _userName;
  String? _userEmail;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = SupabaseService.client.auth.currentUser;
    if (user != null) {
      _userEmail = user.email;
      _userName = user.userMetadata?['full_name'] as String? ?? user.email?.split('@').first ?? 'नागरिक';

      try {
        final profileRes = await SupabaseService.client
            .from('profiles')
            .select('full_name')
            .eq('id', user.id)
            .maybeSingle();

        if (profileRes != null && profileRes['full_name'] != null) {
          _userName = profileRes['full_name'];
        }
      } catch (_) {}
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('लॉगआउट करायचे आहे का?', style: GoogleFonts.mukta(fontWeight: FontWeight.bold)),
        content: Text('आपण ॲपमधून बाहेर पडू इच्छिता?', style: GoogleFonts.mukta(fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('नाही', style: GoogleFonts.mukta(color: Colors.grey.shade600)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade700, foregroundColor: Colors.white),
            child: Text('होय, लॉगआउट करा', style: GoogleFonts.mukta(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await SupabaseService.client.auth.signOut();
      if (mounted) {
        context.go('/welcome');
      }
    }
  }

  void _showPolicyDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title, style: GoogleFonts.mukta(fontWeight: FontWeight.bold, fontSize: 16)),
        content: SingleChildScrollView(
          child: Text(content, style: GoogleFonts.mukta(fontSize: 13, height: 1.4, color: AppColors.textSecondary)),
        ),
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final currentLocale = ref.watch(localeProvider);
    final isGuest = SupabaseService.client.auth.currentUser == null;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text(l10n.translate('profile'), style: GoogleFonts.mukta(fontWeight: FontWeight.bold)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // User Profile Card
                  Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: isGuest
                                ? Colors.grey.shade200
                                : AppColors.primaryBlue.withValues(alpha: 0.12),
                            child: Icon(
                              isGuest ? Icons.person_outline_rounded : Icons.person_rounded,
                              size: 34,
                              color: isGuest ? Colors.grey.shade600 : AppColors.primaryBlue,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isGuest ? 'पाहुणा नागरिक (Guest User)' : (_userName ?? 'गावकरी नागरिक'),
                                  style: GoogleFonts.mukta(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                Text(
                                  isGuest ? 'मर्यादित वापर' : (_userEmail ?? 'सत्यापित गावकरी'),
                                  style: GoogleFonts.mukta(fontSize: 12, color: AppColors.textSecondary),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.location_on_rounded, size: 13, color: AppColors.secondaryGreen),
                                    const SizedBox(width: 4),
                                    Text(
                                      'नरडाणा (पिन: ४२५४०४)',
                                      style: GoogleFonts.mukta(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.secondaryGreen,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          if (isGuest)
                            ElevatedButton(
                              onPressed: () => context.push('/login'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryBlue,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              ),
                              child: Text('लॉगिन', style: GoogleFonts.mukta(fontWeight: FontWeight.bold, fontSize: 13)),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Menu Options Card
                  Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.bookmark_border_rounded, color: AppColors.primaryBlue),
                          title: Text('माझे आवडीचे व्यवसाय (Favorites)', style: GoogleFonts.mukta(fontWeight: FontWeight.w600)),
                          trailing: const Icon(Icons.chevron_right_rounded),
                          onTap: () => context.push('/favorites'),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.translate_rounded, color: AppColors.primaryBlue),
                          title: Text(l10n.translate('change_language'), style: GoogleFonts.mukta(fontWeight: FontWeight.w600)),
                          subtitle: Text(
                            currentLocale.languageCode == 'mr' ? 'मराठी' : 'English',
                            style: GoogleFonts.mukta(fontSize: 12, color: AppColors.secondaryGreen),
                          ),
                          trailing: const Icon(Icons.chevron_right_rounded),
                          onTap: () => context.push('/language'),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.how_to_vote_rounded, color: AppColors.primaryBlue),
                          title: Text('ग्रामपंचायत निवडणूक व उमेदवार', style: GoogleFonts.mukta(fontWeight: FontWeight.w600)),
                          subtitle: Text('उमेदवार निर्देशिका व माहिती', style: GoogleFonts.mukta(fontSize: 12, color: AppColors.textSecondary)),
                          trailing: const Icon(Icons.chevron_right_rounded),
                          onTap: () => context.push('/election'),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.settings_outlined, color: AppColors.primaryBlue),
                          title: Text('ॲप सेटिंग्ज (Settings)', style: GoogleFonts.mukta(fontWeight: FontWeight.w600)),
                          trailing: const Icon(Icons.chevron_right_rounded),
                          onTap: () => context.push('/settings'),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.info_outline_rounded, color: AppColors.primaryBlue),
                          title: Text('ॲप माहिती व आवृत्ती (About App)', style: GoogleFonts.mukta(fontWeight: FontWeight.w600)),
                          subtitle: Text('NARDANA CONNECT • Version Details', style: GoogleFonts.mukta(fontSize: 12, color: AppColors.textSecondary)),
                          trailing: const Icon(Icons.chevron_right_rounded),
                          onTap: () => context.push('/about'),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.privacy_tip_outlined, color: AppColors.primaryBlue),
                          title: Text('गोपनीयता धोरण (Privacy Policy)', style: GoogleFonts.mukta(fontWeight: FontWeight.w600)),
                          trailing: const Icon(Icons.chevron_right_rounded),
                          onTap: () => _showPolicyDialog(
                            'गोपनीयता धोरण (Privacy Policy)',
                            'नरडाणा कनेक्ट (Nardana Connect) हे केवळ नरडाणा गाव (पिन: ४२५४०४, ता. शिंदखेडा, जि. धुळे) या परिसरातील नागरिकांसाठी स्वतंत्र सामाजिक माहिती व्यासपीठ आहे.\n\n१. आम्ही नागरिकांचा कोणताही वैयक्तिक डेटा विकत नाही किंवा बाहेरील कंपन्यांशी सामायिक करत नाही.\n२. वापरकर्त्यांनी स्वेच्छेने दिलेली संपर्क माहिती केवळ स्थानिक व्यवहार आणि आपत्कालीन संपर्कासाठी वापरली जाते.\n३. या ॲपमध्ये कोणत्याही प्रकारचा ट्रॅकिंग डेटा अथवा वैयक्तिक राजकीय पसंती गोळा केली जात नाही.',
                          ),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.description_outlined, color: AppColors.primaryBlue),
                          title: Text('नियम व अटी (Terms & Conditions)', style: GoogleFonts.mukta(fontWeight: FontWeight.w600)),
                          trailing: const Icon(Icons.chevron_right_rounded),
                          onTap: () => _showPolicyDialog(
                            'नियम व अटी (Terms & Conditions)',
                            '१. हे ॲप केवळ नरडाणा गावासाठी मर्यादित आहे.\n२. नागरिकांनी दिलेली माहिती खरी असणे आवश्यक आहे.\n३. आक्षेपार्ह, दिशाभूल करणारी अथवा बेकायदेशीर माहिती त्वरित काढून टाकण्यात येईल.\n४. कोणत्याही आर्थिक व्यवहाराची पडताळणी नागरिकांनी स्वतः प्रत्यक्ष खात्री करूनच करावी.',
                          ),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.gavel_rounded, color: AppColors.primaryBlue),
                          title: Text('कायदेशीर अस्वीकरण (Disclaimer)', style: GoogleFonts.mukta(fontWeight: FontWeight.w600)),
                          subtitle: Text('१४ कलमे • अधिकृत आवृत्ती १.०.० (मराठी व English)', style: GoogleFonts.mukta(fontSize: 12, color: AppColors.textSecondary)),
                          trailing: const Icon(Icons.chevron_right_rounded),
                          onTap: () => context.push('/disclaimer'),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.help_outline_rounded, color: AppColors.primaryBlue),
                          title: Text(l10n.translate('help_support'), style: GoogleFonts.mukta(fontWeight: FontWeight.w600)),
                          trailing: const Icon(Icons.chevron_right_rounded),
                          onTap: () => _showPolicyDialog(
                            'मदत व संपर्क केंद्र',
                            'नरडाणा कनेक्ट डिजिटल हेल्पडेस्क\nकार्यालय: SIYA INFOTECH – NARDANA BRANCH\nपत्ता: स्टेशन रोड चौक, नरडाणा, ता. शिंदखेडा, जि. धुळे - ४२५४०४\n\nस्थानिक व्यवसाय नोंदणी व तांत्रिक मदतीसाठी संपर्क साधा.',
                          ),
                        ),
                        if (!isGuest) ...[
                          const Divider(height: 1),
                          ListTile(
                            leading: const Icon(Icons.logout_rounded, color: Colors.red),
                            title: Text('लॉगआउट (Logout)', style: GoogleFonts.mukta(fontWeight: FontWeight.bold, color: Colors.red)),
                            onTap: _handleLogout,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Attribution & Scope
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        Text('संकल्पना व तंत्रज्ञान विकास', style: GoogleFonts.mukta(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                        const SizedBox(height: 2),
                        Text('Siya Infotech', style: GoogleFonts.mukta(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
                        Text('Rural Digital Initiative • Nardana (Dhule)', style: GoogleFonts.mukta(fontSize: 11, color: AppColors.secondaryGreen, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
