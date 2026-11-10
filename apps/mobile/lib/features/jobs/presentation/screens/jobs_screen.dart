import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:nardana_connect/core/constants/app_colors.dart';
import 'package:nardana_connect/core/localization/app_localizations.dart';

class JobsScreen extends StatelessWidget {
  const JobsScreen({super.key});

  final List<Map<String, dynamic>> _sampleJobs = const [
    {
      'title': 'दुकान सहाय्यक / सेल्समन',
      'company': 'महालक्ष्मी सुपर किराणा, नरडाणा',
      'salary': '₹8,000 - ₹12,000 / महिना',
      'qualification': '१० वी / १२ वी पास',
      'type': 'Full-time',
      'location': 'मेन बाजारपेठ, नरडाणा',
      'phone': '9422054321',
      'desc': 'किराणा दुकानात सामान हाताळणी व बिलिंग कामासाठी स्थानिक तरुणाची आवश्यकता.',
    },
    {
      'title': 'अनुभवी ट्रॅक्टर चालक',
      'company': 'किसान ॲग्रो सर्व्हिसेस',
      'salary': '₹12,000 - ₹16,000 + दैनंदिन भत्ता',
      'qualification': 'ट्रॅक्टर ड्रायव्हिंग लायसन्स',
      'type': 'Full-time',
      'location': 'हायवे रोड, नरडाणा',
      'phone': '9765432100',
      'desc': 'शेतीच्या हंगामात रोटाव्हेटर व नांगरणीसाठी अनुभवी चालकाची आवश्यकता.',
    },
    {
      'title': 'संगणक ऑपरेटर (CSC Center)',
      'company': 'आपले सरकार सेवा केंद्र',
      'salary': '₹9,000 - ₹14,000 / महिना',
      'qualification': 'MS-CIT, मराठी व इंग्रजी टायपिंग',
      'type': 'Full-time',
      'location': 'बस स्टँड जवळ, नरडाणा',
      'phone': '9970112233',
      'desc': 'ऑनलाईन शासकीय फॉर्म भरणे, ७/१२ काढणे व झेरॉक्स कामासाठी.',
    },
    {
      'title': 'वेल्डिंग व फॅब्रिकेशन कारागीर',
      'company': 'जय बजरंग फॅब्रिकेशन वर्कशॉप',
      'salary': '₹10,000 - ₹15,000 / महिना',
      'qualification': 'वेल्डिंग काम अनुभव (किमान १ वर्ष)',
      'type': 'Full-time',
      'location': 'स्टेशन रोड, नरडाणा',
      'phone': '9822334455',
      'desc': 'लोखंडी गेट, ग्रील व शेती अवजारे वेल्डिंगसाठी कारागीर हवा आहे.',
    },
  ];

  Future<void> _call(String number) async {
    final clean = number.replaceAll(RegExp(r'[^0-9]'), '');
    final uri = Uri.parse('tel:$clean');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text(l10n.translate('jobs')),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _sampleJobs.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final j = _sampleJobs[index];
          return Card(
            elevation: 1.5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: AppColors.border),
            ),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => context.push('/job-detail', extra: j),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            j['title'],
                            style: GoogleFonts.mukta(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.primaryBlue.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                j['type'],
                                style: GoogleFonts.mukta(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryBlue,
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
                      ],
                    ),
                    Text(
                      j['company'],
                      style: GoogleFonts.mukta(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.secondaryGreen,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      j['desc'],
                      style: GoogleFonts.mukta(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.currency_rupee_rounded,
                            size: 15, color: AppColors.primaryBlue),
                        const SizedBox(width: 4),
                        Text(
                          j['salary'],
                          style: GoogleFonts.mukta(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                        const Spacer(),
                        const Icon(Icons.location_on_outlined,
                            size: 14, color: AppColors.textMuted),
                        const SizedBox(width: 4),
                        Text(
                          j['location'],
                          style: GoogleFonts.mukta(
                            fontSize: 12,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _call(j['phone']),
                            icon: const Icon(Icons.call_rounded, size: 16),
                            label: Text('कॉल (${j['phone']})'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.secondaryGreen,
                              foregroundColor: Colors.white,
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
                        OutlinedButton.icon(
                          onPressed: () => context.push('/job-detail', extra: j),
                          icon: const Icon(Icons.visibility_rounded, size: 15),
                          label: const Text('तपशील पहा'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primaryBlue,
                            side: const BorderSide(color: AppColors.primaryBlue),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            textStyle: GoogleFonts.mukta(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
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
    );
  }
}
