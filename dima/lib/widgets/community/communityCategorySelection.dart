import 'package:dima/utils/palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../pages/create_community_page.dart';
import '../newsFeed/newsFeedSelectionCategory.dart';

class CommunityDiscoveryHeader extends StatelessWidget {
  final bool isListView;
  final VoidCallback onListViewSelected;
  final VoidCallback onSwiperViewSelected;

  const CommunityDiscoveryHeader({
    required this.isListView,
    required this.onListViewSelected,
    required this.onSwiperViewSelected,
  });

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: Size(360, 690), minTextAdapt: true);
    return Container(
        color: Palette.offWhite,
        child: Padding(
          padding:  EdgeInsets.all(16.sp),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: Icon(Icons.view_list, size: 25.sp,),
                    color: isListView ? Palette.red : Palette.grey,
                    onPressed: onListViewSelected,
                  ),
                  SizedBox(width: 10.sp),
                  IconButton(
                    icon: Icon(Icons.view_carousel, size: 25.sp,),
                    color: !isListView ? Palette.red : Palette.grey,
                    onPressed: onSwiperViewSelected,
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CreateCommunityPage(),
                    ),
                  );
                },
                icon: Icon(Icons.add, color: Palette.black, size: 28.sp),
                label:
                    Text('Nuova community', style: TextStyle(fontSize: 16.sp)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Palette.beige,
                  foregroundColor: Palette.black,
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.sp, vertical: 10.sp),
                  side: BorderSide(
                    color: Palette.black,
                    width: 1,
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}

class CommunityCategorySelection extends StatelessWidget {
  final String selectedCategory;
  final Function(String) onCategorySelected;
  final Set<String> userSelectedCategories;

  const CommunityCategorySelection({
    required this.selectedCategory,
    required this.onCategorySelected,
    required this.userSelectedCategories,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.08,
      child: CategorySelectionWidget(
        selectedCategory: selectedCategory,
        onCategorySelected: onCategorySelected,
        heightNewsFeed: MediaQuery.of(context).size.height,
        userSelectedCategories: userSelectedCategories,
      ),
    );
  }
}
