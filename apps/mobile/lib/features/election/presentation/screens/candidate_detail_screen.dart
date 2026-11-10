import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:nardana_connect/core/constants/app_colors.dart';
import 'package:nardana_connect/core/navigation/app_back_scope.dart';
import 'package:nardana_connect/core/navigation/back_button_handler.dart';

class CandidateDetailScreen extends StatelessWidget {
  final Map<String, dynamic> candidate;

  const CandidateDetailScreen({super.key, required this.candidate});

  Future<void> _call(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    final name = candidate['name'] as String? ?? 'उमेदवार';
    final ward = candidate['ward'] as String? ?? 'प्रभाग';
    final symbol = candidate['symbol'] as String? ?? 'चिन्ह';
    final education = candidate['education'] as String? ?? 'माहिती नाही';
    final age = candidate['age'] as String? ?? '';
    final agenda = candidate['agenda'] as String? ?? 'गावाच्या सर्वांगीण विकासासाठी कटिबद्ध.';
    final phone = candidate['phone'] as String? ?? '';

    return AppBackScope(
      fallbackRoute: '/election',
      child: Scaffold(
        backgroundColor: AppColors.surface,
        appBar: AppBar(
          title: Text('उमेदवार तपशील', style: GoogleFonts.mukta(fontWeight: FontWeight.bold)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => BackButtonHandler.safePop(context, fallbackRoute: '/election'),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 36,
                        backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.12),
                        child: const Icon(Icons.person_rounded, size: 44, color: AppColors.primaryBlue),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        name,
                        style: GoogleFonts.mukta(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        ward,
                        style: GoogleFonts.mukta(fontSize: 14, color: AppColors.secondaryGreen, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.amber.shade300),
                        ),
                        child: Text(
                          'निवडणूक चिन्ह: $symbol',
                          style: GoogleFonts.mukta(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.amber.shade900),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'पार्श्वभूमी व माहिती',
                        style: GoogleFonts.mukta(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      const Divider(height: 16),
                      _buildRow(Icons.school_outlined, 'शिक्षण', education),
                      const SizedBox(height: 10),
                      _buildRow(Icons.cake_outlined, 'वय', age),
                      const SizedBox(height: 10),
                      _buildRow(Icons.location_on_outlined, 'गाव', 'नरडाणा (४२५४०४)'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'उमेदवाराचा जाहीरनामा / उद्दिष्टे',
                        style: GoogleFonts.mukta(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        agenda,
                        style: GoogleFonts.mukta(fontSize: 14, height: 1.5, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              if (phone.isNotEmpty)
                ElevatedButton.icon(
                  onPressed: () => _call(phone),
                  icon: const Icon(Icons.call_rounded, size: 20),
                  label: Text('उमेदवाराशी संपर्क साधा ($phone)', style: GoogleFonts.mukta(fontSize: 15, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textMuted),
        const SizedBox(width: 8),
        Text('$label: ', style: GoogleFonts.mukta(fontSize: 13, color: AppColors.textSecondary)),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.mukta(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
          ),
        ),
      ],
    );
  }
}

