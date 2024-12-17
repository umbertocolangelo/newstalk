import 'package:dima/pages/searching_page.dart';
import 'package:dima/widgets/articleCard/articleDiscoveryCard.dart';
import 'package:dima/widgets/communityCard/communityDiscoveryCard.dart';
import 'package:dima/widgets/searchBar/searchBarSearchingWidget.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../mocks/mock.dart';

void main() {
  setupFirebaseAuthMocks();

  setUpAll(() async {
    await Firebase.initializeApp();
  });

  testWidgets('Check that the Searching page is correctly instantiated', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: SearchingPage(),
    ));

    expect(find.byType(AppBar), findsOneWidget);
    expect(find.text('Cerca'), findsOneWidget);
    expect(find.text('Articoli'), findsOneWidget);
    expect(find.text('Community'), findsOneWidget);
    expect(find.byType(SearchBarSearching), findsOneWidget);
    expect(find.byType(ArticleCardDiscovery), findsNothing);
    expect(find.byType(CommunityDiscoveryCard), findsNothing);

  });


  testWidgets('Check search category selection', (WidgetTester tester) async {

    await tester.pumpWidget(MaterialApp(
      home: SearchingPage(),
    ));
    
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.arrow_drop_down), findsOneWidget);

    // Simulate a tap on the dropdown menu
    await tester.tap(find.byIcon(Icons.arrow_drop_down));
    await tester.pumpAndSettle();

    // Select a category
    await tester.tap(find.text('Attualità').last);
    await tester.pumpAndSettle();

    expect(find.text('Attualità'), findsOneWidget);
  });
}
