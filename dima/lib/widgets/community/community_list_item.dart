import 'package:dima/model/user.dart';
import 'package:dima/utils/palette.dart';
import 'package:flutter/material.dart';
import 'package:dima/model/community.dart';
import 'package:dima/pages/community_homepage.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class CommunityListItem extends StatefulWidget {
  final Community community;
  final User? admin;

  const CommunityListItem({
    required this.community,
    required this.admin,
  });

  @override
  _CommunityListItemState createState() => _CommunityListItemState();
}

class _CommunityListItemState extends State<CommunityListItem> {
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('it_IT', null);
  }

  final List<Map<String, String>> _categories = [
    {'emoji': '🌐', 'name': 'Attualità'},
    {'emoji': '🏅', 'name': 'Sport'},
    {'emoji': '🎬', 'name': 'Intrattenimento'},
    {'emoji': '💪', 'name': 'Salute'},
    {'emoji': '💼', 'name': 'Economia'},
    {'emoji': '💻', 'name': 'Tecnologia'}
  ];

  String _getCategoryEmoji(String categoryName) {
    return _categories.firstWhere(
        (category) => category['name'] == categoryName,
        orElse: () => {'emoji': '❓'})['emoji']!;
  }

  String formatDateToItalian(DateTime dateTime) {
    final DateFormat dateFormat = DateFormat('d MMM y', 'it_IT');
    return dateFormat.format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: Size(360, 690), minTextAdapt: true);
    DateTime dateTime = widget.community.createdAt.toDate();
    String date = formatDateToItalian(dateTime);

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) =>
                CommunityHomePage(community: widget.community),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4.sp, horizontal: 8.sp),
        padding: EdgeInsets.all(16.sp),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(color: Palette.beige.withOpacity(0.8), width: 2.sp),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 30.sp,
                      backgroundColor: Palette.grey,
                      child: ClipOval(
                        child: Image.network(
                          widget.community.profileImagePath,
                          fit: BoxFit.cover,
                          width: 60.sp,
                          height: 60.sp,
                          loadingBuilder: (BuildContext context, Widget child,
                              ImageChunkEvent? loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              color: Palette.offWhite,
                              child: Center(
                                child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes !=
                                            null
                                        ? loadingProgress
                                                .cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Palette.grey,
                                    )),
                              ),
                            );
                          },
                          errorBuilder: (BuildContext context, Object exception,
                              StackTrace? stackTrace) {
                            return Container(
                              color: Palette.grey,
                              width: 60.sp,
                              height: 60.sp,
                              child: Center(child: Icon(Icons.error)),
                            );
                          },
                        ),
                      ),
                    ),
                    SizedBox(width: 16.sp),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.community.name,
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: Palette.black,
                            ),
                          ),
                          SizedBox(height: 8.sp),
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Admin: ',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: Colors.grey,
                                  ),
                                ),
                                TextSpan(
                                  text: widget.admin?.username ?? 'Anonimo',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: Palette.grey,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 8.sp),
                          Text(
                            date,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Palette.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        _isExpanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        size: 32.sp,
                        color: Palette.red,
                      ),
                      onPressed: () {
                        setState(() {
                          _isExpanded = !_isExpanded;
                        });
                      },
                    ),
                  ],
                ),
                if (_isExpanded) ...[
                  SizedBox(height: 16.sp),
                  Text(
                    widget.community.bio,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Palette.black,
                    ),
                  ),
                  SizedBox(height: 8.sp),
                  Text(
                    '${widget.community.memberIds.length} membri iscritti',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Palette.black,
                    ),
                  ),
                  SizedBox(height: 8.sp),
                  Text(
                    '${widget.community.threadIds.length} thread creati',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Palette.black,
                    ),
                  ),
                  SizedBox(height: 8.sp),
                  Wrap(
                    spacing: 8.sp,
                    children: widget.community.categories
                        .map((category) => Chip(
                              label: Text(
                                  '${_getCategoryEmoji(category)} $category'),
                              backgroundColor: Palette.beige,
                              labelStyle: TextStyle(
                                color: Palette.black,
                                fontSize: 16.sp,
                              ),
                            ))
                        .toList(),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}
