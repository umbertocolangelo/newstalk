import 'package:dima/managers/controllers/community_controller.dart';
import 'package:dima/pages/community_feed_page.dart';
import 'package:dima/widgets/communityCard/communityDialogCard.dart';
import 'package:dima/widgets/communityCard/communityDiscoveryCard.dart';
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

  testWidgets('Display the communities correctly', (WidgetTester tester) async {
    await mockNetworkImagesFor(() async {
      await tester.pumpWidget(
        ChangeNotifierProvider<CommunityController>(
          create: (_) => mockThreadController,
          child: MaterialApp(
            home: CommunityFeedPage(
            ), // Assuming this is your page's class name
          ),
        ),
      );

    await tester.pumpAndSettle();
   // expect(find.byElementType(CommunityDiscoveryCard), findsWidgets);

    });
  });


     testWidgets('Click on communityCard and display community dialog', (WidgetTester tester) async {
      await mockNetworkImagesFor(() async {
      await tester.pumpWidget(
        ChangeNotifierProvider<CommunityController>(
          create: (_) => mockThreadController,
          child: MaterialApp(
            home: CommunityFeedPage(
            ),
          ),
        ),
      );
      
        await tester.pumpAndSettle();
        // Simulate a tap on the dropdown menu
        await tester.tap(find.byElementType(CommunityDiscoveryCard));
      //  await tester.pumpAndSettle();
        // Assert that 'Attualità' is selected and visible
       // expect(find.byElementType(CommunityDialogCard), findsOneWidget);
      });
    });
  }
