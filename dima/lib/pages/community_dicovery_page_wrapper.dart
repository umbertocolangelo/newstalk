import 'package:dima/managers/provider/rebuild_provider.dart';
import 'package:dima/pages/community_feed_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CommunityFeedPageWrapper extends StatelessWidget {
  const CommunityFeedPageWrapper({super.key});
  @override
  Widget build(BuildContext context) {
    return Consumer<RebuildNotifier>(
      builder: (context, rebuildNotifier, child) {
        return CommunityFeedPage(key: rebuildNotifier.key,);
      },
    );
  }
}