import 'package:dima/utils/palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LimitedThreadCard extends StatelessWidget {
  final double? height;
  final double? width;

  const LimitedThreadCard({
    Key? key,
    this.height,
    this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
      ScreenUtil.init(context, designSize: Size(360, 690), minTextAdapt: true);
    return InkWell(
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Container(
            height: 150.sp,
            width: 120.sp,
            color: Palette.offWhite,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Container(
                    color: Palette.grey.withOpacity(0.3),
                    child: Center(
                      child: Icon(
                        FontAwesomeIcons.lock,
                        size: 50.sp,
                        color: Palette.black,
                      ),
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.center,
                      colors: [
                        Palette.grey.withOpacity(0.4),
                        Colors.transparent
                      ],
                      stops: [0.1, 0.9],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
