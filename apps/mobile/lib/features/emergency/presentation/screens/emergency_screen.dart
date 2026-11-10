import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:nardana_connect/core/constants/app_colors.dart';
import 'package:nardana_connect/core/localization/app_localizations.dart';

class EmergencyScreen extends StatelessWidget {
  const EmergencyScreen({super.key});

  final List<Map<String, dynamic>> _contacts = const [
    {
      'title_mr': 'पोलीस नियंत्रण कक्ष / तात्काळ मदत',
      'title_en': 'Police Control Room (Toll Free)',
      'number': '112',
      'category': 'पोलीस व सुरक्षा',
      'desc': 'तातडीच्या मदतीसाठी २४ तास उपलब्ध शासकीय क्रमांक.',
      'color': Colors.blue,
      'instructions': 'आणीबाणीच्या परिस्थितीत कॉल करून आपले अचूक ठिकाण (उदा. नरडाणा हायवे, बाजारपेठ) सांगा.',
    },
    {
      'title_mr': 'नरडाणा पोलीस दूरक्षेत्र',
      'title_en': 'Nardana Police Outpost',
      'number': '02566245100',
      'category': 'पोलीस ठाणे',
      'desc': 'स्थानिक नरडाणा दूरक्षेत्र संपर्क क्रमांक.',
      'color': Colors.blue,
      'instructions': 'नरडाणा गावातील कायदा व सुव्यवस्था, तक्रार व मदतीसाठी थेट स्थानिक पोलीस दूरक्षेत्राशी संपर्क करा.',
    },
    {
      'title_mr': 'शासकीय रुग्णवाहिका (१०८)',
      'title_en': 'Government Ambulance Service',
      'number': '108',
      'category': 'रुग्णवाहिका व आरोग्य',
      'desc': 'मोफत २४ तास आपत्कालीन वैद्यकीय रुग्णवाहिका सेवा.',
      'color': AppColors.emergencyRed,
      'instructions': 'अपघात किंवा गंभीर रुग्णांसाठी तात्काळ १०८ वर कॉल करा. मोफत सेवा उपलब्ध.',
    },
    {
      'title_mr': 'महावितरण वीज तक्रार केंद्र (MSEDCL)',
      'title_en': 'MSEDCL Electricity Emergency',
      'number': '1912',
      'category': 'महावितरण (वीज)',
      'desc': 'वीज पुरवठा खंडित अथवा वीज समस्येसाठी टोल-फ्री क्रमांक.',
      'color': Colors.amber,
      'instructions': 'वीज तारा तुटल्यास, शॉर्ट सर्किट झाल्यास किंवा डीपीमध्ये बिघाड झाल्यास तात्काळ कळवा.',
    },
    {
      'title_mr': 'ग्रामपंचायत कार्यालय नरडाणा',
      'title_en': 'Gram Panchayat Office Nardana',
      'number': '02566258200',
      'category': 'ग्रामपंचायत प्रशासन',
      'desc': 'स्थानिक प्रशासकीय कामकाज व पाणी पुरवठा विचारणा.',
      'color': AppColors.secondaryGreen,
      'instructions': 'पिण्याच्या पाण्याचे नियोजन, स्वच्छता व स्थानिक प्रशासकीय चौकशीसाठी कार्यालयीन वेळेत संपर्क करा.',
    },
    {
      'title_mr': 'प्राथमिक आरोग्य केंद्र (PHC) नरडाणा',
      'title_en': 'Primary Health Centre Nardana',
      'number': '02566258210',
      'category': 'आरोग्य केंद्र',
      'desc': 'स्थानिक प्राथमिक शासकीय दवाखाना व प्रसूती सेवा.',
      'color': AppColors.emergencyRed,
      'instructions': 'आरोग्य तपासणी, लस, प्राथमिक उपचार व औषधांसाठी स्थानिक प्राथमिक आरोग्य केंद्रात संपर्क साधा.',
    },
    {
      'title_mr': 'सर्पमित्र हेल्पलाइन (Snake Rescuer)',
      'title_en': 'Snake Rescue Team Nardana',
      'number': '9421526400',
      'category': 'सर्पमित्र व बचाव कार्य',
      'desc': 'विषारी अथवा बिनविषारी साप घरात निघाल्यास तात्काळ संपर्क करा.',
      'color': Colors.teal,
      'instructions': 'सापाला इजा पोहोचवू नका. सापावर लक्ष ठेवून सुरक्षित अंतरावरून सर्पमित्राला कॉल करा.',
    },
    {
      'title_mr': 'अग्निशामक दल (Fire Emergency)',
      'title_en': 'Fire Emergency Services',
      'number': '101',
      'category': 'अग्निशामक',
      'desc': 'आग लागल्यास किंवा नैसर्गिक आपत्तीच्या वेळी.',
      'color': Colors.deepOrange,
      'instructions': 'शेतमालाला आग, शॉर्ट सर्किट किंवा सिलिंडर आगीच्या वेळी तात्काळ १०१ डायल करा.',
    },
  ];

  Future<void> _call(String number) async {
    final clean = number.replaceAll(RegExp(r'[^0-9]'), '');
    final uri = Uri.parse('tel:$clean');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _shareOnWhatsApp(String title, String number, String desc) async {
    final text = Uri.encodeComponent(
      '🚨 *नरडाणा आपत्कालीन हेल्पलाइन क्रमांक*\n\n'
      '🏛️ *$title*\n'
      '📞 *दूरध्वनी:* $number\n'
      'ℹ️ *तपशील:* $desc\n\n'
      'नरडाणा कनेक्ट (केवळ नरडाणा गाव):\nhttps://nardana-connect.vercel.app/download.html',
    );
    final uri = Uri.parse('https://wa.me/?text=$text');
    if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  void _showContactDetails(BuildContext context, Map<String, dynamic> c) {
    final color = c['color'] as Color;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(22),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: color.withValues(alpha: 0.15),
                  child: Icon(Icons.emergency_rounded, color: color, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        c['title_mr'],
                        style: GoogleFonts.mukta(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        c['category'],
                        style: GoogleFonts.mukta(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    c['desc'],
                    style: GoogleFonts.mukta(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (c['instructions'] != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'मार्गदर्शन: ${c['instructions']}',
                      style: GoogleFonts.mukta(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(ctx);
                _call(c['number']);
              },
              icon: const Icon(Icons.call_rounded, size: 20),
              label: Text('तात्काळ कॉल करा (${c['number']})'),
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
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
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: c['number']));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${c['number']} नंबर कॉपी केला!'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                      Navigator.pop(ctx);
                    },
                    icon: const Icon(Icons.copy_rounded, size: 16),
                    label: const Text('नंबर कॉपी करा'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _shareOnWhatsApp(c['title_mr'], c['number'], c['desc']);
                    },
                    icon: const Icon(Icons.share_rounded, size: 16, color: Color(0xFF25D366)),
                    label: const Text('शेअर करा'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
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
            elevation: 1.5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: AppColors.border),
            ),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => _showContactDetails(context, c),
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
                        foregroundColor: Colors.white,
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
            ),
          );
        },
      ),
    );
  }
}
