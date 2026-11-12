import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nardana_connect/core/constants/app_colors.dart';
import 'package:nardana_connect/core/navigation/app_back_scope.dart';
import 'package:nardana_connect/features/vehicles/models/vehicle_listing_model.dart';
import 'package:nardana_connect/features/vehicles/services/vehicle_service.dart';
import 'package:url_launcher/url_launcher.dart';

class VehicleDetailScreen extends StatefulWidget {
  final VehicleListingModel vehicle;

  const VehicleDetailScreen({super.key, required this.vehicle});

  @override
  State<VehicleDetailScreen> createState() => _VehicleDetailScreenState();
}

class _VehicleDetailScreenState extends State<VehicleDetailScreen> {
  late VehicleListingModel _vehicle;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _vehicle = widget.vehicle;
  }

  Future<void> _callDriver() async {
    final clean = _vehicle.contactNumber.replaceAll(RegExp(r'[^0-9]'), '');
    final uri = Uri.parse('tel:$clean');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _whatsappDriver() async {
    final clean = (_vehicle.whatsappNumber ?? _vehicle.contactNumber).replaceAll(RegExp(r'[^0-9]'), '');
    final phone = clean.startsWith('91') ? clean : '91$clean';
    final msg = Uri.encodeComponent(
        'नमस्कार, नरडाणा कनेक्ट (Nardana Connect) ॲपवरून आपल्या "${_vehicle.vehicleModel}" (${_vehicle.vehicleType}) या गाडीच्या भाड्याबाबत विचारणा करत आहे.');
    final uri = Uri.parse('https://wa.me/$phone?text=$msg');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _shareListing() async {
    final text = '🚗 *गाडी भाड्याने मिळेल (नरडाणा)*\n'
        '• वाहन: ${_vehicle.vehicleModel} (${_vehicle.vehicleType})\n'
        '• ड्रायव्हर: ${_vehicle.driverName}\n'
        '• संपर्क: ${_vehicle.contactNumber}\n'
        '• पत्ता: ${_vehicle.locationText ?? "नरडाणा"}\n'
        '• स्थिती: ${_vehicle.isAvailable ? "उपलब्ध (Available)" : "कामावर (Busy)"}\n\n'
        'अधिक माहितीसाठी डाऊनलोड करा "नरडाणा कनेक्ट" ॲप:\nhttps://nardana-connect.vercel.app/download.html';
    await Clipboard.setData(ClipboardData(text: text));
    final uri = Uri.parse('whatsapp://send?text=${Uri.encodeComponent(text)}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('गाडीची माहिती क्लिपबोर्डवर कॉपी केली!', style: GoogleFonts.mukta(fontWeight: FontWeight.bold)),
            backgroundColor: AppColors.primaryBlue,
          ),
        );
      }
    }
  }

  Future<void> _toggleAvailability() async {
    setState(() => _isUpdating = true);
    final newStatus = _vehicle.isAvailable ? 'busy' : 'available';
    final success = await VehicleService.instance.updateAvailability(_vehicle.id, newStatus);
    if (mounted) {
      setState(() {
        _isUpdating = false;
        if (success) {
          _vehicle = VehicleListingModel(
            id: _vehicle.id,
            ownerUserId: _vehicle.ownerUserId,
            driverName: _vehicle.driverName,
            vehicleType: _vehicle.vehicleType,
            vehicleModel: _vehicle.vehicleModel,
            vehicleNumber: _vehicle.vehicleNumber,
            seatingCapacity: _vehicle.seatingCapacity,
            loadCapacity: _vehicle.loadCapacity,
            acAvailable: _vehicle.acAvailable,
            rentalRateOptional: _vehicle.rentalRateOptional,
            contactNumber: _vehicle.contactNumber,
            whatsappNumber: _vehicle.whatsappNumber,
            locationText: _vehicle.locationText,
            latitudeOptional: _vehicle.latitudeOptional,
            longitudeOptional: _vehicle.longitudeOptional,
            availabilityStatus: newStatus,
            verificationStatus: _vehicle.verificationStatus,
            approvalStatus: _vehicle.approvalStatus,
            photoUrl: _vehicle.photoUrl,
            isActive: _vehicle.isActive,
            villageId: _vehicle.villageId,
            createdAt: _vehicle.createdAt,
            updatedAt: DateTime.now(),
          );
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? 'स्थिती यशस्वीरित्या बदलली!' : 'स्थिती बदलण्यात त्रुटी आली.',
            style: GoogleFonts.mukta(fontWeight: FontWeight.bold),
          ),
          backgroundColor: success ? AppColors.secondaryGreen : Colors.red,
        ),
      );
    }
  }

  void _showReportDialog() {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('तक्रार / आक्षेप नोंदवा', style: GoogleFonts.mukta(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'या गाडीच्या नोंदीबाबत काही चुकीची माहिती किंवा अनुचित प्रकार असल्यास ॲडमिनला कळवा:',
              style: GoogleFonts.mukta(fontSize: 13, color: Colors.blueGrey),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              maxLines: 3,
              style: GoogleFonts.mukta(fontSize: 13),
              decoration: const InputDecoration(
                hintText: 'उदा. चुकीचा मोबाईल नंबर, अव्वाच्या सव्वा भाडे...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('रद्द करा', style: GoogleFonts.mukta()),
          ),
          ElevatedButton(
            onPressed: () async {
              if (reasonController.text.trim().isEmpty) return;
              Navigator.of(ctx).pop();
              final ok = await VehicleService.instance.reportListing(
                listingId: _vehicle.id,
                reason: reasonController.text.trim(),
              );
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      ok ? 'तक्रार यशस्वीरित्या नोंदवली गेली.' : 'त्रुटी आली, कृपया पुन्हा प्रयत्न करा.',
                      style: GoogleFonts.mukta(),
                    ),
                    backgroundColor: ok ? AppColors.primaryBlue : Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: Text('तक्रार पाठवा', style: GoogleFonts.mukta(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAvailable = _vehicle.isAvailable;

    return AppBackScope(
      fallbackRoute: '/vehicles',
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F8FA),
        appBar: AppBar(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/vehicles');
              }
            },
          ),
          title: Text(
            'गाडी तपशील (Vehicle Details)',
            style: GoogleFonts.mukta(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.share_rounded),
              tooltip: 'शेअर करा',
              onPressed: _shareListing,
            ),
            IconButton(
              icon: const Icon(Icons.report_problem_outlined),
              tooltip: 'तक्रार नोंदवा',
              onPressed: _showReportDialog,
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Photo Header Card
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: _vehicle.photoUrl != null && _vehicle.photoUrl!.isNotEmpty
                      ? Image.network(
                          _vehicle.photoUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => _buildDetailPlaceholder(),
                        )
                      : _buildDetailPlaceholder(),
                ),
              ),

              const SizedBox(height: 16),

              // Title and Availability
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _vehicle.vehicleType,
                            style: GoogleFonts.mukta(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryBlue,
                            ),
                          ),
                        ),
                        const Spacer(),
                        // Availability pill
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isAvailable ? const Color(0xFFDCFCE7) : const Color(0xFFFFEDD5),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isAvailable ? const Color(0xFF86EFAC) : const Color(0xFFFDBA74),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isAvailable ? const Color(0xFF16A34A) : const Color(0xFFEA580C),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                isAvailable ? 'उपलब्ध (Available)' : 'कामावर (Busy)',
                                style: GoogleFonts.mukta(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: isAvailable ? const Color(0xFF15803D) : const Color(0xFFC2410C),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _vehicle.vehicleModel,
                      style: GoogleFonts.mukta(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.verified_rounded, size: 16, color: AppColors.secondaryGreen),
                        const SizedBox(width: 4),
                        Text(
                          'नरडाणा गाव अधिकृत पडताळणीकृत नोंद',
                          style: GoogleFonts.mukta(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.secondaryGreen,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Specifications Grid Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'वाहन तपशील व वैशिष्ट्ये',
                      style: GoogleFonts.mukta(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildSpecRow(
                      icon: Icons.person_outline_rounded,
                      label: 'ड्रायव्हर / मालक',
                      value: _vehicle.driverName,
                    ),
                    const Divider(height: 16, color: Color(0xFFF1F5F9)),
                    if (_vehicle.seatingCapacity != null) ...[
                      _buildSpecRow(
                        icon: Icons.event_seat_rounded,
                        label: 'बैठक क्षमता',
                        value: '${_vehicle.seatingCapacity} व्यक्ती (Seater)',
                      ),
                      const Divider(height: 16, color: Color(0xFFF1F5F9)),
                    ],
                    if (_vehicle.loadCapacity != null && _vehicle.loadCapacity!.isNotEmpty) ...[
                      _buildSpecRow(
                        icon: Icons.luggage_rounded,
                        label: 'वजन / वाहतूक क्षमता',
                        value: _vehicle.loadCapacity!,
                      ),
                      const Divider(height: 16, color: Color(0xFFF1F5F9)),
                    ],
                    _buildSpecRow(
                      icon: Icons.ac_unit_rounded,
                      label: 'वातानुकूलित (AC)',
                      value: _vehicle.acAvailable ? 'होय (AC उपलब्ध)' : 'नाही (Non-AC)',
                    ),
                    const Divider(height: 16, color: Color(0xFFF1F5F9)),
                    _buildSpecRow(
                      icon: Icons.pin_drop_outlined,
                      label: 'स्थान / ठिकाण',
                      value: _vehicle.locationText ?? 'नरडाणा (पिन: ४२५४०४)',
                    ),
                    const Divider(height: 16, color: Color(0xFFF1F5F9)),
                    _buildSpecRow(
                      icon: Icons.confirmation_number_outlined,
                      label: 'वाहन क्रमांक गोपनीयता',
                      value: _vehicle.maskedVehicleNumber,
                    ),
                    if (_vehicle.rentalRateOptional != null && _vehicle.rentalRateOptional!.isNotEmpty) ...[
                      const Divider(height: 16, color: Color(0xFFF1F5F9)),
                      _buildSpecRow(
                        icon: Icons.currency_rupee_rounded,
                        label: 'अंदाजे भाडे / दर',
                        value: _vehicle.rentalRateOptional!,
                        valueColor: const Color(0xFF92400E),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Owner Quick Status Toggle
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.tune_rounded, size: 20, color: AppColors.primaryBlue),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'चालक / मालक स्थिती अपडेट',
                            style: GoogleFonts.mukta(fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            isAvailable ? 'सध्या गाडी उपलब्ध आहे' : 'सध्या गाडी कामावर व्यस्त आहे',
                            style: GoogleFonts.mukta(fontSize: 11, color: Colors.blueGrey),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: _isUpdating ? null : _toggleAvailability,
                      style: TextButton.styleFrom(
                        backgroundColor: isAvailable ? const Color(0xFFFFEDD5) : const Color(0xFFDCFCE7),
                        foregroundColor: isAvailable ? const Color(0xFFEA580C) : const Color(0xFF16A34A),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      ),
                      child: _isUpdating
                          ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                          : Text(
                              isAvailable ? 'कामावर दाखवा' : 'उपलब्ध दाखवा',
                              style: GoogleFonts.mukta(fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Privacy & Direct Contact Notice
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade100),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline_rounded, size: 18, color: AppColors.primaryBlue),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'नरडाणा कनेक्ट केवळ स्थानिक संपर्क व माहितीसाठी आहे. भाडे, वेळ व बुकिंग थेट चालक/मालकांशी चर्चा करून ठरवा. ॲप कोणतेही कमिशन घेत नाही.',
                        style: GoogleFonts.mukta(fontSize: 11.5, color: const Color(0xFF1E3A8A)),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 80),
            ],
          ),
        ),
        bottomSheet: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 10,
                offset: const Offset(0, -3),
              ),
            ],
          ),
          child: SafeArea(
            child: Row(
              children: [
                // Direct Call
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _callDriver,
                    icon: const Icon(Icons.phone_in_talk_rounded, size: 18),
                    label: Text(
                      'थेट फोन करा',
                      style: GoogleFonts.mukta(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryBlue,
                      side: const BorderSide(color: AppColors.primaryBlue, width: 1.5),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // WhatsApp
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _whatsappDriver,
                    icon: const Icon(Icons.chat_bubble_rounded, size: 18),
                    label: Text(
                      'WhatsApp करा',
                      style: GoogleFonts.mukta(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF25D366),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSpecRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primaryBlue),
        const SizedBox(width: 10),
        Text(
          label,
          style: GoogleFonts.mukta(fontSize: 13, color: Colors.blueGrey.shade700),
        ),
        const Spacer(),
        Text(
          value,
          style: GoogleFonts.mukta(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: valueColor ?? const Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailPlaceholder() {
    return Container(
      color: const Color(0xFFF1F5F9),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.directions_car_filled_rounded, size: 64, color: AppColors.primaryBlue),
            const SizedBox(height: 8),
            Text(
              _vehicle.vehicleType,
              style: GoogleFonts.mukta(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.blueGrey),
            ),
          ],
        ),
      ),
    );
  }
}
