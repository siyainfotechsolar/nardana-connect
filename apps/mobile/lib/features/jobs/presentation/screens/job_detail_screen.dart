import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:nardana_connect/core/constants/app_colors.dart';

class JobDetailScreen extends StatelessWidget {
  final Map<String, dynamic> job;

  const JobDetailScreen({super.key, required this.job});

  Future<void> _call(String number) async {
    final clean = number.replaceAll(RegExp(r'[^0-9]'), '');
    final uri = Uri.parse('tel:$clean');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _openWhatsApp(String number, String jobTitle) async {
    final clean = number.replaceAll(RegExp(r'[^0-9]'), '');
    final phone = clean.startsWith('91') ? clean : '91$clean';
    final text = Uri.encodeComponent(
      'नमस्कार, मी नरडाणा कनेक्ट ॲपवर आपल्या "$jobTitle" या नोकरीची जाहिरात पाहिली. मला या कामाबद्दल अधिक माहिती हवी आहे.',
    );
    final uri = Uri.parse('https://wa.me/$phone?text=$text');
    if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _shareOnWhatsApp(String jobTitle, String company, String salary, String phone) async {
    final text = Uri.encodeComponent(
      '📢 *नरडाणा गावात नोकरीची संधी!*\n\n'
      '🔹 *पद:* $jobTitle\n'
      '🏢 *कंपनी/दुकान:* $company\n'
      '💰 *पगार:* $salary\n'
      '📍 *ठिकाण:* नरडाणा (पिन: ४२५४०४)\n'
      '📞 *संपर्क:* $phone\n\n'
      'अधिक माहितीसाठी *नरडाणा कनेक्ट (Nardana Connect)* ॲप डाऊनलोड करा:\n'
      'https://nardana-connect.vercel.app/download.html',
    );
    final uri = Uri.parse('https://wa.me/?text=$text');
    if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final title = job['title'] ?? job['job_title'] ?? 'नोकरी तपशील';
    final company = job['company'] ?? job['company_name'] ?? 'स्थानिक मालक / संस्था';
    final salary = job['salary'] ?? job['salary_range'] ?? 'चर्चेनुसार (Negotiable)';
    final location = job['location'] ?? job['job_location'] ?? 'नरडाणा (४२५४०४)';
    final qualification = job['qualification'] ?? '१० वी / १२ वी किंवा अनुभव';
    final type = job['type'] ?? job['job_type'] ?? 'Full-time';
    final phone = job['phone'] ?? job['contact_number'] ?? '';
    final desc = job['desc'] ?? job['description'] ?? 'या पदासाठी स्थानिक उमेदवाराची आवश्यकता आहे.';

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text(
          'नोकरी तपशील',
          style: GoogleFonts.mukta(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded, color: Colors.white),
            tooltip: 'व्हॉट्सॲपवर शेअर करा',
            onPressed: () => _shareOnWhatsApp(title, company, salary, phone),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Hero Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryBlue,
                    const Color(0xFF0D2745),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryBlue.withValues(alpha: 0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.accentYellow,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          type,
                          style: GoogleFonts.mukta(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.location_on_rounded, size: 13, color: Colors.white),
                            const SizedBox(width: 4),
                            Text(
                              'केवळ नरडाणा',
                              style: GoogleFonts.mukta(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    title,
                    style: GoogleFonts.mukta(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.business_rounded, size: 16, color: AppColors.accentYellow),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          company,
                          style: GoogleFonts.mukta(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withValues(alpha: 0.95),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.currency_rupee_rounded, size: 20, color: AppColors.accentYellow),
                        const SizedBox(width: 6),
                        Text(
                          'वेतन / पगार: ',
                          style: GoogleFonts.mukta(
                            fontSize: 13,
                            color: Colors.white70,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            salary,
                            style: GoogleFonts.mukta(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Key Info Grid
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: AppColors.border),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildInfoRow(
                      icon: Icons.school_rounded,
                      label: 'शैक्षणिक पात्रता',
                      value: qualification,
                      iconColor: Colors.purple,
                    ),
                    const Divider(height: 20),
                    _buildInfoRow(
                      icon: Icons.place_rounded,
                      label: 'कामाचे ठिकाण',
                      value: location,
                      iconColor: Colors.red,
                    ),
                    const Divider(height: 20),
                    _buildInfoRow(
                      icon: Icons.phone_rounded,
                      label: 'संपर्क क्रमांक',
                      value: phone.isNotEmpty ? phone : 'उपलब्ध नाही',
                      iconColor: AppColors.secondaryGreen,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Job Description
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: AppColors.border),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'कामाचे सविस्तर वर्णन (Job Description)',
                      style: GoogleFonts.mukta(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      desc,
                      style: GoogleFonts.mukta(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Village Scope Assurance
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.verified_rounded, size: 20, color: Colors.blue.shade800),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'नरडाणा कनेक्ट पडताळणी: ही नोकरी केवळ नरडाणा गाव परिसरातील नागरिकांसाठी उपलब्ध आहे. उमेदवारांनी थेट मालकाशी संपर्क साधावा.',
                      style: GoogleFonts.mukta(
                        fontSize: 11,
                        color: Colors.blue.shade900,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Action Buttons
            if (phone.isNotEmpty) ...[
              ElevatedButton.icon(
                onPressed: () => _call(phone),
                icon: const Icon(Icons.call_rounded, size: 20),
                label: Text('थेट कॉल करा ($phone)'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondaryGreen,
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
                onPressed: () => _openWhatsApp(phone, title),
                icon: const Icon(Icons.chat_rounded, size: 20, color: Color(0xFF25D366)),
                label: const Text('व्हॉट्सॲपवर चौकशी करा'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textPrimary,
                  minimumSize: const Size.fromHeight(48),
                  side: const BorderSide(color: Color(0xFF25D366), width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  textStyle: GoogleFonts.mukta(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: iconColor.withValues(alpha: 0.12),
          child: Icon(icon, size: 18, color: iconColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.mukta(
                  fontSize: 12,
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.mukta(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
