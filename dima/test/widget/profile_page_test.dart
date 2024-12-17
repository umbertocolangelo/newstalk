import 'package:dima/managers/controllers/article_controller.dart';
import 'package:dima/managers/controllers/community_controller.dart';
import 'package:dima/managers/controllers/thread_controller.dart';
import 'package:dima/managers/controllers/user_controller.dart';
import 'package:dima/model/globals.dart';
import 'package:dima/widgets/profilePage/personal_view.dart';
import 'package:dima/widgets/profilePage/public_view.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import '../mocks/mock.dart';
import '../mocks/mockUser.dart';
import '../mocks/mock_setup.dart';

void main() {
  setupFirebaseAuthMocks();
  late UserController mockUserController;
  late CommunityController mockCommunityController;
  late ThreadController mockThreadController;
  late ArticleController mockArticleController;

  setUpAll(() async {
    await Firebase.initializeApp();
    mockUserController = MockSetup.createMockUserController();
    mockCommunityController = MockSetup.createMockCommunityController();
    mockThreadController = MockSetup.createMockThreadController();
    mockArticleController = MockSetup.createMockArticleController();
    Globals.instance.userUid = "1";
  });

  Widget createWidgetUnderTest() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<UserController>(create: (_) => mockUserController,),
        ChangeNotifierProvider<CommunityController>(create: (_) => mockCommunityController,),
        ChangeNotifierProvider<ThreadController>(create: (_) => mockThreadController,),
        ChangeNotifierProvider<ArticleController>(create: (_) => mockArticleController,),
      ],
      child: MaterialApp(
        home: PublicView(userId: '2',),
      ),
    );
  }

  group('Public Profile Page Widget Tests', () {
    testWidgets('Check that the Public Profile page is correctly instantiated', (WidgetTester tester) async {

      await tester.pumpWidget(MultiProvider(
        providers: [
          ChangeNotifierProvider<UserController>(create: (_) => mockUserController,),
          ChangeNotifierProvider<CommunityController>(create: (_) => mockCommunityController,),
          ChangeNotifierProvider<ThreadController>(create: (_) => mockThreadController,),
          ChangeNotifierProvider<ArticleController>(create: (_) => mockArticleController,),
        ],
        child: MaterialApp(
          home: PublicView(userId: user1.id,),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.textContaining('Profilo'), findsOneWidget);
      expect(find.text('Community'), findsOneWidget);
      expect(find.text('Thread'), findsOneWidget);
      expect(find.text(user1.name), findsOneWidget);
      expect(find.text(user1.username), findsOneWidget);
      expect(find.text(user1.bio), findsOneWidget);
    });

    testWidgets('Check that the Private Profile page is correctly instantiated', (WidgetTester tester) async {

      await tester.pumpWidget(MultiProvider(
        providers: [
          ChangeNotifierProvider<UserController>(create: (_) => mockUserController,),
          ChangeNotifierProvider<CommunityController>(create: (_) => mockCommunityController,),
          ChangeNotifierProvider<ThreadController>(create: (_) => mockThreadController,),
          ChangeNotifierProvider<ArticleController>(create: (_) => mockArticleController,),
        ],
        child: MaterialApp(
          home: PersonalView(),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.textContaining('Profilo'), findsOneWidget);
      expect(find.text('Community'), findsOneWidget);
      expect(find.text('Thread'), findsOneWidget);
      expect(find.text(user2.name), findsOneWidget);
      expect(find.text(user2.username), findsOneWidget);
      expect(find.text(user2.bio), findsOneWidget);
    });
  });
}
