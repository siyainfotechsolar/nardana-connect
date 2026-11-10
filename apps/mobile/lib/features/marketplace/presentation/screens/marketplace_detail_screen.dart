import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:nardana_connect/core/constants/app_colors.dart';
import 'package:nardana_connect/core/navigation/app_back_scope.dart';
import 'package:nardana_connect/core/navigation/back_button_handler.dart';

class MarketplaceDetailScreen extends StatelessWidget {
  final Map<String, dynamic> item;

  const MarketplaceDetailScreen({super.key, required this.item});

  Future<void> _call(String number) async {
    final clean = number.replaceAll(RegExp(r'[^0-9]'), '');
    final uri = Uri.parse('tel:$clean');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _openWhatsApp(String number, String itemTitle, String price) async {
    final clean = number.replaceAll(RegExp(r'[^0-9]'), '');
    final phone = clean.startsWith('91') ? clean : '91$clean';
    final text = Uri.encodeComponent(
      'नमस्कार, मी नरडाणा कनेक्ट ॲपवर आपल्या "$itemTitle" ($price) या वस्तूची नोंदणी पाहिली. मला या खरेदीबद्दल चर्चा करायची आहे.',
    );
    final uri = Uri.parse('https://wa.me/$phone?text=$text');
    if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _shareOnWhatsApp(String title, String price, String category, String seller, String phone) async {
    final text = Uri.encodeComponent(
      '🛍️ *नरडाणा बाजारपेठ (खरेदी - विक्री)*\n\n'
      '📦 *वस्तू:* $title\n'
      '🏷️ *प्रवर्ग:* $category\n'
      '💰 *किंमत:* $price\n'
      '👤 *विक्रेता:* $seller (नरडाणा)\n'
      '📞 *संपर्क:* $phone\n\n'
      'अधिक माहितीसाठी *नरडाणा कनेक्ट* ॲप डाऊनलोड करा:\n'
      'https://nardana-connect.vercel.app/download.html',
    );
    final uri = Uri.parse('https://wa.me/?text=$text');
    if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final title = item['title'] ?? 'बाजारपेठ वस्तू';
    final category = item['category'] ?? 'सामान्य';
    final price = item['price'] != null ? item['price'].toString() : 'वाजवी दर';
    final seller = item['seller'] ?? item['seller_name'] ?? 'स्थानिक गावकरी';
    final phone = item['phone'] ?? item['contact_phone'] ?? '';
    final village = item['village'] ?? 'नरडाणा';
    final isSell = (item['type'] ?? item['listing_type']) == 'SELL';
    final desc = item['desc'] ?? item['description'] ?? 'ही वस्तू नरडाणा गावात थेट विक्रीसाठी उपलब्ध आहे.';
    final imageUrl = item['image_url'] as String?;

    return AppBackScope(
      fallbackRoute: '/marketplace',
      child: Scaffold(
        backgroundColor: AppColors.surface,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => BackButtonHandler.safePop(context, fallbackRoute: '/marketplace'),
          ),
        title: Text(
          'वस्तू तपशील',
          style: GoogleFonts.mukta(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded, color: Colors.white),
            tooltip: 'व्हॉट्सॲपवर शेअर करा',
            onPressed: () => _shareOnWhatsApp(title, price, category, seller, phone),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image or Default Icon Banner
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: imageUrl != null && imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
                    )
                  : _buildPlaceholder(),
            ),

            const SizedBox(height: 16),

            // Main Info Card
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isSell
                                ? AppColors.primaryBlue.withValues(alpha: 0.1)
                                : AppColors.accentYellow.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            isSell ? 'विक्रीसाठी (SELL)' : 'खरेदी करायचे आहे (WANTED)',
                            style: GoogleFonts.mukta(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isSell ? AppColors.primaryBlue : Colors.amber.shade900,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            category,
                            style: GoogleFonts.mukta(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      title,
                      style: GoogleFonts.mukta(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Text(
                          'किंमत / अपेक्षित दर:',
                          style: GoogleFonts.mukta(
                            fontSize: 13,
                            color: AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          price.startsWith('₹') ? price : '₹$price',
                          style: GoogleFonts.mukta(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Seller Details Card
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
                      'विक्रेता / संपर्क माहिती',
                      style: GoogleFonts.mukta(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.1),
                          child: const Icon(Icons.person_rounded, color: AppColors.primaryBlue),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                seller,
                                style: GoogleFonts.mukta(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                'स्थान: $village (पिन: ४२५४०४)',
                                style: GoogleFonts.mukta(
                                  fontSize: 12,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Description Card
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
                      'वस्तूचे वर्णन (Description)',
                      style: GoogleFonts.mukta(
                        fontSize: 15,
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

            // Safe Trading Notice
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.security_rounded, size: 20, color: Colors.amber.shade900),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'सुरक्षित व्यवहार सूचना: नरडाणा कनेक्ट हे थेट स्थानिक व्यासपीठ आहे. वस्तू प्रत्यक्ष पाहून व खात्री करूनच खरेदी करा. ऑनलाईन आगाऊ पैसे पाठवू नका.',
                      style: GoogleFonts.mukta(
                        fontSize: 11,
                        color: Colors.amber.shade900,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Contact CTA
            if (phone.isNotEmpty) ...[
              ElevatedButton.icon(
                onPressed: () => _call(phone),
                icon: const Icon(Icons.call_rounded, size: 20),
                label: Text('विक्रेत्याशी बोला ($phone)'),
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
                onPressed: () => _openWhatsApp(phone, title, price),
                icon: const Icon(Icons.chat_rounded, size: 20, color: Color(0xFF25D366)),
                label: const Text('व्हॉट्सॲपवर मेसेज करा'),
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
    ),
  );
}

  Widget _buildPlaceholder() {
    return Container(
      color: AppColors.primaryBlue.withValues(alpha: 0.05),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 36,
              backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.1),
              child: const Icon(
                Icons.shopping_bag_rounded,
                size: 38,
                color: AppColors.primaryBlue,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'नरडाणा स्थानिक बाजारपेठ',
              style: GoogleFonts.mukta(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
