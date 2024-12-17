import 'package:dima/pages/searching_page.dart';
import 'package:dima/utils/palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SearchBarDiscovery extends StatelessWidget {
  const SearchBarDiscovery({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:  EdgeInsets.all(8.sp),
      child: GestureDetector(
        onTap: () {
          // Navigate to the search page on tap
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => const SearchingPage()));
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Palette.grey,
              width: 2,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child:  Row(
            children: [
              Icon(Icons.search, color: Palette.red),
              SizedBox(width: 10.sp),
              Text('Cerca...', style: TextStyle(color: Palette.black.withOpacity(0.8))),
            ],
          ),
        ),
      ),
    );
  }
}
