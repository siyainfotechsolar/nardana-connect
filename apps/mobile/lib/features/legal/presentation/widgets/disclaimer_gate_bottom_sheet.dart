import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nardana_connect/core/constants/app_colors.dart';
import 'package:nardana_connect/features/legal/services/disclaimer_service.dart';

class DisclaimerGateBottomSheet extends StatefulWidget {
  final String featureId;
  final String featureNameMr;
  final String disclaimerExcerptMr;
  final VoidCallback onAccepted;
  final VoidCallback onCancel;

  const DisclaimerGateBottomSheet({
    super.key,
    required this.featureId,
    required this.featureNameMr,
    required this.disclaimerExcerptMr,
    required this.onAccepted,
    required this.onCancel,
  });

  static Future<bool> show({
    required BuildContext context,
    required String featureId,
    required String featureNameMr,
    required String disclaimerExcerptMr,
  }) async {
    final needsAcceptance = await DisclaimerService.instance.checkFeatureRequiresAcceptance(featureId);
    if (!needsAcceptance) return true; // Already accepted

    if (!context.mounted) return false;

    final accepted = await showModalBottomSheet<bool>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) => DisclaimerGateBottomSheet(
        featureId: featureId,
        featureNameMr: featureNameMr,
        disclaimerExcerptMr: disclaimerExcerptMr,
        onAccepted: () => Navigator.of(ctx).pop(true),
        onCancel: () => Navigator.of(ctx).pop(false),
      ),
    );

    return accepted == true;
  }

  @override
  State<DisclaimerGateBottomSheet> createState() => _DisclaimerGateBottomSheetState();
}

class _DisclaimerGateBottomSheetState extends State<DisclaimerGateBottomSheet> {
  bool _isSaving = false;

  Future<void> _handleAccept() async {
    setState(() => _isSaving = true);
    await DisclaimerService.instance.recordAcceptance(
      versionNumber: '1.0.0',
      featureId: widget.featureId,
    );
    if (mounted) {
      widget.onAccepted();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: const Icon(Icons.gavel_rounded, color: Color(0xFFB45309), size: 22),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'कायदेशीर अस्वीकरण सूचना',
                      style: GoogleFonts.mukta(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                    ),
                    Text(
                      widget.featureNameMr,
                      style: GoogleFonts.mukta(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primaryBlue),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Text(
              widget.disclaimerExcerptMr,
              style: GoogleFonts.mukta(fontSize: 13, height: 1.5, color: const Color(0xFF334155)),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'पुढे जाण्यापूर्वी कृपया हे नियम व अटी मान्य करा. केवळ या सेवेसाठी ही पुष्टी आवश्यक आहे.',
            style: GoogleFonts.mukta(fontSize: 11.5, color: Colors.blueGrey),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: widget.onCancel,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: const BorderSide(color: Color(0xFFCBD5E1)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text(
                    'मागे जा (Cancel)',
                    style: GoogleFonts.mukta(fontSize: 13.5, fontWeight: FontWeight.bold, color: Colors.blueGrey),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _handleAccept,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: _isSaving
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text(
                          'मान्य करा (Accept)',
                          style: GoogleFonts.mukta(fontSize: 13.5, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

