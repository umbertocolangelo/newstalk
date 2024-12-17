import 'package:dima/utils/palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

Widget buildArticlePlaceholder(BuildContext context) {
    ScreenUtil.init(context, designSize: Size(360, 690), minTextAdapt: true);
  return Shimmer.fromColors(
    baseColor: Palette.grey.withOpacity(0.4),
    highlightColor: Palette.offWhite,
    child: Card(
      child: Column(
        children: [
          Container(
            color: Palette.offWhite,
          ),
          Padding(
            padding:  EdgeInsets.all(8.sp),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(
                  3,
                  (index) => Padding(
                        padding: const EdgeInsets.only(bottom: 5.0),
                        child: Container(
                          height: 10.sp,
                          width: double.infinity,
                          color: Palette.grey,
                        ),
                      )),
            ),
          ),
        ],
      ),
    ),
  );
}
