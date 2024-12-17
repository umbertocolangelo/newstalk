import 'package:dima/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import '../mocks/mock.dart';
import 'package:dima/widgets/loginPage/login_fields.dart';

void main() {
  setupFirebaseAuthMocks();

  setUpAll(() async {
    await Firebase.initializeApp();
  });

  Widget createWidgetUnderTest({Function()? onRegisterTap}) {
    return MaterialApp(
      home: Scaffold(
        body: SafeArea(
          child: LoginPage(onRegisterTap: onRegisterTap),
        ),
      ),
    );
  }
    
  testWidgets('Check that the Login page is correctly instantiated', (WidgetTester tester) async {

    await tester.pumpWidget(createWidgetUnderTest());

    await tester.pumpAndSettle();
  
    expect(find.byType(Image), findsExactly(3));
    expect(find.byType(LoginFields), findsOneWidget);
    expect(find.byType(ElevatedButton), findsOneWidget);
    expect(find.text('Bentornato! Accedi per continuare'), findsOneWidget);
    expect(find.text('Oppure continua con'), findsOneWidget);
    expect(find.text('Non sei un membro?'), findsOneWidget);
    expect(find.text('Registrati ora'), findsOneWidget);

  });

}

