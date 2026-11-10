import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:nardana_connect/core/constants/app_colors.dart';
import 'package:nardana_connect/core/navigation/app_back_scope.dart';
import 'package:nardana_connect/core/navigation/back_button_handler.dart';

class NoticeDetailScreen extends StatelessWidget {
  final Map<String, dynamic> notice;

  const NoticeDetailScreen({super.key, required this.notice});

  Future<void> _shareOnWhatsApp(String title, String desc, String date, String authority) async {
    final text = Uri.encodeComponent(
      '📢 *नरडाणा गाव अधिकृत सूचना*\n\n'
      '📌 *विषय:* $title\n'
      '🏛️ *प्राधिकरण:* $authority\n'
      '📅 *दिनांक:* $date\n\n'
      '📝 *सूचना तपशील:*\n$desc\n\n'
      'गावातील ताज्या सूचना व सेवांसाठी *नरडाणा कनेक्ट* ॲप वापरा:\n'
      'https://nardana-connect.vercel.app/download.html',
    );
    final uri = Uri.parse('https://wa.me/?text=$text');
    if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _callAuthority(String phone) async {
    final clean = phone.replaceAll(RegExp(r'[^0-9]'), '');
    final uri = Uri.parse('tel:$clean');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    final titleMr = notice['title_mr'] ?? notice['title'] ?? 'गाव सूचना';
    final titleEn = notice['title_en'] as String?;
    final descMr = notice['desc_mr'] ?? notice['description_mr'] ?? notice['desc'] ?? '';
    final descEn = notice['description_en'] as String?;
    final date = notice['date'] ?? notice['published_date'] ?? 'आजची तारीख';
    final authority = notice['authority'] ?? 'ग्रामपंचायत कार्यालय, नरडाणा';
    final isOfficial = notice['is_official'] ?? notice['is_gram_panchayat'] ?? true;
    final priority = notice['priority'] ?? 'normal';
    final isEmergency = priority == 'emergency';
    final isHigh = priority == 'high';

    return AppBackScope(
      fallbackRoute: '/notices',
      child: Scaffold(
        backgroundColor: AppColors.surface,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => BackButtonHandler.safePop(context, fallbackRoute: '/notices'),
          ),
        title: Text(
          'गाव सूचना तपशील',
          style: GoogleFonts.mukta(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded, color: Colors.white),
            tooltip: 'व्हॉट्सॲपवर शेअर करा',
            onPressed: () => _shareOnWhatsApp(titleMr, descMr, date, authority),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status & Priority Badges
            Row(
              children: [
                if (isOfficial)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryGreen,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.verified_rounded, size: 14, color: Colors.white),
                        const SizedBox(width: 4),
                        Text(
                          'ग्रामपंचायत अधिकृत',
                          style: GoogleFonts.mukta(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'सार्वजनिक सूचना',
                      style: GoogleFonts.mukta(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade900,
                      ),
                    ),
                  ),
                const SizedBox(width: 8),
                if (isEmergency)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade300),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.warning_amber_rounded, size: 14, color: Colors.red),
                        const SizedBox(width: 4),
                        Text(
                          'तातडीची / आणीबाणी',
                          style: GoogleFonts.mukta(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.red.shade900,
                          ),
                        ),
                      ],
                    ),
                  )
                else if (isHigh)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'महत्त्वाची सूचना',
                      style: GoogleFonts.mukta(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade900,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 14),

            // Title & Authority
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: AppColors.border),
              ),
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titleMr,
                      style: GoogleFonts.mukta(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        height: 1.25,
                      ),
                    ),
                    if (titleEn != null && titleEn.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        titleEn,
                        style: GoogleFonts.mukta(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    const Divider(),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.account_balance_rounded, size: 16, color: AppColors.primaryBlue),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            authority,
                            style: GoogleFonts.mukta(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_rounded, size: 14, color: AppColors.textMuted),
                        const SizedBox(width: 6),
                        Text(
                          'प्रसिद्ध दिनांक: $date',
                          style: GoogleFonts.mukta(
                            fontSize: 12,
                            color: AppColors.textMuted,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'नरडाणा (४२५४०४)',
                            style: GoogleFonts.mukta(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryBlue,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Notice Body
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: AppColors.border),
              ),
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.article_rounded, size: 18, color: AppColors.primaryBlue),
                        const SizedBox(width: 6),
                        Text(
                          'संपूर्ण सूचना मजकूर',
                          style: GoogleFonts.mukta(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Text(
                        descMr,
                        style: GoogleFonts.mukta(
                          fontSize: 15,
                          height: 1.6,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    if (descEn != null && descEn.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      Text(
                        'English Summary:',
                        style: GoogleFonts.mukta(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        descEn,
                        style: GoogleFonts.mukta(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Share CTA
            ElevatedButton.icon(
              onPressed: () => _shareOnWhatsApp(titleMr, descMr, date, authority),
              icon: const Icon(Icons.share_rounded, size: 20),
              label: const Text('गावकऱ्यांना व्हॉट्सॲपवर पाठवा'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF25D366),
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                textStyle: GoogleFonts.mukta(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 10),

            OutlinedButton.icon(
              onPressed: () => _callAuthority('02566258200'),
              icon: const Icon(Icons.call_rounded, size: 20, color: AppColors.primaryBlue),
              label: const Text('ग्रामपंचायत कार्यालयाशी संपर्क (02566-258200)'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryBlue,
                minimumSize: const Size.fromHeight(48),
                side: const BorderSide(color: AppColors.primaryBlue, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                textStyle: GoogleFonts.mukta(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 10),

            OutlinedButton.icon(
              onPressed: () {
                context.push('/pdf-viewer', extra: {
                  'title': titleMr,
                  'url': 'https://zrnukpkufwrexrvysmpw.supabase.co/storage/v1/object/public/notice-attachments/notice.pdf',
                  'fallbackRoute': '/notice-detail',
                });
              },
              icon: const Icon(Icons.picture_as_pdf_rounded, size: 20, color: Colors.red),
              label: const Text('अधिकृत PDF सूचनापत्र पहा (View PDF)'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red.shade700,
                minimumSize: const Size.fromHeight(48),
                side: BorderSide(color: Colors.red.shade300, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                textStyle: GoogleFonts.mukta(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    ),
  );
}
}
