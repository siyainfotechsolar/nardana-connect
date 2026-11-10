import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:nardana_connect/core/constants/app_colors.dart';
import 'package:nardana_connect/core/localization/app_localizations.dart';

class NoticesScreen extends StatelessWidget {
  const NoticesScreen({super.key});

  final List<Map<String, dynamic>> _notices = const [
    {
      'title_mr': 'पिण्याच्या पाण्याचे वेळापत्रक बदल',
      'title_en': 'Drinking Water Schedule Update',
      'desc_mr':
          'नरडाणा ग्रामस्थांना कळविण्यात येते की मुख्य जलवाहिनी दुरुस्तीच्या कामामुळे उद्या सकाळी ७ ते १० दरम्यानच पाणीपुरवठा केला जाईल. कृपया नोंद घ्यावी.',
      'date': '१० नोव्हेंबर २०२६',
      'authority': 'ग्रामपंचायत कार्यालय, नरडाणा',
      'priority': 'high',
      'is_official': true,
    },
    {
      'title_mr': 'महावितरण: नियोजित वीज पुरवठा खंडित',
      'title_en': 'MSEDCL Scheduled Power Cut',
      'desc_mr':
          'नरडाणा सबस्टेशनवरील तातडीच्या देखभाल दुरुस्ती कामामुळे गुरुवारी सकाळी ९ ते दुपारी २ वाजेपर्यंत संपूर्ण नरडाणा गावातील वीज पुरवठा बंद राहील.',
      'date': '०९ नोव्हेंबर २०२६',
      'authority': 'महावितरण उपविभाग',
      'priority': 'high',
      'is_official': false,
    },
    {
      'title_mr': 'मोफत डोळे तपासणी व मोतीबिंदू शस्त्रक्रिया शिबीर',
      'title_en': 'Free Eye Checkup Camp',
      'desc_mr':
          'रविवार रोजी प्राथमिक आरोग्य केंद्र नरडाणा येथे सकाळी ९ ते दुपारी २ या वेळेत मोफत तपासणी शिबीर आयोजित करण्यात आले आहे. गरजू ग्रामस्थांनी लाभ घ्यावा.',
      'date': '०८ नोव्हेंबर २०२६',
      'authority': 'प्राथमिक आरोग्य केंद्र नरडाणा',
      'priority': 'normal',
      'is_official': true,
    },
    {
      'title_mr': 'विशेष ग्रामसभा व विकास कामे नियोजन बैठक',
      'title_en': 'Special Gram Sabha Meeting',
      'desc_mr':
          'येत्या शुक्रवारी दुपारी ४ वाजता ग्रामपंचायत कार्यालय नरडाणा प्रांगणात विशेष ग्रामसभेचे आयोजन करण्यात आले आहे. गावातील रस्ते, गटारी व पथदिव्यांच्या कामांवर चर्चा होईल.',
      'date': '०७ नोव्हेंबर २०२६',
      'authority': 'ग्रामपंचायत कार्यालय, नरडाणा',
      'priority': 'normal',
      'is_official': true,
    },
  ];

  Future<void> _shareOnWhatsApp(String title, String desc, String date) async {
    final text = Uri.encodeComponent(
      '📢 *नरडाणा गाव सूचना*\n\n'
      '📌 *विषय:* $title\n'
      '📅 *दिनांक:* $date\n\n'
      '📝 *तपशील:*\n$desc\n\n'
      'नरडाणा कनेक्ट ॲप:\nhttps://nardana-connect.vercel.app/download.html',
    );
    final uri = Uri.parse('https://wa.me/?text=$text');
    if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text(l10n.translate('village_notices')),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _notices.length,
        separatorBuilder: (context, index) => const SizedBox(height: 14),
        itemBuilder: (context, index) {
          final n = _notices[index];
          final isOfficial = n['is_official'] as bool;
          final isHighPriority = n['priority'] == 'high';

          return Card(
            elevation: 1.5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: AppColors.border),
            ),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => context.push('/notice-detail', extra: n),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (isOfficial) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.secondaryGreen,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.verified_rounded,
                                    size: 13, color: Colors.white),
                                const SizedBox(width: 4),
                                Text(
                                  l10n.translate('gram_panchayat_official'),
                                  style: GoogleFonts.mukta(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ] else ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade100,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'सार्वजनिक सूचना',
                              style: GoogleFonts.mukta(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade900,
                              ),
                            ),
                          ),
                        ],
                        const Spacer(),
                        if (isHighPriority)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: Colors.red.shade200),
                            ),
                            child: Text(
                              'महत्त्वाचे',
                              style: GoogleFonts.mukta(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.red.shade700,
                              ),
                            ),
                          ),
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 13,
                          color: AppColors.primaryBlue,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      n['title_mr'],
                      style: GoogleFonts.mukta(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      n['desc_mr'],
                      style: GoogleFonts.mukta(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_rounded,
                            size: 13, color: AppColors.textMuted),
                        const SizedBox(width: 4),
                        Text(
                          n['date'],
                          style: GoogleFonts.mukta(
                            fontSize: 12,
                            color: AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            n['authority'],
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.mukta(
                              fontSize: 12,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => context.push('/notice-detail', extra: n),
                            icon: const Icon(Icons.read_more_rounded, size: 16),
                            label: const Text('संपूर्ण सूचना वाचा'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primaryBlue,
                              side: const BorderSide(color: AppColors.primaryBlue),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              textStyle: GoogleFonts.mukta(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton.filledTonal(
                          onPressed: () => _shareOnWhatsApp(n['title_mr'], n['desc_mr'], n['date']),
                          icon: const Icon(Icons.share_rounded, size: 18),
                          tooltip: 'शेअर करा',
                          style: IconButton.styleFrom(
                            backgroundColor: const Color(0xFF25D366).withValues(alpha: 0.15),
                            foregroundColor: const Color(0xFF075E54),
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
    );
  }
}
