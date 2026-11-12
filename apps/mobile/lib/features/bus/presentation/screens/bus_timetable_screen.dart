import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nardana_connect/core/constants/app_colors.dart';
import 'package:nardana_connect/core/navigation/app_back_scope.dart';
import 'package:nardana_connect/features/bus/models/bus_timetable_model.dart';
import 'package:nardana_connect/features/bus/services/bus_service.dart';

class BusTimetableScreen extends StatefulWidget {
  const BusTimetableScreen({super.key});

  @override
  State<BusTimetableScreen> createState() => _BusTimetableScreenState();
}

class _BusTimetableScreenState extends State<BusTimetableScreen> {
  List<BusTimetableModel> _buses = [];
  bool _isLoading = true;
  String _selectedLang = 'mr'; // 'mr' | 'en'

  @override
  void initState() {
    super.initState();
    _loadTimetable();
  }

  Future<void> _loadTimetable() async {
    setState(() => _isLoading = true);
    final list = await BusService.instance.fetchTimetables();
    if (mounted) {
      setState(() {
        _buses = list;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMr = _selectedLang == 'mr';

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
          title: Text(
            isMr ? 'एसटी बस वेळापत्रक' : 'Bus Time Table',
            style: GoogleFonts.mukta(fontSize: 19, fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              tooltip: isMr ? 'रिफ्रेश करा' : 'Refresh',
              onPressed: _loadTimetable,
            ),
          ],
        ),
        body: Column(
          children: [
            // Top Bar: Station info & Language Toggle
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  const Icon(Icons.directions_bus_rounded, size: 20, color: AppColors.primaryBlue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isMr ? 'नरडाणा बस थांबा (MSRTC)' : 'Nardana Bus Stop (MSRTC)',
                      style: GoogleFonts.mukta(
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                  ),
                  // Language Toggle
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildLangChip('mr', 'मराठी'),
                        _buildLangChip('en', 'EN'),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Table Header: Bus Route | Departure Time
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: const BoxDecoration(
                color: Color(0xFFE2E8F0),
                border: Border(
                  bottom: BorderSide(color: Color(0xFFCBD5E1)),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 7,
                    child: Row(
                      children: [
                        const Icon(Icons.alt_route_rounded, size: 16, color: Color(0xFF334155)),
                        const SizedBox(width: 6),
                        Text(
                          isMr ? 'बस मार्ग (Bus Route)' : 'Bus Route',
                          style: GoogleFonts.mukta(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Icon(Icons.access_time_rounded, size: 15, color: Color(0xFF334155)),
                        const SizedBox(width: 4),
                        Text(
                          isMr ? 'वेळ (Time)' : 'Departure Time',
                          style: GoogleFonts.mukta(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Simple Mobile List UI
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue))
                  : _buses.isEmpty
                      ? Center(
                          child: Text(
                            isMr ? 'वेळापत्रक उपलब्ध नाही' : 'No bus timings available',
                            style: GoogleFonts.mukta(fontSize: 14, color: Colors.blueGrey),
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadTimetable,
                          color: AppColors.primaryBlue,
                          child: ListView.separated(
                            itemCount: _buses.length,
                            separatorBuilder: (context, index) => const Divider(
                              height: 1,
                              color: Color(0xFFF1F5F9),
                            ),
                            itemBuilder: (context, index) {
                              final bus = _buses[index];
                              final routeText = isMr ? bus.routeMr : bus.routeEn;
                              final isEven = index % 2 == 0;

                              return Container(
                                color: isEven ? Colors.white : const Color(0xFFF8FAFC),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                                child: Row(
                                  children: [
                                    // Bus Route Column
                                    Expanded(
                                      flex: 7,
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Container(
                                            width: 24,
                                            height: 24,
                                            decoration: BoxDecoration(
                                              color: AppColors.primaryBlue.withValues(alpha: 0.1),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Center(
                                              child: Text(
                                                '${index + 1}',
                                                style: GoogleFonts.mukta(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                  color: AppColors.primaryBlue,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              routeText,
                                              style: GoogleFonts.mukta(
                                                fontSize: 13.5,
                                                fontWeight: FontWeight.w700,
                                                color: const Color(0xFF0F172A),
                                                height: 1.25,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Departure Time Column
                                    Expanded(
                                      flex: 4,
                                      child: Align(
                                        alignment: Alignment.centerRight,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFEFF6FF),
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(color: const Color(0xFFBFDBFE)),
                                          ),
                                          child: Text(
                                            bus.departureTime,
                                            style: GoogleFonts.mukta(
                                              fontSize: 12.5,
                                              fontWeight: FontWeight.w800,
                                              color: const Color(0xFF1D4ED8),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
            ),

            // Bottom informational strip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.white,
              child: SafeArea(
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, size: 14, color: Colors.blueGrey),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        isMr
                            ? 'वेळापत्रक स्थानिक एसटी वाहतुकीनुसार बदलू शकते.'
                            : 'Timings are subject to local MSRTC operational changes.',
                        style: GoogleFonts.mukta(fontSize: 11, color: Colors.blueGrey.shade700),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLangChip(String code, String label) {
    final isSelected = _selectedLang == code;
    return InkWell(
      onTap: () => setState(() => _selectedLang = code),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryBlue : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
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
}

