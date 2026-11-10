import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nardana_connect/core/constants/app_colors.dart';
import 'package:nardana_connect/features/village/providers/village_provider.dart';

class VillageSelectorDialog extends ConsumerWidget {
  const VillageSelectorDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentVillage = ref.watch(selectedVillageProvider);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(22.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.location_on_rounded,
                        color: AppColors.secondaryGreen, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      'गाव तपशील (Village Profile)',
                      style: GoogleFonts.mukta(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.15)),
              ),
              child: Column(
                children: [
                  _buildInfoRow('अधिकृत गाव', '${currentVillage.nameMr} (${currentVillage.nameEn})'),
                  const Divider(height: 16),
                  _buildInfoRow('पिनकोड (PIN)', currentVillage.pincode),
                  const Divider(height: 16),
                  _buildInfoRow('तालुका', currentVillage.taluka),
                  const Divider(height: 16),
                  _buildInfoRow('जिल्हा', 'धुळे (Dhule)'),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.secondaryGreen.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.secondaryGreen.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.verified_rounded, color: AppColors.secondaryGreen, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'नरडाणा कनेक्ट हे केवळ नरडाणा गावासाठीचे अधिकृत डिजिटल व्यासपीठ आहे.',
                      style: GoogleFonts.mukta(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.secondaryGreen,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(
                'समजले (Close)',
                style: GoogleFonts.mukta(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.mukta(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.mukta(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
