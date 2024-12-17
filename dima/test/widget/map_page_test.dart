import 'package:dima/managers/provider/article_provider.dart';
import 'package:dima/pages/map_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:provider/provider.dart';

import '../mocks/mock.dart';
import '../mocks/mock_setup.dart';

void main() {
  late ArticleRepository mockArticleController;
  setupFirebaseAuthMocks();

  setUpAll(() async {
    mockArticleController = MockSetup.createMockArticleRepository();
    await Firebase.initializeApp();
  });

  testWidgets('Display all widgets of Map Page correctly',
      (WidgetTester tester) async {
    await mockNetworkImagesFor(() async {
      
      await tester.pumpWidget(
        ChangeNotifierProvider<ArticleRepository>(
          create: (_) => mockArticleController,
          child: MaterialApp(
            home: MapPage(
            ),
          ),
        ),
      );

      expect(find.text("Tutto"), findsOneWidget);
      expect(find.text("Mappa"), findsOneWidget);
      //Panel icon
      expect(find.byIcon(Icons.groups), findsOneWidget);
      expect(find.byIcon(Icons.article_outlined), findsOneWidget);
      expect(find.text("Articoli"), findsOneWidget);
      expect(find.text("Community"), findsOneWidget);
      //Zoom icons
      expect(find.byIcon(FontAwesomeIcons.magnifyingGlassMinus), findsOneWidget);
      expect(find.byIcon(FontAwesomeIcons.magnifyingGlassPlus), findsOneWidget);
    });
  });


testWidgets('Display no article available on the map', (WidgetTester tester) async {
  await mockNetworkImagesFor(() async {

    await tester.pumpWidget(
      ChangeNotifierProvider<ArticleRepository>(
        create: (_) => mockArticleController,
        child: MaterialApp(
          home: MapPage(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Assert that the community icon is present
    expect(find.byIcon(Icons.article_outlined), findsOneWidget);

    // Simulate a tap on the community menu
    await tester.tap(find.byIcon(Icons.article_outlined));
    await tester.pumpAndSettle();

    expect(find.text("Nessun articolo in questa parte della mappa"), findsOneWidget);
  });
});



  testWidgets('Check search category selection', (WidgetTester tester) async {

    await mockNetworkImagesFor(() async {

      await tester.pumpWidget(
        ChangeNotifierProvider<ArticleRepository>(
          create: (_) => mockArticleController,
          child: MaterialApp(
            home: MapPage(), 
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Assert that the dropdown icon is present
      expect(find.byIcon(Icons.arrow_drop_down), findsOneWidget);

      // Simulate a tap on the dropdown menu
      await tester.tap(find.byIcon(Icons.arrow_drop_down));
      await tester.pumpAndSettle();

      // Select a category
      await tester.tap(find.text('Attualità').last);
      await tester.pumpAndSettle();

      // Assert that 'Attualità' is selected and visible
      expect(find.text('Attualità'), findsOneWidget);
    });
  });
}