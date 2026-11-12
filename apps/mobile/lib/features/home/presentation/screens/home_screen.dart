import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nardana_connect/core/constants/app_colors.dart';
import 'package:nardana_connect/core/localization/app_localizations.dart';
import 'package:nardana_connect/features/village/providers/village_provider.dart';
import 'package:nardana_connect/features/advertisements/presentation/widgets/home_ad_carousel.dart';
import 'package:nardana_connect/features/advertisements/presentation/widgets/sponsored_ad_card.dart';
import 'package:nardana_connect/features/advertisements/providers/advertisement_provider.dart';
import 'package:nardana_connect/features/app_update/services/app_update_service.dart';
import 'package:nardana_connect/features/app_update/presentation/widgets/optional_update_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAppUpdates();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkAppUpdates(forceRefresh: true);
    }
  }

  Future<void> _checkAppUpdates({bool forceRefresh = false}) async {
    final result = await AppUpdateService.instance.checkUpdateStatus(forceRefresh: forceRefresh);
    if (!mounted) return;

    if (result.status == AppUpdateStatus.maintenanceMode && result.config != null) {
      context.go('/maintenance', extra: result.config);
      return;
    }

    if (result.status == AppUpdateStatus.forceUpdateRequired && result.config != null) {
      context.go('/force-update', extra: {
        'config': result.config,
        'installedVersion': result.installedVersion,
        'installedBuildNumber': result.installedBuildNumber,
      });
      return;
    }

    if (result.status == AppUpdateStatus.optionalUpdateAvailable && result.config != null) {
      OptionalUpdateDialog.show(
        context,
        config: result.config!,
        installedVersion: result.installedVersion,
        installedBuildNumber: result.installedBuildNumber,
      );
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'शुभ प्रभात!';
    if (hour < 17) return 'शुभ दुपार!';
    return 'शुभ संध्याकाळ!';
  }

  void _showNardanaProfileDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(
          children: [
            const Icon(Icons.location_on_rounded, color: AppColors.secondaryGreen, size: 24),
            const SizedBox(width: 8),
            Text(
              'नरडाणा गाव माहिती (Profile)',
              style: GoogleFonts.mukta(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDialogRow('अधिकृत गाव', 'नरडाणा (Nardana)'),
            const Divider(height: 14),
            _buildDialogRow('पिनकोड (PIN)', '४२५४०४'),
            const Divider(height: 14),
            _buildDialogRow('तालुका', 'शिंदखेडा (Shindkheda)'),
            const Divider(height: 14),
            _buildDialogRow('जिल्हा', 'धुळे (Dhule)'),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.secondaryGreen.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.secondaryGreen.withValues(alpha: 0.2)),
              ),
              child: Text(
                'नरडाणा कनेक्ट हे केवळ नरडाणा गावासाठीचे अधिकृत डिजिटल व्यासपीठ आहे.',
                style: GoogleFonts.mukta(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.secondaryGreen),
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue, foregroundColor: Colors.white),
            child: Text('समजले', style: GoogleFonts.mukta(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.mukta(fontSize: 13, color: AppColors.textSecondary)),
        Text(value, style: GoogleFonts.mukta(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
      ],
    );
  }

  Future<void> _makeCall(String number) async {
    final uri = Uri.parse('tel:$number');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final selectedVillage = ref.watch(selectedVillageProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        elevation: 0,
        titleSpacing: 16,
        title: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  'assets/images/app_logo.png',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.white,
                    child: Center(
                      child: Text(
                        'NC',
                        style: GoogleFonts.mukta(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n.translate('app_name'),
                      style: GoogleFonts.mukta(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '• ${_getGreeting()}',
                      style: GoogleFonts.mukta(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.accentYellow,
                      ),
                    ),
                  ],
                ),
                Text(
                  'आपलं गाव, आपली डिजिटल ओळख!',
                  style: GoogleFonts.mukta(
                    fontSize: 11,
                    color: AppColors.accentYellow,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: InkWell(
              onTap: () => _showNardanaProfileDialog(context),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.location_on_rounded,
                        color: AppColors.accentYellow, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      'नरडाणा (425404)',
                      style: GoogleFonts.mukta(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Search Bar
            Container(
              color: AppColors.primaryBlue,
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              child: InkWell(
                onTap: () => context.push('/search'),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search_rounded,
                          color: AppColors.textSecondary, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          l10n.translate('search_hint'),
                          style: GoogleFonts.mukta(
                            color: AppColors.textMuted,
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          selectedVillage.nameMr,
                          style: GoogleFonts.mukta(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Advertisement Carousel (Admin-Controlled, Realtime)
            const HomeAdCarousel(),

            const SizedBox(height: 14),

            // Emergency Quick Dial Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.emergencyRed,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        l10n.translate('emergency_services'),
                        style: GoogleFonts.mukta(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: () => context.push('/emergency'),
                    child: Text(
                      l10n.translate('view_all'),
                      style: GoogleFonts.mukta(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            SizedBox(
              height: 72,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildEmergencyButton(
                    title: 'पोलीस (112)',
                    color: Colors.blue.shade800,
                    icon: Icons.local_police_rounded,
                    onTap: () => _makeCall('112'),
                  ),
                  const SizedBox(width: 10),
                  _buildEmergencyButton(
                    title: 'रुग्णवाहिका (108)',
                    color: AppColors.emergencyRed,
                    icon: Icons.medical_services_rounded,
                    onTap: () => _makeCall('108'),
                  ),
                  const SizedBox(width: 10),
                  _buildEmergencyButton(
                    title: 'वीज तक्रार (1912)',
                    color: Colors.amber.shade800,
                    icon: Icons.electric_bolt_rounded,
                    onTap: () => _makeCall('1912'),
                  ),
                  const SizedBox(width: 10),
                  _buildEmergencyButton(
                    title: 'ग्रामपंचायत नरडाणा',
                    color: AppColors.secondaryGreen,
                    icon: Icons.account_balance_rounded,
                    onTap: () => _makeCall('02566258200'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Gram Panchayat Notice Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: InkWell(
                onTap: () {
                  context.push('/notice-detail', extra: {
                    'title_mr': 'पिण्याच्या पाण्याचे वेळापत्रक बदल',
                    'title_en': 'Drinking Water Supply Interruption Notice',
                    'desc_mr':
                        'नरडाणा ग्रामस्थांना कळविण्यात येते की पाईपलाईन दुरुस्तीच्या कामामुळे उद्या सकाळी ७ ते १० दरम्यानच पाणीपुरवठा केला जाईल. कृपया नोंद घ्यावी.',
                    'date': '१० नोव्हेंबर २०२६',
                    'authority': 'ग्रामपंचायत कार्यालय, नरडाणा',
                    'priority': 'high',
                    'is_official': true,
                  });
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primaryBlue.withValues(alpha: 0.06),
                        Colors.white,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.18)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.secondaryGreen,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'ग्रामपंचायत सूचना',
                              style: GoogleFonts.mukta(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const Spacer(),
                          const Icon(Icons.water_drop_rounded,
                              size: 16, color: Colors.blue),
                          const SizedBox(width: 4),
                          Text(
                            'पाणी पुरवठा वेळापत्रक',
                            style: GoogleFonts.mukta(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue.shade900,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(Icons.arrow_forward_ios_rounded,
                              size: 11, color: AppColors.primaryBlue),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'नरडाणा ग्रामस्थांना कळविण्यात येते की पाईपलाईन दुरुस्तीच्या कामामुळे उद्या सकाळी ७ ते १० दरम्यानच पाणीपुरवठा केला जाईल. (सविस्तर वाचण्यासाठी टॅप करा)',
                        style: GoogleFonts.mukta(
                          fontSize: 13,
                          color: AppColors.textPrimary,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),



            // Categories Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.translate('categories'),
                    style: GoogleFonts.mukta(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  InkWell(
                    onTap: () => context.push('/explore'),
                    child: Text(
                      l10n.translate('view_all'),
                      style: GoogleFonts.mukta(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Category Grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 4,
                mainAxisSpacing: 12,
                crossAxisSpacing: 10,
                childAspectRatio: 0.82,
                children: [
                  _buildCategoryItem(
                    icon: Icons.electric_meter_rounded,
                    title: 'इलेक्ट्रिशियन',
                    color: Colors.orange,
                    onTap: () => context.push('/explore', extra: {'category': 'इलेक्ट्रिशियन', 'group': 'home_services'}),
                  ),
                  _buildCategoryItem(
                    icon: Icons.plumbing_rounded,
                    title: 'प्लंबर',
                    color: Colors.blue,
                    onTap: () => context.push('/explore', extra: {'category': 'प्लंबर', 'group': 'home_services'}),
                  ),
                  _buildCategoryItem(
                    icon: Icons.shopping_cart_rounded,
                    title: 'किराणा',
                    color: Colors.green,
                    onTap: () => context.push('/explore', extra: {'category': 'किराणा', 'group': 'shops'}),
                  ),
                  _buildCategoryItem(
                    icon: Icons.local_pharmacy_rounded,
                    title: 'मेडिकल',
                    color: Colors.red,
                    onTap: () => context.push('/explore', extra: {'category': 'मेडिकल', 'group': 'health'}),
                  ),
                  _buildCategoryItem(
                    icon: Icons.agriculture_rounded,
                    title: 'ट्रॅक्टर भाड्याने',
                    color: Colors.teal,
                    onTap: () => context.push('/vehicles', extra: 'tractor'),
                  ),
                  _buildCategoryItem(
                    icon: Icons.print_rounded,
                    title: 'महा-ई-सेवा',
                    color: Colors.indigo,
                    onTap: () => context.push('/explore', extra: {'category': 'महा-ई-सेवा', 'group': 'digital'}),
                  ),
                  _buildCategoryItem(
                    icon: Icons.local_taxi_rounded,
                    title: 'गाडी / टॅक्सी',
                    color: Colors.deepOrange,
                    onTap: () => context.push('/vehicles', extra: 'all'),
                  ),
                  _buildCategoryItem(
                    icon: Icons.restaurant_rounded,
                    title: 'हॉटेल्स',
                    color: Colors.brown,
                    onTap: () => context.push('/explore', extra: {'category': 'हॉटेल्स', 'group': 'other'}),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Featured Shops Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.storefront_rounded, size: 18, color: AppColors.primaryBlue),
                      const SizedBox(width: 6),
                      Text(
                        'स्थानिक दुकाने व सेवा',
                        style: GoogleFonts.mukta(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: () => context.push('/explore'),
                    child: Text(
                      l10n.translate('view_all'),
                      style: GoogleFonts.mukta(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            SizedBox(
              height: 148,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildFeaturedShopCard(
                    context,
                    name: 'जय भवानी इलेक्ट्रिकल',
                    category: 'इलेक्ट्रिशियन',
                    village: 'नरडाणा',
                    owner: 'सचिन पाटील',
                    phone: '9823012345',
                    address: 'स्टेशन रोड, नरडाणा',
                    desc: 'घरगुती व शेती पंपाचे सर्व प्रकारचे वायरिंग व दुरुस्ती काम योग्य दरात.',
                    icon: Icons.electric_bolt_rounded,
                    color: Colors.orange.shade700,
                  ),
                  const SizedBox(width: 12),
                  _buildFeaturedShopCard(
                    context,
                    name: 'महालक्ष्मी किराणा',
                    category: 'किराणा दुकान',
                    village: 'नरडाणा',
                    owner: 'प्रमोद महाजन',
                    phone: '9422054321',
                    address: 'मेन बाजारपेठ, नरडाणा',
                    desc: 'सर्व प्रकारचा दर्जेदार किराणा, कडधान्ये व घरगुती वस्तू.',
                    icon: Icons.shopping_basket_rounded,
                    color: Colors.green.shade700,
                  ),
                  const SizedBox(width: 12),
                  _buildFeaturedShopCard(
                    context,
                    name: 'धनवंतरी मेडिकल',
                    category: 'औषध स्टोअर्स',
                    village: 'नरडाणा',
                    owner: 'डॉ. भूषण पाटील',
                    phone: '9890123456',
                    address: 'ग्रामीण रुग्णालयासमोर, नरडाणा',
                    desc: 'सर्व ॲलोपॅथिक, व्हेटरनरी व लहान मुलांची औषधे वाजवी दरात.',
                    icon: Icons.local_pharmacy_rounded,
                    color: Colors.red.shade700,
                  ),
                  const SizedBox(width: 12),
                  _buildFeaturedShopCard(
                    context,
                    name: 'किसान ट्रॅक्टर सर्व्हिस',
                    category: 'शेती अवजारे',
                    village: 'नरडाणा',
                    owner: 'दिनेश चौधरी',
                    phone: '9765432100',
                    address: 'हायवे चौक, नरडाणा',
                    desc: 'नांगरणी, रोटाव्हेटर आणि पेरणीसाठी महिंद्रा ट्रॅक्टर वेळेवर उपलब्ध.',
                    icon: Icons.agriculture_rounded,
                    color: Colors.teal.shade700,
                  ),
                ],
              ),
            ),

            // Sponsored Advertisements Section (Admin-Controlled)
            Consumer(
              builder: (context, ref, child) {
                final sponsoredAsync = ref.watch(sponsoredAdsProvider);
                return sponsoredAsync.when(
                  data: (sponsoredAds) {
                    if (sponsoredAds.isEmpty) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.campaign_rounded, size: 18, color: AppColors.accentYellow),
                              const SizedBox(width: 6),
                              Text(
                                'नरडाणा विशेष जाहिराती (Sponsored)',
                                style: GoogleFonts.mukta(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ...sponsoredAds.map((ad) => Padding(
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: SponsoredAdCard(ad: ad),
                              )),
                        ],
                      ),
                    );
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (e, s) => const SizedBox.shrink(),
                );
              },
            ),

            const SizedBox(height: 14),

            // Vehicle Rental Section (गाडी भाड्याने मिळेल - Nardana Special)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.car_rental_rounded, size: 20, color: AppColors.primaryBlue),
                      const SizedBox(width: 6),
                      Text(
                        'गाडी भाड्याने मिळेल',
                        style: GoogleFonts.mukta(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: () => context.push('/vehicles'),
                    child: Text(
                      l10n.translate('view_all'),
                      style: GoogleFonts.mukta(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Vehicle Quick Slider
            SizedBox(
              height: 130,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildVehicleQuickCard(
                    context,
                    title: 'अर्टिगा (७ सीटर)',
                    desc: 'कौटुंबिक प्रवास / AC',
                    driver: 'कैलास पाटील (९४२१८८९९०१)',
                    status: 'उपलब्ध',
                    icon: Icons.airport_shuttle_rounded,
                    color: Colors.blue.shade700,
                    onTap: () => context.push('/vehicles', extra: 'ertiga'),
                  ),
                  const SizedBox(width: 12),
                  _buildVehicleQuickCard(
                    context,
                    title: 'पिकअप / छोटा हत्ती',
                    desc: '१.५ टन मालवाहतूक',
                    driver: 'सचिन माळी (९८२३०१२३४४)',
                    status: 'उपलब्ध',
                    icon: Icons.local_shipping_rounded,
                    color: Colors.deepOrange.shade700,
                    onTap: () => context.push('/vehicles', extra: 'pickup'),
                  ),
                  const SizedBox(width: 12),
                  _buildVehicleQuickCard(
                    context,
                    title: 'महिंद्रा ट्रॅक्टर',
                    desc: 'रोटाव्हेटर / नांगरणी',
                    driver: 'दिनेश चौधरी (९७६५४३२१०१)',
                    status: 'उपलब्ध',
                    icon: Icons.agriculture_rounded,
                    color: Colors.teal.shade700,
                    onTap: () => context.push('/vehicles', extra: 'tractor'),
                  ),
                  const SizedBox(width: 12),
                  _buildVehicleQuickCard(
                    context,
                    title: 'जेसीबी (JCB 3DX)',
                    desc: 'खोदकाम व सपाटीकरण',
                    driver: 'अमोल सूर्यवंशी (९८२२३३४४५६)',
                    status: 'उपलब्ध',
                    icon: Icons.construction_rounded,
                    color: Colors.amber.shade900,
                    onTap: () => context.push('/vehicles', extra: 'jcb'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Jobs and Marketplace Banner Cards
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => context.push('/jobs'),
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primaryBlue.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.work_outline_rounded,
                                  color: AppColors.primaryBlue, size: 20),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'रोजगार (Jobs)',
                                    style: GoogleFonts.mukta(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    'स्थानिक नोकऱ्या',
                                    style: GoogleFonts.mukta(
                                      fontSize: 11,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: () => context.push('/marketplace'),
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.secondaryGreen.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.shopping_bag_outlined,
                                  color: AppColors.secondaryGreen, size: 20),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'खरेदी - विक्री',
                                    style: GoogleFonts.mukta(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    'स्थानिक बाजारपेठ',
                                    style: GoogleFonts.mukta(
                                      fontSize: 11,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyButton({
    required String title,
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: color,
              child: Icon(icon, size: 14, color: Colors.white),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: GoogleFonts.mukta(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryItem({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: color.withValues(alpha: 0.12),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.mukta(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedShopCard(
    BuildContext context, {
    required String name,
    required String category,
    required String village,
    required String owner,
    required String phone,
    required String address,
    required String desc,
    required IconData icon,
    required Color color,
  }) {
    return InkWell(
      onTap: () {
        context.push('/business-detail', extra: {
          'name_mr': name,
          'category': category,
          'village': village,
          'owner': owner,
          'phone': phone,
          'address': address,
          'desc': desc,
          'opening_hours': 'सकाळी ९:०० ते रात्री ८:००',
        });
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 175,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: color.withValues(alpha: 0.12),
                  child: Icon(icon, size: 18, color: color),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    village,
                    style: GoogleFonts.mukta(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.mukta(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
                height: 1.2,
              ),
            ),
            Text(
              category,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.mukta(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.secondaryGreen,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.person_outline_rounded, size: 12, color: AppColors.textMuted),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    owner,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.mukta(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                Text(
                  'पहा →',
                  style: GoogleFonts.mukta(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBlue,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleQuickCard(
    BuildContext context, {
    required String title,
    required String desc,
    required String driver,
    required String status,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 190,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CircleAvatar(
                  radius: 15,
                  backgroundColor: color.withValues(alpha: 0.12),
                  child: Icon(icon, size: 16, color: color),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    status,
                    style: GoogleFonts.mukta(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF15803D),
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.mukta(
                fontSize: 13.5,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
                height: 1.2,
              ),
            ),
            Text(
              desc,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.mukta(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.secondaryGreen,
              ),
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Expanded(
                  child: Text(
                    driver,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.mukta(fontSize: 10.5, color: AppColors.textSecondary),
                  ),
                ),
                Text(
                  'कॉल →',
                  style: GoogleFonts.mukta(fontSize: 10.5, fontWeight: FontWeight.bold, color: AppColors.primaryBlue),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
