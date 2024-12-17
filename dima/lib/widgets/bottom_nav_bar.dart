import 'package:dima/utils/palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({
    Key? key,
    required this.index,
    required this.onItemSelected,
  }) : super(key: key);

  final int index;
  final void Function(int) onItemSelected;

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: Size(360, 690), minTextAdapt: true);
    return Column(
      mainAxisSize: MainAxisSize
          .min,
      children: [
        Container(
          height: 0,
          color: Palette.grey, 
        ),
        BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Palette.offWhite,
          currentIndex: index,
          onTap: onItemSelected,
          selectedItemColor: Palette.red,
          selectedLabelStyle:  TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12.sp,
          ),
          selectedIconTheme:  IconThemeData(size: 28.sp),
          showUnselectedLabels: false,
          unselectedItemColor: Palette.grey,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.article_outlined),
              label: 'News',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.map_outlined),
              label: 'Mappa',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search_outlined),
              label: 'Discovery',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.groups),
              label: 'Community',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.face),
              label: 'Profilo',
            ),
          ],
        ),
      ],
    );
  }
}
