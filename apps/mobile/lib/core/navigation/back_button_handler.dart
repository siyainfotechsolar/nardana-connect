import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nardana_connect/core/constants/app_colors.dart';

/// Centralized Global Back Button Handler for Nardana Connect.
/// Manages double-back exit on Home, modal dismissal, keyboard closing,
/// deep link fallback, and dirty-form data safety.
class BackButtonHandler {
  static DateTime? _lastBackPressTime;
  static bool _isExitDialogOpen = false;
  static const Duration _doublePressWindow = Duration(milliseconds: 2500);

  /// Handle Back Press on Home / Root Shell.
  /// First press: Shows localized Toast / SnackBar.
  /// Second press within 2.5s: Shows bilingual Exit Confirmation Dialog.
  static Future<void> handleHomeBackPress(
    BuildContext context, {
    required bool isMr,
    VoidCallback? onStay,
  }) async {
    final now = DateTime.now();

    // If exit dialog is already visible, do not open another
    if (_isExitDialogOpen) return;

    if (_lastBackPressTime == null ||
        now.difference(_lastBackPressTime!) > _doublePressWindow) {
      _lastBackPressTime = now;

      // Show bottom SnackBar notification
      final message = isMr
          ? 'पुन्हा Back दाबल्यास NARDANA CONNECT बंद होईल.'
          : 'Press Back again to exit NARDANA CONNECT.';

      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.info_outline_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: GoogleFonts.mukta(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.primaryBlue,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      );
    } else {
      // Second back press within window: show exit confirmation dialog
      _lastBackPressTime = null;
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      await showExitConfirmationDialog(context, isMr: isMr, onStay: onStay);
    }
  }

  /// Show Bilingual Exit Confirmation Dialog
  /// Title: "अॅप बंद करायचे आहे?"
  /// Buttons: "नाही" (Stay) / "होय, बाहेर पडा" (Exit)
  static Future<bool> showExitConfirmationDialog(
    BuildContext context, {
    required bool isMr,
    VoidCallback? onStay,
  }) async {
    if (_isExitDialogOpen) return false;
    _isExitDialogOpen = true;

    try {
      final shouldExit = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          actionsPadding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.exit_to_app_rounded, color: Colors.red.shade700, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isMr ? 'अॅप बंद करायचे आहे?' : 'Exit NARDANA CONNECT?',
                  style: GoogleFonts.mukta(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            isMr
                ? 'तुम्हाला नरडाणा कनेक्ट (Nardana Connect) ॲपमधून बाहेर पडायचे आहे का?'
                : 'Are you sure you want to exit the Nardana Connect app?',
            style: GoogleFonts.mukta(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                side: const BorderSide(color: AppColors.border),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(
                isMr ? 'नाही' : 'No',
                style: GoogleFonts.mukta(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              child: Text(
                isMr ? 'होय, बाहेर पडा' : 'Yes, Exit',
                style: GoogleFonts.mukta(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );

      if (shouldExit == true) {
        await SystemNavigator.pop();
        return true;
      } else {
        onStay?.call();
        return false;
      }
    } finally {
      _isExitDialogOpen = false;
    }
  }

  /// Safe pop navigation with fallback route (for deep links or isolated routes).
  /// If [context.canPop()] is true, pops the route.
  /// Otherwise, navigates safely to [fallbackRoute].
  static void safePop(BuildContext context, {String fallbackRoute = '/home'}) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(fallbackRoute);
    }
  }

  /// Confirm unsaved changes dialog before discarding dirty form data.
  static Future<bool> confirmDiscardChanges(
    BuildContext context, {
    required bool isMr,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.amber.shade800, size: 24),
            const SizedBox(width: 10),
            Text(
              isMr ? 'माहिती जतन करायची आहे का?' : 'Unsaved Changes',
              style: GoogleFonts.mukta(fontSize: 17, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(
          isMr
              ? 'तुम्ही भरलेली माहिती अजून सेव्ह झालेली नाही. मागे गेल्यास ही माहिती नष्ट होऊ शकते.'
              : 'You have unsaved changes. Navigating back may discard this draft.',
          style: GoogleFonts.mukta(fontSize: 14, color: AppColors.textSecondary),
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              isMr ? 'माहिती जतन ठेवा' : 'Keep Editing',
              style: GoogleFonts.mukta(fontWeight: FontWeight.bold),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
            ),
            child: Text(
              isMr ? 'मागे जा' : 'Discard & Leave',
              style: GoogleFonts.mukta(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}
