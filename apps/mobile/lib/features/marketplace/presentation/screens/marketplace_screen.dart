import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:nardana_connect/core/constants/app_colors.dart';
import 'package:nardana_connect/core/localization/app_localizations.dart';

class MarketplaceScreen extends StatelessWidget {
  const MarketplaceScreen({super.key});

  final List<Map<String, dynamic>> _sampleItems = const [
    {
      'title': 'रोटाव्हेटर अवजार (शेतीसाठी)',
      'price': '48,000',
      'category': 'शेती अवजारे',
      'seller': 'सतीश गिरासे',
      'phone': '9822114455',
      'village': 'नरडाणा',
      'type': 'SELL',
      'desc': 'उत्कृष्ट स्थितीतील शक्तीमान ५ फूट रोटाव्हेटर अवजार विक्रीस उपलब्ध. नवीन ब्लेड्स बसवलेले आहेत.',
    },
    {
      'title': 'हिरो स्प्लेंडर प्लस (२०२२ मॉडेल)',
      'price': '42,000',
      'category': 'टू व्हीलर',
      'seller': 'सचिन महाजन',
      'phone': '9923445566',
      'village': 'नरडाणा',
      'type': 'SELL',
      'desc': 'एकाच हाताने चालवलेली गाडी, उत्तम मायलेज व सर्व कागदपत्रे पूर्ण.',
    },
    {
      'title': 'गाय / म्हशीचे वासरू हवे आहे',
      'price': 'वाजवी दर',
      'category': 'पशूधन',
      'seller': 'रविंद्र पाटील',
      'phone': '9890556677',
      'village': 'नरडाणा',
      'type': 'WANTED',
      'desc': 'गावरान किंवा गीर जातीचे निरोगी वासरू खरेदी करावयाचे आहे.',
    },
    {
      'title': 'सोयाबीन बियाणे (फुले संगम)',
      'price': '3,800 / बॅग',
      'category': 'बियाणे व खते',
      'seller': 'गजानन कृषी सेवा',
      'phone': '9421526400',
      'village': 'नरडाणा',
      'type': 'SELL',
      'desc': 'प्रमाणित फुले संगम ७२६ सोयाबीन बियाणे उपलब्ध. उच्च उगवण क्षमता.',
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
        title: Text(l10n.translate('buy_sell')),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _sampleItems.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = _sampleItems[index];
          final isSell = item['type'] == 'SELL';
          final priceStr = item['price'].toString().startsWith('₹')
              ? item['price'].toString()
              : '₹${item['price']}';

          return Card(
            elevation: 1.5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: AppColors.border),
            ),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => context.push('/marketplace-detail', extra: item),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: isSell
                                ? AppColors.primaryBlue.withValues(alpha: 0.1)
                                : AppColors.accentYellow.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            isSell ? 'विक्री (SELL)' : 'हवे आहे (WANTED)',
                            style: GoogleFonts.mukta(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isSell
                                  ? AppColors.primaryBlue
                                  : Colors.amber.shade900,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          item['category'],
                          style: GoogleFonts.mukta(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          priceStr,
                          style: GoogleFonts.mukta(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item['title'],
                      style: GoogleFonts.mukta(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item['desc'],
                      style: GoogleFonts.mukta(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.person_outline_rounded,
                            size: 14, color: AppColors.textMuted),
                        const SizedBox(width: 4),
                        Text(
                          '${item['seller']} (${item['village']})',
                          style: GoogleFonts.mukta(
                            fontSize: 12,
                            color: AppColors.textMuted,
                          ),
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            Text(
                              'तपशील पहा',
                              style: GoogleFonts.mukta(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryBlue,
                              ),
                            ),
                            const SizedBox(width: 2),
                            const Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 11,
                              color: AppColors.primaryBlue,
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _call(item['phone']),
                            icon: const Icon(Icons.call_rounded, size: 16),
                            label: Text('कॉल करा (${item['phone']})'),
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
                          onPressed: () => context.push('/marketplace-detail', extra: item),
                          icon: const Icon(Icons.visibility_rounded, size: 15),
                          label: const Text('तपशील'),
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
