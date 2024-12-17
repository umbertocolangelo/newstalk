import 'package:dima/managers/controllers/article_controller.dart';
import 'package:dima/managers/controllers/community_controller.dart';
import 'package:dima/managers/controllers/thread_controller.dart';
import 'package:dima/managers/controllers/user_controller.dart';
import 'package:dima/managers/provider/navigation_provider.dart';
import 'package:dima/managers/provider/rebuild_provider.dart';
import 'package:dima/managers/provider/userEdit_provider.dart';
import 'package:dima/model/globals.dart';
import 'package:dima/pages/community_dicovery_page_wrapper.dart';
import 'package:dima/pages/discovery_page.dart';
import 'package:dima/pages/login_page.dart';
import 'package:dima/pages/map_page.dart';
import 'package:dima/pages/news_feed_wrapper_page.dart';
import 'package:dima/pages/profile_page.dart';
import 'package:dima/widgets/bottom_nav_bar.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:dima/main.dart';
import 'package:dima/pages/home_page.dart';
import 'package:dima/managers/services/auth_service.dart';

import '../mocks/mock.dart';
import '../mocks/mock_setup.dart';

class MockAuthService extends Mock implements AuthService {}
class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockUserCredential extends Mock implements UserCredential {}
class MockUser extends Mock implements User {}

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
    final mockFirebaseAuth = MockFirebaseAuth();
    final mockUser = MockUser();
    final mockUserCredential = MockUserCredential();

    when(mockUserCredential.user).thenReturn(mockUser);
    when(mockFirebaseAuth.signInWithEmailAndPassword(
      email: 'valid@example.com',
      password: 'validpassword',
    )).thenAnswer((_) async => mockUserCredential);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => UserEditProvider()),
          ChangeNotifierProvider(create: (_) => RebuildNotifier()),
          ChangeNotifierProvider(create: (_) => NavigationProvider()),
          ChangeNotifierProvider<ArticleController>(create: (_) => mockArticleController,),
          ChangeNotifierProvider<CommunityController>(create: (_) => mockCommunityController,),
          ChangeNotifierProvider<ThreadController>(create: (_) => mockThreadController,),
          ChangeNotifierProvider<UserController>(create: (_) => mockUserController,),
        ],
        child: const MainApp(),
      ),
    );

    expect(find.byType(LoginPage), findsOneWidget);

    await tester.enterText(find.byType(TextField).at(0), 'valid@example.com');
    await tester.enterText(find.byType(TextField).at(1), 'validpassword');

    await tester.tap(find.text('Accedi'));
    await tester.pumpAndSettle();

    expect(find.byType(HomePage), findsOneWidget);
    
    await tester.tap(find.text('Go to Dashboard'));
    await tester.pumpAndSettle();

    expect(find.byType(HomePage), findsOneWidget);

    expect(find.byType(BottomNavBar), findsOneWidget);

    final navBarButtons = find.byType(IconButton);

    expect(navBarButtons, findsNWidgets(5));

    await tester.tap(navBarButtons.at(0));
    await tester.pumpAndSettle();

    expect(find.byType(NewsFeedPageWrapper), findsOneWidget);

    await tester.tap(navBarButtons.at(1));
    await tester.pumpAndSettle();

    expect(find.byType(MapPage), findsOneWidget);

    await tester.tap(navBarButtons.at(2));
    await tester.pumpAndSettle();

    expect(find.byType(DiscoveryPage), findsOneWidget);


    await tester.tap(navBarButtons.at(3));
    await tester.pumpAndSettle();

    expect(find.byType(CommunityFeedPageWrapper), findsOneWidget);

    await tester.tap(navBarButtons.at(4));
    await tester.pumpAndSettle();

    expect(find.byType(ProfilePage), findsOneWidget);

  });

}
