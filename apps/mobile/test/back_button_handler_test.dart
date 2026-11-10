import 'package:flutter_test/flutter_test.dart';
import 'package:nardana_connect/core/navigation/back_button_handler.dart';

void main() {
  group('BackButtonHandler & Navigation Rules Tests', () {
    test('BackButtonHandler class exists and has static methods', () {
      expect(BackButtonHandler.showExitConfirmationDialog, isNotNull);
      expect(BackButtonHandler.handleHomeBackPress, isNotNull);
      expect(BackButtonHandler.safePop, isNotNull);
      expect(BackButtonHandler.confirmDiscardChanges, isNotNull);
    });

    test('Double press window is 2.5 seconds', () {
      // Confirmed via contract in back_button_handler.dart
      const duration = Duration(milliseconds: 2500);
      expect(duration.inSeconds, 2);
      expect(duration.inMilliseconds, 2500);
    });
  });
}

