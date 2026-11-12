import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:nardana_connect/core/constants/app_colors.dart';
import 'package:nardana_connect/core/navigation/app_back_scope.dart';
import 'package:nardana_connect/core/navigation/back_button_handler.dart';
import 'package:nardana_connect/features/updates/models/village_update_model.dart';
import 'package:nardana_connect/features/updates/services/village_updates_service.dart';

class VillageUpdatesScreen extends StatefulWidget {
  final String? initialCategory;

  const VillageUpdatesScreen({super.key, this.initialCategory});

  @override
  State<VillageUpdatesScreen> createState() => _VillageUpdatesScreenState();
}

class _VillageUpdatesScreenState extends State<VillageUpdatesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<VillageUpdateModel> _allUpdates = [];
  bool _isLoading = true;
  String _selectedCategory = 'all';

  final List<Map<String, String>> _categories = const [
    {'key': 'all', 'label': 'सर्व घडामोडी', 'icon': '✨'},
    {'key': 'kirtan_bhajan', 'label': 'कीर्तन / भजन', 'icon': '🚩'},
    {'key': 'festival', 'label': 'सण व उत्सव', 'icon': '🎪'},
    {'key': 'health_camp', 'label': 'आरोग्य शिबीर', 'icon': '🏥'},
    {'key': 'school_education', 'label': 'शाळा व प्रवेश', 'icon': '🏫'},
    {'key': 'shop_opening', 'label': 'दुकान उद्घाटन', 'icon': '🎉'},
    {'key': 'announcement', 'label': 'जाहीर सूचना', 'icon': '📢'},
    {'key': 'cultural', 'label': 'सांस्कृतिक', 'icon': '🎭'},
    {'key': 'invitation', 'label': 'निमंत्रण सोहळा', 'icon': '💌'},
    {'key': 'village_news', 'label': 'बातम्या', 'icon': '📰'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    if (widget.initialCategory != null && widget.initialCategory!.isNotEmpty) {
      _selectedCategory = widget.initialCategory!;
    }
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final data = await VillageUpdatesService.instance.getPublishedUpdates();
    if (mounted) {
      setState(() {
        _allUpdates = data;
        _isLoading = false;
      });
    }
  }

  Future<void> _callOrganizer(String number) async {
    final uri = Uri.parse('tel:$number');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _openDirections(double lat, double lng) async {
    final uri = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$lat,$lng');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _shareOnWhatsApp(VillageUpdateModel item) async {
    final message = '''
*${item.categoryIcon} ${item.titleMr}*
📍 ठिकाण: ${item.venueMr ?? 'नरडाणा'}
📅 दिनांक: ${item.eventDate ?? ''} ${item.eventTime ?? ''}
👤 आयोजक: ${item.organizerName ?? 'नरडाणा ग्रामस्थ'}

${item.descriptionMr}

👉 नरडाणा गावातील सर्व घडामोडी पाहण्यासाठी Nardana Connect ॲप डाऊनलोड करा:
https://nardana-connect.vercel.app/download.html
''';
    final url = Uri.parse('https://wa.me/?text=${Uri.encodeComponent(message)}');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  void _shareNative(VillageUpdateModel item) {
    final message = '''
${item.categoryIcon} ${item.titleMr}
ठिकाण: ${item.venueMr ?? 'नरडाणा'}
दिनांक: ${item.eventDate ?? ''} ${item.eventTime ?? ''}
आयोजक: ${item.organizerName ?? 'नरडाणा ग्रामस्थ'}

${item.descriptionMr}

Nardana Connect ॲप: https://nardana-connect.vercel.app/download.html
''';
    SharePlus.instance.share(ShareParams(text: message, subject: item.titleMr));
  }

  List<VillageUpdateModel> _filterList(int tabIndex) {
    var filtered = _allUpdates;
    if (_selectedCategory != 'all') {
      filtered = filtered.where((u) => u.category == _selectedCategory).toList();
    }

    if (tabIndex == 0) {
      // Upcoming
      return filtered.where((u) => u.isUpcoming).toList();
    } else if (tabIndex == 1) {
      // Past
      return filtered.where((u) => !u.isUpcoming).toList();
    }
    // All
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return AppBackScope(
      fallbackRoute: '/home',
      child: Scaffold(
        backgroundColor: AppColors.surface,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => BackButtonHandler.safePop(context, fallbackRoute: '/home'),
          ),
          title: Text(
            'गावातील नवीन घडामोडी',
            style: GoogleFonts.mukta(fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              onPressed: _loadData,
              tooltip: 'रीफ्रेश',
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: AppColors.accentYellow,
            indicatorWeight: 3,
            labelStyle: GoogleFonts.mukta(fontWeight: FontWeight.bold, fontSize: 14),
            unselectedLabelStyle: GoogleFonts.mukta(fontWeight: FontWeight.w600, fontSize: 13),
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: const [
              Tab(text: 'आगामी कार्यक्रम'),
              Tab(text: 'झालेले कार्यक्रम'),
              Tab(text: 'सर्व घडामोडी'),
            ],
          ),
        ),
        body: Column(
          children: [
            // Category Filter Chips Carousel
            Container(
              height: 48,
              padding: const EdgeInsets.symmetric(vertical: 6),
              color: Colors.white,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                itemCount: _categories.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, idx) {
                  final cat = _categories[idx];
                  final isSelected = _selectedCategory == cat['key'];
                  return ChoiceChip(
                    label: Text('${cat['icon']} ${cat['label']}'),
                    selected: isSelected,
                    labelStyle: GoogleFonts.mukta(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                    ),
                    selectedColor: AppColors.primaryBlue,
                    backgroundColor: Colors.grey.shade100,
                    showCheckmark: false,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: isSelected ? AppColors.primaryBlue : Colors.grey.shade300,
                      ),
                    ),
                    onSelected: (val) {
                      setState(() {
                        _selectedCategory = cat['key']!;
                      });
                    },
                  );
                },
              ),
            ),
            const Divider(height: 1),

            // Tab Views List
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _buildUpdatesList(0),
                        _buildUpdatesList(1),
                        _buildUpdatesList(2),
                      ],
                    ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => context.push('/submit-update'),
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add_circle_outline_rounded, size: 20),
          label: Text(
            'नवीन घडामोड पाठवा',
            style: GoogleFonts.mukta(fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ),
      ),
    );
  }

  Widget _buildUpdatesList(int tabIndex) {
    final list = _filterList(tabIndex);

    if (list.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.event_busy_rounded, size: 54, color: Colors.grey.shade400),
              const SizedBox(height: 12),
              Text(
                tabIndex == 0
                    ? 'या प्रवर्गात आगामी कार्यक्रम नाहीत.'
                    : tabIndex == 1
                    ? 'झालेले कार्यक्रम सापडले नाहीत.'
                    : 'कोणत्याही नोंदी उपलब्ध नाहीत.',
                style: GoogleFonts.mukta(color: AppColors.textSecondary, fontSize: 15),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 80),
        itemCount: list.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = list[index];
          return _buildUpdateCard(item);
        },
      ),
    );
  }

  Widget _buildUpdateCard(VillageUpdateModel item) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.border.withValues(alpha: 0.8)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/update-detail', extra: item),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Poster Image (if available)
            if (item.posterUrl != null && item.posterUrl!.isNotEmpty)
              Stack(
                children: [
                  CachedNetworkImage(
                    imageUrl: item.posterUrl!,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      height: 150,
                      color: Colors.grey.shade200,
                      child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 150,
                      color: Colors.grey.shade100,
                      child: Center(
                        child: Text(item.categoryIcon, style: const TextStyle(fontSize: 48)),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.75),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(item.categoryIcon, style: const TextStyle(fontSize: 12)),
                          const SizedBox(width: 4),
                          Text(
                            item.categoryLabel,
                            style: GoogleFonts.mukta(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (item.eventDate != null)
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Text(
                          item.eventDate!,
                          style: GoogleFonts.mukta(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),

            // Card Body Content
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (item.posterUrl == null || item.posterUrl!.isEmpty)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: item.categoryColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${item.categoryIcon} ${item.categoryLabel}',
                            style: GoogleFonts.mukta(
                              color: item.categoryColor,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (item.eventDate != null)
                          Text(
                            item.eventDate!,
                            style: GoogleFonts.mukta(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryBlue,
                            ),
                          ),
                      ],
                    ),

                  const SizedBox(height: 6),

                  // Title
                  Text(
                    item.titleMr,
                    style: GoogleFonts.mukta(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      height: 1.25,
                    ),
                  ),

                  const SizedBox(height: 6),

                  // Description snippet
                  Text(
                    item.descriptionMr,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.mukta(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.35,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Event Info Row (Date/Time, Venue)
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      children: [
                        if (item.eventTime != null && item.eventTime!.isNotEmpty)
                          Row(
                            children: [
                              const Icon(Icons.access_time_rounded, size: 14, color: AppColors.primaryBlue),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  'वेळ: ${item.eventTime}',
                                  style: GoogleFonts.mukta(fontSize: 12, color: AppColors.textPrimary),
                                ),
                              ),
                            ],
                          ),
                        if (item.venueMr != null && item.venueMr!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.location_on_rounded, size: 14, color: Colors.red),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  'स्थळ: ${item.venueMr}',
                                  style: GoogleFonts.mukta(fontSize: 12, color: AppColors.textPrimary),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Action Buttons: Directions, WhatsApp Share, Call
                  Row(
                    children: [
                      // Google Maps Directions (if GPS available)
                      if (item.hasValidGps) ...[
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _openDirections(item.latitude!, item.longitude!),
                            icon: const Icon(Icons.directions_rounded, size: 16, color: AppColors.primaryBlue),
                            label: Text(
                              'दिशामार्ग',
                              style: GoogleFonts.mukta(fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primaryBlue,
                              side: const BorderSide(color: AppColors.primaryBlue),
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                      ],

                      // WhatsApp Share
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _shareOnWhatsApp(item),
                          icon: const Icon(Icons.chat_rounded, size: 16),
                          label: Text(
                            'शेअर करा',
                            style: GoogleFonts.mukta(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.secondaryGreen,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),

                      const SizedBox(width: 6),

                      // Native Share Icon Button
                      IconButton(
                        onPressed: () => _shareNative(item),
                        icon: const Icon(Icons.share_rounded, size: 18, color: AppColors.textSecondary),
                        tooltip: 'शेअर',
                      ),

                      // Call Organizer (if number provided)
                      if (item.organizerContact != null && item.organizerContact!.isNotEmpty)
                        IconButton(
                          onPressed: () => _callOrganizer(item.organizerContact!),
                          icon: const Icon(Icons.phone_in_talk_rounded, size: 18, color: AppColors.primaryBlue),
                          tooltip: 'कॉल करा',
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

