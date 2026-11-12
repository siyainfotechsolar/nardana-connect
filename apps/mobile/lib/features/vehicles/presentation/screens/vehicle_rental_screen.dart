import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nardana_connect/core/constants/app_colors.dart';
import 'package:nardana_connect/core/navigation/app_back_scope.dart';
import 'package:nardana_connect/features/vehicles/models/vehicle_listing_model.dart';
import 'package:nardana_connect/features/vehicles/services/vehicle_service.dart';
import 'package:url_launcher/url_launcher.dart';

class VehicleRentalScreen extends ConsumerStatefulWidget {
  final String? initialCategory;

  const VehicleRentalScreen({super.key, this.initialCategory});

  @override
  ConsumerState<VehicleRentalScreen> createState() => _VehicleRentalScreenState();
}

class _VehicleRentalScreenState extends ConsumerState<VehicleRentalScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<VehicleCategory> _categories = [];
  List<VehicleListingModel> _listings = [];
  bool _isLoading = true;
  String _selectedCategorySlug = 'all';
  String _selectedAvailability = 'all'; // 'all' | 'available' | 'busy'

  @override
  void initState() {
    super.initState();
    if (widget.initialCategory != null && widget.initialCategory!.isNotEmpty) {
      _selectedCategorySlug = widget.initialCategory!;
    }
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final categories = await VehicleService.instance.fetchCategories();
    final listings = await VehicleService.instance.fetchListings(
      categorySlug: _selectedCategorySlug == 'all' ? null : _selectedCategorySlug,
      availabilityStatus: _selectedAvailability == 'all' ? null : _selectedAvailability,
      searchQuery: _searchController.text.trim().isEmpty ? null : _searchController.text.trim(),
    );

    if (mounted) {
      setState(() {
        _categories = categories;
        _listings = listings;
        _isLoading = false;
      });
    }
  }

  Future<void> _callDriver(String number) async {
    final clean = number.replaceAll(RegExp(r'[^0-9]'), '');
    final uri = Uri.parse('tel:$clean');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _whatsappDriver(String number, String vehicleModel) async {
    final clean = number.replaceAll(RegExp(r'[^0-9]'), '');
    final phone = clean.startsWith('91') ? clean : '91$clean';
    final msg = Uri.encodeComponent(
        'नमस्कार, नरडाणा कनेक्ट (Nardana Connect) ॲपवरून आपल्या "$vehicleModel" या गाडीच्या भाड्याबाबत विचारणा करत आहे.');
    final uri = Uri.parse('https://wa.me/$phone?text=$msg');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBackScope(
      fallbackRoute: '/home',
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
                context.go('/home');
              }
            },
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'गाडी भाड्याने मिळेल',
                style: GoogleFonts.mukta(fontSize: 19, fontWeight: FontWeight.bold),
              ),
              Text(
                'नरडाणा गाव विशेष • ड्रायव्हर्स व वाहने',
                style: GoogleFonts.mukta(fontSize: 11, color: AppColors.accentYellow),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              tooltip: 'रिफ्रेश करा',
              onPressed: _loadData,
            ),
          ],
        ),
        body: Column(
          children: [
            // Search & Availability Bar
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
              child: Column(
                children: [
                  // Search Input
                  Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (_) => _loadData(),
                      style: GoogleFonts.mukta(fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'वाहन, मॉडेल किंवा ड्रायव्हरचे नाव शोधा...',
                        hintStyle: GoogleFonts.mukta(fontSize: 13, color: Colors.grey.shade500),
                        prefixIcon: const Icon(Icons.search_rounded, size: 20, color: AppColors.primaryBlue),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded, size: 18),
                                onPressed: () {
                                  _searchController.clear();
                                  _loadData();
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Availability Filter Pills
                  Row(
                    children: [
                      Text(
                        'स्थिती:',
                        style: GoogleFonts.mukta(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blueGrey),
                      ),
                      const SizedBox(width: 8),
                      _buildAvailabilityPill('all', 'सर्व'),
                      const SizedBox(width: 6),
                      _buildAvailabilityPill('available', '🟢 उपलब्ध (Available)'),
                      const SizedBox(width: 6),
                      _buildAvailabilityPill('busy', '🟠 कामावर (Busy)'),
                    ],
                  ),
                ],
              ),
            ),

            // Horizontal Category Selector
            Container(
              height: 46,
              color: Colors.white,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                itemCount: _categories.length,
                separatorBuilder: (context, index) => const SizedBox(width: 6),
                itemBuilder: (context, index) {
                  final cat = _categories[index];
                  final isSelected = _selectedCategorySlug == cat.slug;
                  return InkWell(
                    onTap: () {
                      setState(() => _selectedCategorySlug = cat.slug);
                      _loadData();
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primaryBlue : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? AppColors.primaryBlue : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          cat.nameMr,
                          style: GoogleFonts.mukta(
                            fontSize: 12.5,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            color: isSelected ? Colors.white : const Color(0xFF334155),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const Divider(height: 1, color: Color(0xFFE2E8F0)),

            // Listings List / Empty / Loading
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue))
                  : _listings.isEmpty
                      ? _buildEmptyState()
                      : RefreshIndicator(
                          onRefresh: _loadData,
                          color: AppColors.primaryBlue,
                          child: ListView.separated(
                            padding: const EdgeInsets.all(14),
                            itemCount: _listings.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final item = _listings[index];
                              return _buildVehicleCard(item);
                            },
                          ),
                        ),
            ),
          ],
        ),
        bottomNavigationBar: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, -3),
              ),
            ],
          ),
          child: SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final res = await context.push('/vehicle-submit');
                      if (res == true) {
                        _loadData();
                      }
                    },
                    icon: const Icon(Icons.add_circle_outline_rounded, size: 20),
                    label: Text(
                      'आपली गाडी नोंदवा (Add Vehicle)',
                      style: GoogleFonts.mukta(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondaryGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
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

  Widget _buildAvailabilityPill(String key, String label) {
    final isSelected = _selectedAvailability == key;
    return InkWell(
      onTap: () {
        setState(() => _selectedAvailability = key);
        _loadData();
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1E293B) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF1E293B) : const Color(0xFFCBD5E1),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.mukta(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : const Color(0xFF475569),
          ),
        ),
      ),
    );
  }

  Widget _buildVehicleCard(VehicleListingModel vehicle) {
    final isAvailable = vehicle.isAvailable;

    return InkWell(
      onTap: () {
        context.push('/vehicle-detail', extra: vehicle);
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isAvailable ? const Color(0xFFE2E8F0) : const Color(0xFFFED7AA),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Header: Type & Status
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      vehicle.vehicleType,
                      style: GoogleFonts.mukta(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (vehicle.acAvailable)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.cyan.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '❄️ AC उपलब्ध',
                        style: GoogleFonts.mukta(fontSize: 10.5, fontWeight: FontWeight.bold, color: Colors.cyan.shade900),
                      ),
                    ),
                  const Spacer(),
                  // Availability Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: isAvailable ? const Color(0xFFDCFCE7) : const Color(0xFFFFEDD5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isAvailable ? const Color(0xFF86EFAC) : const Color(0xFFFDBA74),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isAvailable ? const Color(0xFF16A34A) : const Color(0xFFEA580C),
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          isAvailable ? 'उपलब्ध (Available)' : 'कामावर (Busy)',
                          style: GoogleFonts.mukta(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isAvailable ? const Color(0xFF15803D) : const Color(0xFFC2410C),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Middle: Vehicle info & Driver
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Photo / Thumbnail
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 82,
                      height: 82,
                      color: const Color(0xFFF1F5F9),
                      child: vehicle.photoUrl != null && vehicle.photoUrl!.isNotEmpty
                          ? Image.network(
                              vehicle.photoUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => _buildVehiclePlaceholder(vehicle.vehicleType),
                            )
                          : _buildVehiclePlaceholder(vehicle.vehicleType),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          vehicle.vehicleModel,
                          style: GoogleFonts.mukta(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1E293B),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(Icons.person_rounded, size: 14, color: AppColors.primaryBlue),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                vehicle.driverName,
                                style: GoogleFonts.mukta(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF334155),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        if (vehicle.seatingCapacity != null || vehicle.loadCapacity != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            vehicle.seatingCapacity != null
                                ? 'बैठक क्षमता: ${vehicle.seatingCapacity} व्यक्ती'
                                : 'क्षमता: ${vehicle.loadCapacity}',
                            style: GoogleFonts.mukta(fontSize: 11.5, color: Colors.blueGrey.shade700),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(Icons.location_on_rounded, size: 13, color: Colors.redAccent),
                            const SizedBox(width: 3),
                            Expanded(
                              child: Text(
                                vehicle.locationText ?? 'नरडाणा',
                                style: GoogleFonts.mukta(fontSize: 11.5, color: Colors.grey.shade700),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            if (vehicle.rentalRateOptional != null && vehicle.rentalRateOptional!.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFFDE68A)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.sell_outlined, size: 12, color: Color(0xFF92400E)),
                      const SizedBox(width: 4),
                      Text(
                        'दर: ${vehicle.rentalRateOptional}',
                        style: GoogleFonts.mukta(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF92400E),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 10),
            const Divider(height: 1, color: Color(0xFFF1F5F9)),

            // Action Buttons (Call & WhatsApp)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  // Call Button
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _callDriver(vehicle.contactNumber),
                      icon: const Icon(Icons.phone_in_talk_rounded, size: 16),
                      label: Text(
                        'थेट कॉल करा',
                        style: GoogleFonts.mukta(fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primaryBlue,
                        side: const BorderSide(color: AppColors.primaryBlue, width: 1.2),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // WhatsApp Button
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _whatsappDriver(
                        vehicle.whatsappNumber ?? vehicle.contactNumber,
                        vehicle.vehicleModel,
                      ),
                      icon: const Icon(Icons.chat_bubble_rounded, size: 16),
                      label: Text(
                        'WhatsApp',
                        style: GoogleFonts.mukta(fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF25D366),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVehiclePlaceholder(String vehicleType) {
    IconData iconData = Icons.directions_car_rounded;
    final t = vehicleType.toLowerCase();
    if (t.contains('ट्रॅक्टर')) {
      iconData = Icons.agriculture_rounded;
    } else if (t.contains('जेसीबी')) {
      iconData = Icons.construction_rounded;
    } else if (t.contains('पिकअप') || t.contains('टेम्पो') || t.contains('हत्ती')) {
      iconData = Icons.local_shipping_rounded;
    } else if (t.contains('टॅक्सी')) {
      iconData = Icons.local_taxi_rounded;
    } else if (t.contains('बस')) {
      iconData = Icons.directions_bus_rounded;
    }

    return Center(
      child: Icon(iconData, size: 36, color: AppColors.primaryBlue.withValues(alpha: 0.6)),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.car_rental_rounded, size: 48, color: AppColors.primaryBlue),
            ),
            const SizedBox(height: 16),
            Text(
              'कोणतीही गाडी आढळली नाही',
              style: GoogleFonts.mukta(fontSize: 17, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
            ),
            const SizedBox(height: 6),
            Text(
              'कृपया वेगळा शोध शब्द किंवा कॅटेगरी निवडून पुन्हा प्रयत्न करा.',
              textAlign: TextAlign.center,
              style: GoogleFonts.mukta(fontSize: 13, color: Colors.blueGrey),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _selectedCategorySlug = 'all';
                  _selectedAvailability = 'all';
                });
                _loadData();
              },
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: Text('सर्व गाड्या पहा', style: GoogleFonts.mukta(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
