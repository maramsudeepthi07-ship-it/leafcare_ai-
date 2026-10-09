import 'package:flutter_test/flutter_test.dart';
import 'package:leafcare_ai/main.dart';
import 'package:flutter/material.dart';

void main() {
  testWidgets('Login screen loads correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const LeafCareApp());

    // Verify that the login screen is displayed with its key elements.
    expect(find.text('LeafCare AI'), findsWidgets);
    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Farmer Login'), findsOneWidget);
    
    // Verify that the email and password fields are present.
    expect(find.byType(TextField), findsNWidgets(2));
  });
}
