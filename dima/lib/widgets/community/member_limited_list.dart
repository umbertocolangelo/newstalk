import 'package:dima/utils/palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CommunityLimitedMemberList extends StatelessWidget {
  final int size;
  double? height;

  CommunityLimitedMemberList({Key? key, required this.size, this.height});

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: Size(360, 690), minTextAdapt: true);
    return Container(
      height: height, // Adjust as needed
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: size > 5 ? 5 : size,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 6.sp),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 3.sp),
              child: Column(
                children: [
                  CircleAvatar(
                    backgroundColor: Palette.grey.withOpacity(0.3),
                    radius: 30.sp,
                    child: Icon(
                      FontAwesomeIcons.lock,
                      size: 25.sp,
                      color: Palette.black,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
