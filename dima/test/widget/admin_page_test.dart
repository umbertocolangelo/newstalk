import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima/managers/controllers/community_controller.dart';
import 'package:dima/model/community.dart';
import 'package:dima/pages/community_admin_homepage.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:provider/provider.dart';

import '../mocks/mock.dart';
import '../mocks/mock_setup.dart';

void main() {
  setupFirebaseAuthMocks();
  late CommunityController mockThreadController;

  setUpAll(() async {
    mockThreadController = MockSetup.createMockCommunityController();
    await Firebase.initializeApp();
  });

  testWidgets('Display the requests correctly', (WidgetTester tester) async {
    Community community1 = Community(
      id: '1',
      name: 'Test Community',
      categories: ['Sport'],
      bio: 'Community bio',
      backgroundImagePath: '',
      profileImagePath: '',
      type: 'public',
      threadIds: ['1'],
      memberIds: ['1'],
      adminId: '1',
      requestStatus: {'2': 'pending'},
      createdAt: Timestamp.now(),
      coordinates: "45.464664,9.188540",
    );

    await mockNetworkImagesFor(() async {
      await tester.pumpWidget(
        ChangeNotifierProvider<CommunityController>(
          create: (_) => mockThreadController,
          child: MaterialApp(
            home: CommunityAdminHomePage(
              community: community1,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Attualità'), findsOneWidget);
    });
  });
}
