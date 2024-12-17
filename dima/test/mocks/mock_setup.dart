import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima/managers/controllers/article_controller.dart';
import 'package:dima/managers/controllers/comment_controller.dart';
import 'package:dima/managers/provider/article_provider.dart';
import 'package:dima/model/article.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:dima/managers/controllers/community_controller.dart';
import 'package:dima/managers/controllers/user_controller.dart';
import 'package:dima/managers/controllers/thread_controller.dart';
import 'package:dima/model/thread.dart';
import 'package:http/http.dart' as http;
import 'mockArticle.dart';

import 'mockCommunity.dart';
import 'mockThread.dart';
import 'mockUser.dart';
@GenerateNiceMocks([
  MockSpec<CommunityController>(),
  MockSpec<UserController>(),
  MockSpec<ThreadController>(),
  MockSpec<ArticleController>(),
  MockSpec<ArticleRepository>(),
  MockSpec<CommentController>(),
  MockSpec<http.Client>(),
])
import 'mock_setup.mocks.dart';

// Classe di configurazione dei mock
class MockSetup {
  static CommunityController createMockCommunityController() {
    final mock = MockCommunityController();

    when(mock.getCommunityById('1')).thenAnswer((_) async => community1);

    when(mock.getCommunitiesByUserId('1'))
        .thenAnswer((_) async => [community1]);

    when(mock.getCommunitiesByIds(['1'])).thenAnswer((_) async => [community1]);
    when(mock.getCommunitiesByIds(['2'])).thenAnswer((_) async => [community2]);
    when(mock.getCommunitiesByIds(['1', '2']))
        .thenAnswer((_) async => [community1, community2]);

    when(mock.getCommunityById('2')).thenAnswer((_) async => community2);

    when(mock.getCommunitiesByUserId('2'))
        .thenAnswer((_) async => [community2]);

    return mock;
  }

  static UserController createMockUserController() {
    final mock = MockUserController();

    when(mock.getUserById('1')).thenAnswer((_) async => user1);

    when(mock.getUsersByCommunityId('1')).thenAnswer((_) async => [user1]);

    when(mock.getUsersByCommunityId('2'))
        .thenAnswer((_) async => [user1, user2]);
    return mock;
  }

  static ThreadController createMockThreadController() {
    final mock = MockThreadController();

    List<Thread> mockThreadList = [
      createMockThread(id: 'mock_thread_1', title: 'Mock Thread 1'),
      createMockThread(id: 'mock_thread_2', title: 'Mock Thread 2'),
    ];

    when(mock.getThreadsByCommunityId(any)).thenAnswer((_) async => [
          Thread(
            id: '1',
            articleIds: [],
            authorId: '1',
            participantIds: [],
            communityId: '1',
            title: 'thread1',
            upvotes: 0,
            downvotes: 0,
            commentIds: [],
            time: Timestamp.now(),
          )
        ]);

    when(mock.getThreadsByAuthorId(any)).thenAnswer((_) async => [
          Thread(
            id: '1',
            articleIds: [],
            authorId: '1',
            participantIds: [],
            communityId: '1',
            title: 'thread1',
            upvotes: 0,
            downvotes: 0,
            commentIds: [],
            time: Timestamp.now(),
          )
        ]);

    // Setup mock behavior for `fetchThreads`
    when(mock.fetchThreads()).thenAnswer((_) => Future.value(mockThreadList));

    // Setup mock behavior for `getThreadById`
    when(mock.getThreadById(any)).thenAnswer((invocation) {
      final threadId = invocation.positionalArguments[0] as String;
      return Future.value(
        mockThreadList.firstWhere((thread) => thread.id == threadId,
            orElse: () => mockThreadList[0]),
      );
    });

    // Setup mock behavior for `addThread`
    when(mock.addThread(any)).thenAnswer((_) => Future.value());

    // Setup mock behavior for `updateThread`
    when(mock.updateThread(any, any)).thenAnswer((_) => Future.value());

    // Setup mock behavior for `deleteThread`
    when(mock.deleteThread(any)).thenAnswer((_) => Future.value());

    // Add more setups as needed for other methods

    return mock;
  }

// Function to set up the mock for testing
  static MockArticleController createMockArticleController() {
    final mock = MockArticleController();

    // Sample data
    List<Article> techArticles = mockArticleList
        .where((article) => article.category == 'Technology')
        .toList();
    List<Article> scienceArticles = mockArticleList
        .where((article) => article.category == 'Science')
        .toList();
    List<Article> attualitaArticles =
        mockArticleList; // Assuming mockArticleList contains 'attualità' articles

    // Mocking fetchArticlesForCategory method
    when(mock.fetchArticlesForCategory("attualità")).thenAnswer((_) async {
      return Future.delayed(Duration(seconds: 2), () => attualitaArticles);
    });

    // Mocking getArticlesForCategory method
    when(mock.getArticlesForCategory('tecnologia')).thenReturn(techArticles);
    when(mock.getArticlesForCategory('salute')).thenReturn(scienceArticles);
    when(mock.getArticlesForCategory("attualità"))
        .thenReturn(attualitaArticles);

    // Mocking fetchArticlesForCategoryFilteredBySources method
    when(mock.fetchArticlesForCategoryFilteredBySources(
        'tecnologia', {'il_foglio'})).thenAnswer((invocation) async {
      final Set<String> sources = invocation.positionalArguments[1];
      return Future.delayed(Duration(seconds: 2), () => mockArticleList);
    });

    // Mocking loadMoreArticlesFilteredBySources method
    when(mock.loadMoreArticlesFilteredBySources('Technology', {'il_foglio'}))
        .thenAnswer((invocation) async {
      return Future.delayed(Duration(seconds: 2), () => mockArticleList);
    });

    return mock;
  }

  static ArticleRepository createMockArticleRepository() {
    final mock = MockArticleRepository();

    // Setup mock behavior for `fetchArticles`
    when(mock.fetchArticles(any, any))
        .thenAnswer((_) => Future.value(mockArticleList));

    // Setup mock behavior for `fetchArticlesFilteredBySources`
    when(mock.fetchArticlesFilteredBySources(any, any, any))
        .thenAnswer((_) => Future.value(mockArticleList));

    // Setup mock behavior for `retrieveAllArticles`
    when(mock.retrieveAllArticles())
        .thenAnswer((_) => Future.value([mockArticleList]));

    // Setup mock behavior for other methods as needed
    // Example for `fetchArticlesInBatch`
    when(mock.fetchArticlesInBatch(any))
        .thenAnswer((_) => Future.value(mockArticleList));

    return mock;
  }

  static http.Client createMockHttpClient() {
    final mock = MockClient();

    when(mock.get(Uri.parse('https://example.com')))
        .thenAnswer((_) async => http.Response('{"message": "Success"}', 200));

    return mock;
  }
}
