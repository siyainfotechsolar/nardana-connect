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
        padding: const EdgeInsets.all(20.0),
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
                      'गाव निवडा (Select Village)',
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
            const SizedBox(height: 6),
            Text(
              'आपल्या गावातील स्थानिक सेवा व सूचना पाहण्यासाठी गाव निवडा:',
              style: GoogleFonts.mukta(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 320),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: kSupportedVillages.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final v = kSupportedVillages[index];
                  final isSelected = v.id == currentVillage.id;

                  return ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    leading: CircleAvatar(
                      radius: 16,
                      backgroundColor: isSelected
                          ? AppColors.primaryBlue
                          : AppColors.primaryBlue.withValues(alpha: 0.08),
                      child: Icon(
                        Icons.home_work_rounded,
                        size: 16,
                        color: isSelected ? Colors.white : AppColors.primaryBlue,
                      ),
                    ),
                    title: Text(
                      '${v.nameMr} (${v.nameEn})',
                      style: GoogleFonts.mukta(
                        fontSize: 15,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected
                            ? AppColors.primaryBlue
                            : AppColors.textPrimary,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle_rounded,
                            color: AppColors.secondaryGreen, size: 20)
                        : null,
                    onTap: () {
                      ref.read(selectedVillageProvider.notifier).selectVillage(v);
                      Navigator.of(context).pop();
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
