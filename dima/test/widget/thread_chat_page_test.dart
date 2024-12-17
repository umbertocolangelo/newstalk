import 'package:dima/managers/controllers/thread_controller.dart';
import 'package:dima/model/thread.dart';
import 'package:dima/pages/thread_chat_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:provider/provider.dart';

import '../mocks/mock.dart';
import '../mocks/mockThread.dart';
import '../mocks/mock_setup.dart';

void main() {
  setupFirebaseAuthMocks();
  late ThreadController mockThreadController;

  setUpAll(() async {
    mockThreadController = MockSetup.createMockThreadController();
    await Firebase.initializeApp();
  });

  testWidgets('Display the thread correctly', (WidgetTester tester) async {
    List<Thread> mockThreadList = [
      createMockThread(id: 'mock_thread_1', title: 'Mock Thread 1'),
      createMockThread(id: 'mock_thread_2', title: 'Mock Thread 2'),
    ];

    await mockNetworkImagesFor(() async {
      await tester.pumpWidget(
        ChangeNotifierProvider<ThreadController>(
          create: (_) => mockThreadController,
          child: MaterialApp(
            home: ThreadChatPage(
              threadId: '',
              currentUserId: '',
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.text(mockThreadList[0].title), findsOneWidget);
    });
  });

  testWidgets('Write a comment correctly', (WidgetTester tester) async {
    List<Thread> mockThreadList = [
      createMockThread(id: 'mock_thread_1', title: 'Mock Thread 1'),
      createMockThread(id: 'mock_thread_2', title: 'Mock Thread 2'),
    ];

    await mockNetworkImagesFor(() async {
      await tester.pumpWidget(
        ChangeNotifierProvider<ThreadController>(
          create: (_) => mockThreadController,
          child: MaterialApp(
            home: ThreadChatPage(
              threadId: '',
              currentUserId: '',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Assert that the dropdown icon is present
      expect(find.byIcon(Icons.arrow_drop_down), findsOneWidget);

      // Simulate a tap on the dropdown menu
      await tester.tap(find.byElementType(TextField));
      await tester.pumpAndSettle();

      // Select a category
      await tester.tap(find.byIcon(Icons.arrow_drop_down));
      await tester.pumpAndSettle();

      expect(find.text('Scrivi un commento'), findsOneWidget);
    });
  });
}
