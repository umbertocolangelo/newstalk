import 'package:dima/pages/register_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import '../mocks/mock.dart';

void main() {
  setupFirebaseAuthMocks();

  setUpAll(() async {
    await Firebase.initializeApp();
  });

  testWidgets('Check that the Register page is correctly instantiated', (WidgetTester tester) async {
    void _onTap() {}

    await tester.pumpWidget(
      MaterialApp(
        home: RegisterPage(onLoginTap: _onTap),
      ),
    );
    await tester.pumpAndSettle(); 

    expect(find.textContaining('Benvenuto! Iscriviti ora', skipOffstage: false), findsOneWidget);
    expect(find.textContaining('O continua con', skipOffstage: false), findsOneWidget);
    expect(find.textContaining('Hai già un account?', skipOffstage: false), findsOneWidget);
    expect(find.textContaining('Accedi ora', skipOffstage: false), findsOneWidget);

  });
}
