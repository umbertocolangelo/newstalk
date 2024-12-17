import 'package:dima/widgets/thread/limited_thread_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CommunityLimitedThreadList extends StatelessWidget {
  final int size;

  CommunityLimitedThreadList({Key? key, required this.size});

  @override
  Widget build(BuildContext context) {
      ScreenUtil.init(context, designSize: Size(360, 690), minTextAdapt: true);
    return Container(
      height: 150.sp, // Adjust as needed
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: size > 5 ? 5 : size,
        itemBuilder: (context, index) {
          return Padding(
            padding:  EdgeInsets.symmetric(horizontal: 6.sp),
            child: LimitedThreadCard(),
          );
        },
      ),
    );
  }
}
