import 'package:dima/managers/provider/rebuild_provider.dart';
import 'package:dima/pages/news_feed_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NewsFeedPageWrapper extends StatelessWidget {
  final Map<String, int> swiperIndex = {
    'Tutto': 0,
    'Attualità': 0,
    'Sport': 0,
    'Intrattenimento': 0,
    'Salute': 0,
    'Economia': 0,
    'Tecnologia': 0,
  };

  @override
  Widget build(BuildContext context) {
    return Consumer<RebuildNotifier>(
      builder: (context, rebuildNotifier, child) {
        return NewsFeedPage(key: rebuildNotifier.key, swiperIndex: swiperIndex);
      },
    );
  }
}
