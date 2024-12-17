import 'package:dima/managers/provider/navigation_provider.dart';
import 'package:dima/pages/community_dicovery_page_wrapper.dart';
import 'package:dima/pages/news_feed_wrapper_page.dart';
import 'package:dima/pages/profile_page.dart';
import 'package:dima/utils/palette.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/bottom_nav_bar.dart';
import 'discovery_page.dart';
import 'map_page.dart';

class HomePage extends StatefulWidget {
  static const routeName = '/home';

  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    final navigationModel = Provider.of<NavigationProvider>(context);

    final List<Widget> pages = [
      NewsFeedPageWrapper(),
      MapPage(),
      DiscoveryPage(),
      CommunityFeedPageWrapper(),
      ProfilePage(),
    ];

    return Scaffold(
      backgroundColor: Palette.offWhite,
      body: IndexedStack(
        index: navigationModel.selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: BottomNavBar(
        index: navigationModel.selectedIndex,
        onItemSelected: (index) {
          navigationModel.setIndex(index);
        },
      ),
    );
  }
}
