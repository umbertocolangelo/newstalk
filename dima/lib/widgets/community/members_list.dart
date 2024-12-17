import 'package:dima/model/globals.dart';
import 'package:dima/model/user.dart';
import 'package:dima/pages/profile_page.dart';
import 'package:dima/utils/palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CommunityMembersList extends StatelessWidget {
  final List<User> members;

  const CommunityMembersList({
    Key? key,
    required this.members,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: Size(360, 690), minTextAdapt: true);
    return _listViewMembers(context, members);
  }
}

Widget _listViewMembers(BuildContext context, List<User> members) {
  return Container(
    height: 100.sp, // Adjust as needed
    child: ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: members.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            // Do not show current user
            if (members[index].id != Globals.instance.userUid.toString()) {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ProfilePage(
                          userId: members[index].id,
                        )),
              );
            }
          },
          child: Padding(
            padding:  EdgeInsets.symmetric(horizontal: 6.sp),
            child: Column(
              children: [
                ClipOval(
                  child: SizedBox(
                    width: 50.sp,
                    height: 50.sp,
                    child: (members[index].profileImagePath).startsWith('assets')
                        ? Image.asset(
                            members[index].profileImagePath,
                            fit: BoxFit.cover,
                          )
                        : Image.network(
                            members[index].profileImagePath,
                            fit: BoxFit.cover,
                            loadingBuilder: (BuildContext
                                    context,
                                Widget child,
                                ImageChunkEvent?
                                    loadingProgress) {
                              if (loadingProgress ==
                                  null) {
                                return child;
                              }
                              return Center(
                                child:
                                    CircularProgressIndicator(
                                  value: loadingProgress
                                              .expectedTotalBytes !=
                                          null
                                      ? loadingProgress
                                              .cumulativeBytesLoaded /
                                          (loadingProgress
                                                  .expectedTotalBytes ??
                                              1)
                                      : null,
                                  valueColor:
                                      AlwaysStoppedAnimation<
                                              Color>(
                                          Palette.grey),
                                ),
                              );
                            },
                            errorBuilder:
                                (BuildContext context,
                                    Object error,
                                    StackTrace?
                                        stackTrace) {
                              return Icon(Icons.error,
                                  size: 25.sp);
                            },
                          ),
                  ),
                ),
                SizedBox(height: 8.sp),
                Text(
                  members[index].username,
                  style: TextStyle(fontSize: 14.sp),
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}
