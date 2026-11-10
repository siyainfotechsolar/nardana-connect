import 'package:flutter/material.dart';
import 'package:nardana_connect/core/navigation/back_button_handler.dart';

/// Reusable PopScope wrapper for Nardana Connect screens.
/// Guarantees consistent Android hardware Back and gesture behavior,
/// automatically dismissing keyboard/modals first, running custom pop hooks,
/// and safely falling back to a parent route if canPop is false.
class AppBackScope extends StatelessWidget {
  final Widget child;
  final String fallbackRoute;
  final Future<bool> Function()? onWillPop;
  final VoidCallback? onCustomPop;
  final bool dismissKeyboardFirst;
  final bool isLocked; // If true, completely blocks back navigation (e.g. Force Update)

  const AppBackScope({
    super.key,
    required this.child,
    this.fallbackRoute = '/home',
    this.onWillPop,
    this.onCustomPop,
    this.dismissKeyboardFirst = true,
    this.isLocked = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLocked) {
      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          // Locked: cannot pop
        },
        child: child,
      );
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        // 1. If keyboard is visible and dismissKeyboardFirst is enabled, dismiss keyboard first
        if (dismissKeyboardFirst) {
          final focus = FocusScope.of(context);
          if (focus.hasFocus) {
            focus.unfocus();
            // Let the UI breathe so keyboard closes
            return;
          }
        }

        // 2. Custom onWillPop hook (e.g., search query clear, dirty form prompt)
        if (onWillPop != null) {
          final shouldProceed = await onWillPop!();
          if (!shouldProceed) return;
        }

        // 3. Custom pop callback if provided
        if (onCustomPop != null) {
          onCustomPop!();
          return;
        }

        // 4. Standard safe pop
        if (!context.mounted) return;
        BackButtonHandler.safePop(context, fallbackRoute: fallbackRoute);
      },
      child: child,
    );
  }
}
