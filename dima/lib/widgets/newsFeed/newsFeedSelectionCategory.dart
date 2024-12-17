import 'package:dima/utils/palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CategorySelectionWidget extends StatelessWidget {
  final String selectedCategory;
  final Function(String) onCategorySelected;
  final double heightNewsFeed;
  final Set<String> userSelectedCategories;

  final List<Map<String, String>> allCategories = [
    {'emoji': '⭐', 'name': 'Tutto'},
    {'emoji': '🌐', 'name': 'Attualità'},
    {'emoji': '🏅', 'name': 'Sport'},
    {'emoji': '🎬', 'name': 'Intrattenimento'},
    {'emoji': '💪', 'name': 'Salute'},
    {'emoji': '💼', 'name': 'Economia'},
    {'emoji': '💻', 'name': 'Tecnologia'}
  ];

  CategorySelectionWidget({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
    required this.heightNewsFeed,
    required this.userSelectedCategories,
  });

  @override
  Widget build(BuildContext context) {
    List<Map<String, String>> categories = allCategories
        .where((category) => userSelectedCategories.contains(category['name']))
        .toList();

    return Container(
      color: Palette.offWhite,
      height: heightNewsFeed,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          Map<String, String> category = categories[index];
          bool isSelected =
              category['name']!.toLowerCase() == selectedCategory.toLowerCase();
          return GestureDetector(
            onTap: () => onCategorySelected(category['name']!),
            child: Container(
              alignment: Alignment.center,
              padding:  EdgeInsets.symmetric(horizontal: 20.sp),
              margin:  EdgeInsets.symmetric(vertical: 10.sp, horizontal: 5.sp),
              decoration: isSelected
                  ? BoxDecoration(
                      color: Palette.grey.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    )
                  : const BoxDecoration(),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${category['emoji']!} ${category['name']!}',
                    style: TextStyle(
                      color: isSelected ? Palette.red : Palette.grey,
                      fontSize: 16.sp,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
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
