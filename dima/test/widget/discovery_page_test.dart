import 'dart:io';
import 'package:dima/managers/provider/article_provider.dart';
import 'package:dima/pages/discovery_page.dart';
import 'package:dima/widgets/articleCard/articleDialogCard.dart';
import 'package:dima/widgets/articleCard/articleDiscoveryCard.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:provider/provider.dart';

import '../mocks/mock.dart';
import '../mocks/mockArticle.dart';
import '../mocks/mock_setup.dart';

void main() {
  late ArticleRepository createMockArticleRepository;
  setupFirebaseAuthMocks();

  setUpAll(() async {
    createMockArticleRepository = MockSetup.createMockArticleRepository();
    await Firebase.initializeApp();
    HttpOverrides.global = null;
  });

  testWidgets('Display the article correctly', (WidgetTester tester) async {

    await mockNetworkImagesFor(() async {

        await tester.pumpWidget(
          ChangeNotifierProvider<ArticleRepository>(
            create: (_) => createMockArticleRepository,
            child: MaterialApp(
              home: Container(
                alignment: Alignment.center,
                child: DiscoveryPage(),
              ),
            ),
          ),
        );
        
        await tester.pump();

        expect(find.text(mockArticleList[0].title), findsOneWidget);
        expect(find.text(mockArticleList[0].description), findsOneWidget);
      });
    });


    testWidgets('Click on articleCard and show article dialog', (WidgetTester tester) async {

    await mockNetworkImagesFor(() async {

        await tester.pumpWidget(
          ChangeNotifierProvider<ArticleRepository>(
            create: (_) => createMockArticleRepository,
            child: MaterialApp(
              home: Container(
                alignment: Alignment.center,
                child: DiscoveryPage(),
              ),
            ),
          ),
        );
        await tester.pump();

        await tester.pumpAndSettle();

        // Assert that the dropdown icon is present

        // Simulate a tap on the dropdown menu
        await tester.tap(find.byElementType(ArticleCardDiscovery));
        await tester.pumpAndSettle();
        // Assert that 'Attualità' is selected and visible
        expect(find.byElementType(ArticleCardDialog), findsOneWidget);
    });
    });

}


