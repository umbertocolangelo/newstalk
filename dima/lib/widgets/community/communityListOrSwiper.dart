import 'dart:ui';

import 'package:dima/utils/palette.dart';
import 'package:dima/widgets/community/community_list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_swiper_null_safety/flutter_swiper_null_safety.dart';

import '../../model/community.dart';
import '../../model/user.dart';
import '../communityCard/communityHomeCard.dart';

class CommunityListOrSwiper extends StatelessWidget {
  final bool isListView;
  final List<Community> communities;
  final bool isLoadingMore;
  final Map<String, User> admins;
  final VoidCallback onLoadMore;
  final SwiperController swiperController;
  final bool isFetchingInitialData;

  const CommunityListOrSwiper({
    required this.isListView,
    required this.communities,
    required this.isLoadingMore,
    required this.admins,
    required this.onLoadMore,
    required this.swiperController,
    required this.isFetchingInitialData,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Palette.offWhite,
      child: isListView
          ? _buildListView()
          : _buildSwiperView(BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height,
            )),
    );
  }

  Widget _buildListView() {
    return communities.length == 0
        ? Center(
            child: Padding(
              padding: EdgeInsets.fromLTRB(15.sp, 0, 15.sp, 30.sp),
              child: Text(
                'Nessuna community ancora presente in questa categoria.\nCrea tu la prima!',
                style: TextStyle(
                  color: Palette.grey,
                  fontSize: 20.sp,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          )
        : ListView.builder(
            padding:  EdgeInsets.all(5.sp),
            itemCount: communities.length,
            itemBuilder: (context, index) {
              Community community = communities[index];
              User? admin = admins[community.adminId];
              return Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Palette.offWhite,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    color: Palette.offWhite,
                    child: CommunityListItem(
                      community: community,
                      admin: admin,
                    ),
                  ),
                ],
              );
            },
          );
  }

  Widget _buildSwiperView(BoxConstraints constraints) {
    return communities.length == 0
        ? Center(
            child: Padding(
              padding: EdgeInsets.fromLTRB(15.sp, 0, 15.sp, 30.sp),
              child: Text(
                'Nessuna community ancora presente in questa categoria.\nCrea tu la prima!',
                style: TextStyle(
                  color: Palette.grey,
                  fontSize: 20.sp,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          )
        : Swiper(
            controller: swiperController,
            itemCount: isFetchingInitialData ? (communities.length > 5 ? 5 : communities.length) : communities.length,
            onIndexChanged: (int index) {
              if (index == communities.length && !isLoadingMore) {
                onLoadMore();
              }
            },
            itemBuilder: (context, index) {
              Community community = communities[index];
              User? admin = admins[community.adminId];
              return communityHomeCard(
                community: community,
                admin: admin,
                height: constraints.maxHeight,
                width: constraints.maxWidth * 0.8,
              );
            },
            itemWidth: constraints.maxWidth * 0.8,
            itemHeight: constraints.maxHeight,
            viewportFraction: 0.85,
            scale: 0.8,
            loop: false,
            duration: 1000,
            curve: Curves.easeInOut,
          );
  }
}
