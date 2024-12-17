import 'package:dima/model/globals.dart';
import 'package:dima/pages/community_admin_homepage.dart';
import 'package:dima/widgets/community/member_home_page.dart';
import 'package:dima/widgets/community/limited_home_page.dart';
import 'package:flutter/material.dart';
import 'package:dima/model/community.dart';

class CommunityHomePage extends StatefulWidget {
  final Community community;

  const CommunityHomePage({
    Key? key,
    required this.community,
  }) : super(key: key);

  @override
  _CommunityHomePageState createState() => _CommunityHomePageState();
}

class _CommunityHomePageState extends State<CommunityHomePage> {
  @override
  Widget build(BuildContext context) {
    String userId = Globals.instance.userUid.toString();

    bool isMember = widget.community.memberIds.contains(userId);
    bool isAdmin = widget.community.adminId == userId;

    return Scaffold(
      body: isAdmin
          ? CommunityAdminHomePage(community: widget.community)
          : isMember
              ? MemberHomePage(community: widget.community)
              : LimitedHomePage(community: widget.community, userId: userId),
    );
  }
}
