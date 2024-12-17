import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomTag extends StatelessWidget {
  const CustomTag({
    Key? key,
    required this.backgroundColor,
    required this.children,
    required this.borderColor,
  }) : super(key: key);

  final Color backgroundColor;
  final Color borderColor;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
      ScreenUtil.init(context, designSize: Size(360, 690), minTextAdapt: true);
    return Container(
      padding:  EdgeInsets.all(10.sp),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20.sp),
        border: Border.all(
          color: borderColor, // Color of the border
          width: 1.0, // Thickness of the border
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }
}
