import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nardana_connect/core/constants/app_colors.dart';
import 'package:nardana_connect/core/navigation/app_back_scope.dart';

class ElectionScreen extends StatelessWidget {
  const ElectionScreen({super.key});

  final List<Map<String, dynamic>> _candidates = const [
    {
      'id': '1',
      'name': 'दिलीप आनंदा पाटील',
      'ward': 'प्रभाग क्र. १ (वॉर्ड १)',
      'symbol': 'कमळ / चिन्ह अ',
      'education': 'बी.ए. (B.A.)',
      'age': '४६ वर्ष',
      'agenda': 'नरडाणा गावातील पाणी पुरवठा योजना नियमित करणे व नवीन सिमेंट रस्ते बांधणे.',
      'phone': '9822011223',
    },
    {
      'id': '2',
      'name': 'अनिता सुनील चौधरी',
      'ward': 'प्रभाग क्र. २ (वॉर्ड २)',
      'symbol': 'शिट्टी / चिन्ह ब',
      'education': '१२ वी उत्तीर्ण',
      'age': '३८ वर्ष',
      'agenda': 'महिला बचत गटांना बळकटी देणे आणि प्राथमिक आरोग्य केंद्रात २४ तास रुग्णवाहिका सेवा सुरू करणे.',
      'phone': '9421556677',
    },
    {
      'id': '3',
      'name': 'सुरेश काशिनाथ माळी',
      'ward': 'प्रभाग क्र. ३ (वॉर्ड ३)',
      'symbol': 'विमान / चिन्ह क',
      'education': 'डी.एड. (D.Ed.)',
      'age': '५२ वर्ष',
      'agenda': 'गावातील सांडपाणी व्यवस्थापन, कचरा व्यवस्थापन व शेतकरी सेवा केंद्र सक्षम करणे.',
      'phone': '9890887766',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return AppBackScope(
      fallbackRoute: '/home',
      child: Scaffold(
        backgroundColor: AppColors.surface,
        appBar: AppBar(
          title: Text('ग्रामपंचायत निवडणूक व उमेदवार', style: GoogleFonts.mukta(fontWeight: FontWeight.bold)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => context.go('/home'),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.how_to_vote_rounded, color: AppColors.primaryBlue, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'नरडाणा ग्रामपंचायत निवडणूक निर्देशिका',
                          style: GoogleFonts.mukta(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.primaryBlue),
                        ),
                        Text(
                          'आपल्या प्रभागातील उमेदवारांची पार्श्वभूमी व जाहीरनामा पहा.',
                          style: GoogleFonts.mukta(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
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
          ],
        ),
      ),
    );
  }
}
