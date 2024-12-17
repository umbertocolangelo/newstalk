import 'package:dima/managers/controllers/article_controller.dart';
import 'package:dima/managers/controllers/community_controller.dart';
import 'package:dima/managers/controllers/thread_controller.dart';
import 'package:dima/managers/controllers/user_controller.dart';
import 'package:dima/model/globals.dart';
import 'package:dima/pages/create_thread_page.dart';
import 'package:dima/pages/thread_chat_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import '../mocks/mock.dart';
import '../mocks/mockCommunity.dart';
import '../mocks/mock_setup.dart';

void main() {
    late CommunityController mockCommunityController;
    late ArticleController mockArticleController;
    late ThreadController mockThreadController;
    late UserController mockUserController;
    setupFirebaseAuthMocks();

    setUpAll(() async {
      Globals.instance.userUid = '1';
      mockCommunityController = MockSetup.createMockCommunityController();
      mockArticleController = MockSetup.createMockArticleController();
      mockThreadController = MockSetup.createMockThreadController();
      mockUserController = MockSetup.createMockUserController();
      await Firebase.initializeApp();
    });
  testWidgets('Login test with valid credentials', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<ArticleController>(create: (_) => mockArticleController,),
          ChangeNotifierProvider<CommunityController>(create: (_) => mockCommunityController,),
          ChangeNotifierProvider<ThreadController>(create: (_) => mockThreadController,),
          ChangeNotifierProvider<UserController>(create: (_) => mockUserController,),
        ],
        child: const CreateThreadPage(articleId: 'mock-article-001'),
      ),
    );

    expect(find.text("Seleziona la Community in cui vuoi creare il Thread"), findsOneWidget);
    expect(find.text(community1.name), findsOneWidget);
    expect(find.textContaining("Admin"), findsOneWidget); 
  
    await tester.tap(find.text(community1.name));
    await tester.pumpAndSettle();

    expect(find.text("Inserisci il nome del nuovo Thread"), findsOneWidget);
    expect(find.text("Conferma"), findsOneWidget); 

    await tester.enterText(find.byType(TextField), 'thread1');
    
    await tester.tap(find.text('Conferma'));
    await tester.pumpAndSettle();

    expect(find.byType(ThreadChatPage), findsOneWidget);
    expect(find.text('thread1'), findsOneWidget);

  });

}
