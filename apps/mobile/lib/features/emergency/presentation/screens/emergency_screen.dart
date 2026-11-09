import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:nardana_connect/core/constants/app_colors.dart';
import 'package:nardana_connect/core/localization/app_localizations.dart';

class EmergencyScreen extends StatelessWidget {
  const EmergencyScreen({super.key});

  final List<Map<String, dynamic>> _contacts = const [
    {
      'title_mr': 'पोलीस नियंत्रण कक्ष / तात्काळ मदत',
      'title_en': 'Police Control Room',
      'number': '112',
      'category': 'Police',
      'desc': 'तातडीच्या मदतीसाठी २४ तास उपलब्ध शासकीय क्रमांक.',
      'color': Colors.blue,
    },
    {
      'title_mr': 'नरडाणा पोलीस दूरक्षेत्र',
      'title_en': 'Nardana Police Outpost',
      'number': '02566245100',
      'category': 'Police Outpost',
      'desc': 'स्थानिक नरडाणा दूरक्षेत्र संपर्क.',
      'color': Colors.blue,
    },
    {
      'title_mr': 'शासकीय रुग्णवाहिका (१०८)',
      'title_en': 'Government Ambulance',
      'number': '108',
      'category': 'Ambulance',
      'desc': 'मोफत २४ तास आपत्कालीन वैद्यकीय रुग्णवाहिका सेवा.',
      'color': AppColors.emergencyRed,
    },
    {
      'title_mr': 'महावितरण वीज तक्रार केंद्र (MSEDCL)',
      'title_en': 'MSEDCL Electricity Emergency',
      'number': '1912',
      'category': 'Electricity',
      'desc': 'वीज पुरवठा खंडित अथवा वीज समस्येसाठी टोल-फ्री क्रमांक.',
      'color': Colors.amber,
    },
    {
      'title_mr': 'ग्रामपंचायत कार्यालय नरडाणा',
      'title_en': 'Gram Panchayat Office Nardana',
      'number': '02566258200',
      'category': 'Local Body',
      'desc': 'स्थानिक प्रशासकीय कामकाज व पाणी पुरवठा विचारणा.',
      'color': AppColors.secondaryGreen,
    },
    {
      'title_mr': 'प्राथमिक आरोग्य केंद्र (PHC) नरडाणा',
      'title_en': 'Primary Health Centre Nardana',
      'number': '02566258210',
      'category': 'Health',
      'desc': 'स्थानिक प्राथमिक शासकीय दवाखाना.',
      'color': AppColors.emergencyRed,
    },
    {
      'title_mr': 'सर्पमित्र हेल्पलाइन (Snake Rescuer)',
      'title_en': 'Snake Rescue Team',
      'number': '9421526400',
      'category': 'Rescue',
      'desc': 'विषारी अथवा बिनविषारी साप घरात निघाल्यास तात्काळ संपर्क.',
      'color': Colors.teal,
    },
    {
      'title_mr': 'अग्निशामक दल (Fire Emergency)',
      'title_en': 'Fire Station',
      'number': '101',
      'category': 'Fire',
      'desc': 'आग लागल्यास किंवा आपत्तीच्या वेळी.',
      'color': Colors.deepOrange,
    },
  ];

  Future<void> _call(String number) async {
    final uri = Uri.parse('tel:$number');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text(l10n.translate('emergency_services')),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _contacts.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final c = _contacts[index];
          final color = c['color'] as Color;

          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: color.withValues(alpha: 0.12),
                    child: Icon(Icons.emergency_rounded, color: color, size: 26),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          c['title_mr'],
                          style: GoogleFonts.mukta(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          c['desc'],
                          style: GoogleFonts.mukta(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () => _call(c['number']),
                    icon: const Icon(Icons.call_rounded, size: 16),
                    label: Text(c['number']),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      textStyle: GoogleFonts.mukta(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
