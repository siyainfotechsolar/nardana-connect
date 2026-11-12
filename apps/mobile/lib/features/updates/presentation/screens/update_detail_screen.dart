import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:nardana_connect/core/constants/app_colors.dart';
import 'package:nardana_connect/core/navigation/app_back_scope.dart';
import 'package:nardana_connect/core/navigation/back_button_handler.dart';
import '../../models/village_update_model.dart';
import '../../services/village_updates_service.dart';

class UpdateDetailScreen extends StatefulWidget {
  final VillageUpdateModel? update;
  final String? eventId;

  const UpdateDetailScreen({
    super.key,
    this.update,
    this.eventId,
  });

  @override
  State<UpdateDetailScreen> createState() => _UpdateDetailScreenState();
}

class _UpdateDetailScreenState extends State<UpdateDetailScreen> {
  VillageUpdateModel? _update;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.update != null) {
      _update = widget.update;
    } else if (widget.eventId != null && widget.eventId!.isNotEmpty) {
      _fetchUpdateById(widget.eventId!);
    } else {
      _errorMessage = 'माहिती सापडली नाही.';
    }
  }

  Future<void> _fetchUpdateById(String id) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final data = await VillageUpdatesService.instance.getUpdateById(id);
    if (mounted) {
      setState(() {
        _isLoading = false;
        if (data != null) {
          _update = data;
        } else {
          _errorMessage = 'सदर घडामोड किंवा कार्यक्रम उपलब्ध नाही.';
        }
      });
    }
  }

  Future<void> _callOrganizer(String number) async {
    final clean = number.replaceAll(RegExp(r'[^0-9]'), '');
    final uri = Uri.parse('tel:$clean');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _chatOnWhatsApp(String number, String title) async {
    final clean = number.replaceAll(RegExp(r'[^0-9]'), '');
    final phone = clean.length == 10 ? '91$clean' : clean;
    final message = 'नमस्कार, मी Nardana Connect ॲपवरून *$title* संदर्भात संपर्क करत आहे.';
    final uri = Uri.parse('https://wa.me/$phone?text=${Uri.encodeComponent(message)}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
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
📍 ठिकाण: ${item.venueMr ?? 'नरडाणा'}
📅 दिनांक: ${item.eventDate ?? ''} ${item.eventTime ?? ''}
👤 आयोजक: ${item.organizerName ?? 'नरडाणा ग्रामस्थ'}

${item.descriptionMr}

Nardana Connect ॲप: https://nardana-connect.vercel.app/download.html
''';
    SharePlus.instance.share(ShareParams(text: message, subject: item.titleMr));
  }

  @override
  Widget build(BuildContext context) {
    return AppBackScope(
      fallbackRoute: '/village-updates',
      child: Scaffold(
        backgroundColor: AppColors.surface,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => BackButtonHandler.safePop(context, fallbackRoute: '/village-updates'),
          ),
          title: Text(
            'गावातील घडामोडी तपशील',
            style: GoogleFonts.mukta(fontWeight: FontWeight.bold),
          ),
          actions: [
            if (_update != null) ...[
              IconButton(
                icon: const Icon(Icons.share_rounded),
                onPressed: () => _shareNative(_update!),
                tooltip: 'शेअर करा',
              ),
            ],
          ],
        ),
        body: _buildBody(),
        bottomNavigationBar: _update == null
            ? null
            : Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: AppColors.border)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _shareOnWhatsApp(_update!),
                          icon: const Icon(Icons.chat_rounded, size: 20),
                          label: Text(
                            'WhatsApp वर शेअर करा',
                            style: GoogleFonts.mukta(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.secondaryGreen,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      IconButton.filledTonal(
                        onPressed: () => _shareNative(_update!),
                        icon: const Icon(Icons.share_rounded, color: AppColors.primaryBlue),
                        tooltip: 'इतर माध्यमातून शेअर करा',
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.12),
                          padding: const EdgeInsets.all(12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null || _update == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline_rounded, size: 56, color: Colors.grey.shade400),
              const SizedBox(height: 12),
              Text(
                _errorMessage ?? 'माहिती उपलब्ध नाही.',
                style: GoogleFonts.mukta(fontSize: 16, color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => BackButtonHandler.safePop(context, fallbackRoute: '/village-updates'),
                child: Text('मागे जा', style: GoogleFonts.mukta(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      );
    }

    final item = _update!;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Poster Card / Image
          if (item.posterUrl != null && item.posterUrl!.isNotEmpty) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                color: Colors.grey.shade100,
                child: CachedNetworkImage(
                  imageUrl: item.posterUrl!,
                  width: double.infinity,
                  fit: BoxFit.contain,
                  placeholder: (context, url) => Container(
                    height: 220,
                    color: Colors.grey.shade200,
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) => Container(
                    height: 180,
                    color: Colors.grey.shade100,
                    child: Center(
                      child: Text(item.categoryIcon, style: const TextStyle(fontSize: 54)),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Category Badge & Status
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: item.categoryColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: item.categoryColor.withValues(alpha: 0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(item.categoryIcon, style: const TextStyle(fontSize: 14)),
                    const SizedBox(width: 6),
                    Text(
                      item.categoryLabel,
                      style: GoogleFonts.mukta(
                        color: item.categoryColor,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              if (item.isUpcoming)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.green.shade300),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.alarm_rounded, size: 14, color: Colors.green),
                      const SizedBox(width: 4),
                      Text(
                        'आगामी कार्यक्रम',
                        style: GoogleFonts.mukta(
                          color: Colors.green.shade800,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Text(
                    'झालेला कार्यक्रम',
                    style: GoogleFonts.mukta(
                      color: Colors.grey.shade700,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 12),

          // Title
          Text(
            item.titleMr,
            style: GoogleFonts.mukta(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              height: 1.25,
            ),
          ),
          if (item.titleEn != null && item.titleEn!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              item.titleEn!,
              style: GoogleFonts.mukta(
                fontSize: 14,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],

          const SizedBox(height: 16),

          // Key Highlights Card (Date, Time, Venue)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Date & Time
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.calendar_month_rounded, color: AppColors.primaryBlue, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'दिनांक व वेळ',
                            style: GoogleFonts.mukta(fontSize: 11, color: AppColors.textSecondary),
                          ),
                          Text(
                            '${item.eventDate ?? "लवकरच जाहीर होईल"}${item.eventTime != null && item.eventTime!.isNotEmpty ? " • ${item.eventTime}" : ""}',
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
                ),

                const Divider(height: 20),

                // Venue / Location
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.location_on_rounded, color: Colors.red, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'स्थळ / ठिकाण',
                            style: GoogleFonts.mukta(fontSize: 11, color: AppColors.textSecondary),
                          ),
                          Text(
                            item.venueMr ?? 'नरडाणा (ता. शिंदखेडा, जि. धुळे)',
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
                ),

                // Google Maps Direction Button
                if (item.hasValidGps) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _openDirections(item.latitude!, item.longitude!),
                      icon: const Icon(Icons.directions_rounded, size: 18),
                      label: Text(
                        'गुगल मॅप्स दिशामार्ग (Get Directions)',
                        style: GoogleFonts.mukta(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primaryBlue,
                        side: const BorderSide(color: AppColors.primaryBlue),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Detailed Description Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.description_rounded, size: 18, color: AppColors.primaryBlue),
                    const SizedBox(width: 6),
                    Text(
                      'सविस्तर माहिती',
                      style: GoogleFonts.mukta(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  item.descriptionMr,
                  style: GoogleFonts.mukta(
                    fontSize: 15,
                    color: AppColors.textPrimary,
                    height: 1.6,
                  ),
                ),
                if (item.descriptionEn != null && item.descriptionEn!.isNotEmpty) ...[
                  const Divider(height: 24),
                  Text(
                    item.descriptionEn!,
                    style: GoogleFonts.mukta(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Organizer & Contact Box
          if ((item.organizerName != null && item.organizerName!.isNotEmpty) ||
              (item.organizerContact != null && item.organizerContact!.isNotEmpty))
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.person_pin_rounded, size: 18, color: AppColors.primaryBlue),
                      const SizedBox(width: 6),
                      Text(
                        'आयोजक व संपर्क',
                        style: GoogleFonts.mukta(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (item.organizerName != null && item.organizerName!.isNotEmpty)
                    Text(
                      item.organizerName!,
                      style: GoogleFonts.mukta(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  if (item.organizerContact != null && item.organizerContact!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      'संपर्क: ${item.organizerContact}',
                      style: GoogleFonts.mukta(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _callOrganizer(item.organizerContact!),
                            icon: const Icon(Icons.call_rounded, size: 16),
                            label: Text(
                              'कॉल करा',
                              style: GoogleFonts.mukta(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryBlue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _chatOnWhatsApp(item.organizerContact!, item.titleMr),
                            icon: const Icon(Icons.chat_rounded, size: 16, color: AppColors.secondaryGreen),
                            label: Text(
                              'WhatsApp',
                              style: GoogleFonts.mukta(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: AppColors.secondaryGreen,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppColors.secondaryGreen),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}

