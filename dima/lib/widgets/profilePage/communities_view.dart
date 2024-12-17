import 'package:dima/managers/controllers/community_controller.dart';
import 'package:dima/managers/controllers/user_controller.dart';
import 'package:dima/model/community.dart';
import 'package:dima/model/globals.dart';
import 'package:dima/model/user.dart';
import 'package:dima/utils/palette.dart';
import 'package:dima/widgets/community/community_list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CommunitiesView extends StatelessWidget {
  final String userId;
  const CommunitiesView({
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    CommunityController communityController = CommunityController();
    UserController userController = UserController();

    Future<List<Community>> fetchCommunities() async {
      if (userId.isEmpty) {
        return communityController
            .getCommunitiesByUserId(Globals.instance.userUid.toString());
      } else {
        User? currentUser = await userController
            .getUserById(Globals.instance.userUid.toString());
        User? targetUser = await userController.getUserById(userId);
        List<String> commonCommunityIds = currentUser.communityIds
            .where((id) => targetUser.communityIds.contains(id))
            .toList();
        return communityController.getCommunitiesByIds(commonCommunityIds);
      }
    }

    return Container(
      padding: const EdgeInsets.all(0),
      color: Palette.offWhite,
      child: FutureBuilder(
        future: fetchCommunities(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              return Scaffold(
                body: Column(
                  children: [
                    Expanded(
                      child: _listView(
                        context,
                        snapshot.data as List<Community>,
                      ),
                    ),
                  ],
                ),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text(snapshot.error.toString()),
              );
            } else {
              return const Center(
                child: Text('Errore'),
              );
            }
          } else {
            return Container(
              color: Palette.offWhite,
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Palette.grey),
                ),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _listView(BuildContext context, List<Community> communities) {
    UserController userController = UserController();
    return Container(
      color: Palette.offWhite,
      child: ListView.builder(
        itemCount: communities.length,
        padding:  EdgeInsets.all(5.sp),
        itemBuilder: (context, index) {
          Community community = communities[index];
          return FutureBuilder(
            future: userController.getUserById(community.adminId),
            builder: (context, adminSnapshot) {
              if (adminSnapshot.connectionState == ConnectionState.done) {
                if (adminSnapshot.hasData) {
                  User admin = adminSnapshot.data as User;
                  return CommunityListItem(
                    community: community,
                    admin: admin,
                  );
                } else if (adminSnapshot.hasError) {
                  return Center(
                    child: Text('Errore: ${adminSnapshot.error}'),
                  );
                } else {
                  return const Center(
                    child: Text('Errore'),
                  );
                }
              } else {
                return Container(
                  color: Palette.offWhite,
                  child: const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Palette.grey),
                    ),
                  ),
                );
              }
            },
          );
        },
      ),
    );
  }
}
