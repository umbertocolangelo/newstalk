import 'package:dima/utils/palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../widgets/feedDiscoveryWidget.dart';
import '../widgets/searchBar/searchBarDiscoveryWidget.dart';

class DiscoveryPage extends StatelessWidget {
  const DiscoveryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: Size(360, 690), minTextAdapt: true);
    return Scaffold(
        appBar: AppBar(
          title:  Text('Discovery', 
            style: TextStyle(
              color: Palette.red,
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
            )),
        backgroundColor: Palette.offWhite,
        foregroundColor: Palette.black,
          centerTitle: true,
        ),
        body: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
          return Scaffold(
            backgroundColor: Palette.offWhite,
            body: Container(
              color: Palette.offWhite,
              child: Column(
                children: [
                  SizedBox(
                    height: constraints.maxHeight * 0.1,
                    child: const SearchBarDiscovery(),
                  ),
                  const Expanded(
                    child: FeedDiscoveryWidget(),
                  ),
                ],
              ),
            ),
          );
        }));
  }
}
