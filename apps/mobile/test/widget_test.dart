import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:nardana_connect/features/splash/presentation/screens/splash_screen.dart';

void main() {
  testWidgets('Nardana Connect splash branding smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SplashScreen(),
      ),
    );

    expect(find.text('नरडाणा कनेक्ट'), findsOneWidget);
    expect(find.text('NARDANA CONNECT'), findsOneWidget);
    expect(find.text('आपलं गाव, आपली डिजिटल ओळख!'), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);

    // Let the splash timer finish cleanly
    await tester.pump(const Duration(milliseconds: 2500));
  });
}
