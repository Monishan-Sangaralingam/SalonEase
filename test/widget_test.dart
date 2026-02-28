// Basic widget test for the SalonEase app.

import 'package:flutter_test/flutter_test.dart';

import 'package:salon_app/main.dart';

void main() {
  testWidgets('App renders without Firebase (shows error screen)', (
    WidgetTester tester,
  ) async {
    // When Firebase is not initialized, MyApp shows FirebaseInitErrorScreen.
    await tester.pumpWidget(
      const MyApp(firebaseInitError: 'Test: Firebase not configured'),
    );
    await tester.pumpAndSettle();

    // Verify the error screen is shown with diagnostic text.
    expect(
      find.text('Firebase is not configured for this platform'),
      findsOneWidget,
    );
    expect(
      find.textContaining('Test: Firebase not configured'),
      findsOneWidget,
    );
  });
}
