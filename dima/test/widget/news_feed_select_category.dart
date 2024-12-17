import 'package:dima/managers/controllers/article_controller.dart';
import 'package:dima/widgets/newsFeed/newsFeedForCategory.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import '../mocks/mock.dart';
import '../mocks/mockArticle.dart';
import '../mocks/mock_setup.dart';

void main() {
  late ArticleController mockArticleController;
  setupFirebaseAuthMocks();
  
  setUpAll(() async {
    mockArticleController = MockSetup.createMockArticleController();
    await Firebase.initializeApp();
  });

  testWidgets('News Category Bar changes category', (WidgetTester tester) async {

    await tester.pumpWidget(
      ChangeNotifierProvider<ArticleController>(
        create: (_) => mockArticleController,
        child: MaterialApp(
          home: NewsFeedForCategory(swiperIndex: {}, controller: ScrollController(), category: 'Tecnologia', sources: const {"il_foglio"},),
        ),
      ),
    );
    
    // Verify that the loading indicator is shown initially
   // expect(find.byType(CircularProgressIndicator), findsOneWidget);
    
    // Wait for the Future to complete
    await tester.pump();
    
    // Verify that articles are displayed after loading
   //expect(find.byType(mockArticle as Type), findsWidgets);
  });
}
