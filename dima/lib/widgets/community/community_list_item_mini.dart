import 'package:dima/model/user.dart';
import 'package:dima/utils/palette.dart';
import 'package:flutter/material.dart';
import 'package:dima/model/community.dart';
import 'package:dima/pages/community_homepage.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CommunityListItemMini extends StatefulWidget {
  final Community community;
  final User? admin;

  const CommunityListItemMini({
    required this.community,
    required this.admin,
  });

  @override
  _CommunityListItemMiniState createState() => _CommunityListItemMiniState();
}

class _CommunityListItemMiniState extends State<CommunityListItemMini> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: Size(360, 690), minTextAdapt: true);
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) =>
                CommunityHomePage(community: widget.community),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4.sp, horizontal: 8.sp),
        padding: EdgeInsets.all(16.sp),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.0),
          border:
              Border.all(color: Palette.beige.withOpacity(0.8), width: 2.sp),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 30.sp,
                      backgroundColor: Palette.grey,
                      child: ClipOval(
                        child: Image.network(
                          widget.community.profileImagePath,
                          fit: BoxFit.cover,
                          width: 60.sp,
                          height: 60.sp,
                          loadingBuilder: (BuildContext context, Widget child,
                              ImageChunkEvent? loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              color: Palette.offWhite,
                              child: Center(
                                child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes !=
                                            null
                                        ? loadingProgress
                                                .cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Palette.grey,
                                    )),
                              ),
                            );
                          },
                          errorBuilder: (BuildContext context, Object exception,
                              StackTrace? stackTrace) {
                            return Container(
                              color: Palette.grey,
                              width: 60.sp,
                              height: 60.sp,
                              child: Center(child: Icon(Icons.error)),
                            );
                          },
                        ),
                      ),
                    ),
                    SizedBox(width: 16.sp),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.community.name,
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: Palette.black,
                            ),
                          ),
                          SizedBox(height: 8.sp),
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Admin: ',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: Colors.grey,
                                  ),
                                ),
                                TextSpan(
                                  text: widget.admin?.username ?? 'Anonimo',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: Palette.grey,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
