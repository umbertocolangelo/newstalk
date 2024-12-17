import 'package:dima/managers/controllers/article_controller.dart';
import 'package:dima/managers/controllers/community_controller.dart';
import 'package:dima/managers/controllers/thread_controller.dart';
import 'package:dima/model/globals.dart';
import 'package:dima/pages/article_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:provider/provider.dart';

import '../mocks/mock.dart';
import '../mocks/mockArticle.dart';
import '../mocks/mock_setup.dart';

void main() {
  late CommunityController mockCommunityController;
  late ArticleController mockArticleController;
  late ThreadController mockThreadController;
  setupFirebaseAuthMocks();

  setUpAll(() async {
    Globals.instance.userUid = '1';
    mockCommunityController = MockSetup.createMockCommunityController();
    mockArticleController = MockSetup.createMockArticleController();
    mockThreadController = MockSetup.createMockThreadController();
    await Firebase.initializeApp();
  });



  testWidgets('Display the article correctly', (WidgetTester tester) async {
    await mockNetworkImagesFor(() async {
      
      await tester.pumpWidget(
        ChangeNotifierProvider<ArticleController>(
          create: (_) => mockArticleController,
          child: MaterialApp(
            home: ArticleScreen(
              article: mockArticle,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();  

      expect(find.text(mockArticle.title), findsOneWidget);
      expect(find.text(mockArticle.description), findsOneWidget);
      expect(find.text(mockArticle.author), findsOneWidget);
    });
  });


  //Mock url launcher functionality
  testWidgets('Check lunch url', (WidgetTester tester) async {

    await mockNetworkImagesFor(() async {
        
        await tester.pumpWidget(
          ChangeNotifierProvider<ArticleController>(
            create: (_) => mockArticleController,
            child: MaterialApp(
              home: ArticleScreen(
                article: mockArticle,
              ),
            ),
          ),
        );

        await tester.pumpAndSettle(); 

    // Assert that the dropdown icon is present
    expect(find.byIcon(FontAwesomeIcons.globe), findsOneWidget);

    // Simulate a tap on the dropdown menu
    await tester.tap(find.byIcon(FontAwesomeIcons.globe));
    await tester.pumpAndSettle();

    });
  });


  //Mock copy of the id of article on clipboard

  testWidgets('Check copy idArticle Icon button', (WidgetTester tester) async {
    // Set up a mock clipboard
    String? clipboardContent;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (MethodCall methodCall) async {
        if (methodCall.method == 'Clipboard.setData') {
          final Map<String, dynamic> arguments = methodCall.arguments as Map<String, dynamic>;
          clipboardContent = arguments['text'] as String?;
          return;
        }
      },
    );

    await mockNetworkImagesFor(() async {
      await tester.pumpWidget(
        ChangeNotifierProvider<ArticleController>(
          create: (_) => mockArticleController,
          child: MaterialApp(
            home: ArticleScreen(
              article: mockArticle,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle(); 

      expect(find.byIcon(FontAwesomeIcons.shareNodes), findsOneWidget);

      // Simulate a tap on the share icon
      await tester.tap(find.byIcon(FontAwesomeIcons.shareNodes));
      await tester.pumpAndSettle();
    });

    // Assert that the clipboard content is as expected
    expect(clipboardContent, equals("%%"+ mockArticle.articleId+"%%"));
  });


 //Mock  create Thred 
  testWidgets('Check create thread fucntionality', (WidgetTester tester) async {
    await mockNetworkImagesFor(() async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<ArticleController>(create: (_) => mockArticleController,),
            ChangeNotifierProvider<CommunityController>(create: (_) => mockCommunityController,),
            ChangeNotifierProvider<ThreadController>(create: (_) => mockThreadController,),
          ],
          child: MaterialApp(
            home: ArticleScreen(
              article: mockArticle,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle(); 

      // Assert that the share icon is present
      expect(find.byIcon(FontAwesomeIcons.commentDots), findsOneWidget);

      // Simulate a tap on the share icon
      await tester.tap(find.byIcon(FontAwesomeIcons.commentDots));
      await tester.pump();

      expect(find.text('Crea Nuovo Thread'), findsOneWidget);

    });

  });
}
