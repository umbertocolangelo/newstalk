import 'package:dima/utils/palette.dart';
import 'package:dima/utils/utilsFunctionsMapPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../model/article.dart';
import '../../pages/article_page.dart';

class ArticleCardDiscovery extends StatelessWidget {
  final Article article;
  final double? height;
  final double? width;

  const ArticleCardDiscovery({
    Key? key,
    required this.article,
    this.height,
    this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: Size(360, 690), minTextAdapt: true);
    return InkWell(
      onTap: () => showCustomDialogWithArticleInfo(article, context),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Container(
            height: height,
            color: Palette.offWhite,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.network(
                    article.urlToImage,
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                    loadingBuilder: (BuildContext context, Widget child,
                        ImageChunkEvent? loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: Palette.offWhite,
                        child: const Center(
                          child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Palette.grey),
                          ),
                        ),
                      );
                    },
                    errorBuilder: (BuildContext context, Object exception,
                        StackTrace? stackTrace) {
                      return Container(
                        color: Palette.grey,
                        child: Center(child: Icon(Icons.error)),
                      );
                    },
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
                Positioned(
                  top: 10.sp,
                  left: 10.sp,
                  child: CircleAvatar(
                    radius: 22.sp,
                    backgroundColor: Palette.offWhite,
                    child: IconButton(
                      icon: Icon(FontAwesomeIcons.newspaper,size: 22.sp,
                          color: Palette.black),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                ArticleScreen(article: article),
                            settings: RouteSettings(arguments: article),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Positioned(
                  top: 10.sp,
                  right: 10.sp,
                  child: Container(
                    padding: EdgeInsets.all(2.sp),
                    decoration: BoxDecoration(
                      color: Palette.offWhite,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Palette.beige,
                        width: 2.sp,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 20.sp,
                      backgroundImage: NetworkImage(
                        article.urlToAuthor,
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    padding: EdgeInsets.all(10.sp),
                    child: Text(
                      article.title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Palette.offWhite,
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold),
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
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
