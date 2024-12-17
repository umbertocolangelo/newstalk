import 'package:dima/utils/palette.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../model/article.dart';
import '../../pages/article_page.dart';

class ArticleCardHome extends StatefulWidget {
  final Article article;
  final double? height;
  final double? width;

  const ArticleCardHome({
    Key? key,
    required this.article,
    this.height,
    this.width,
  }) : super(key: key);

  @override
  _ArticleCardHomeState createState() => _ArticleCardHomeState();
}

class _ArticleCardHomeState extends State<ArticleCardHome> {
  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: Size(360, 690), minTextAdapt: true);
    final article = widget.article;
    return Stack(children: [
      Card(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Container(
            height: widget.height,
            color: Palette.offWhite,
            child: Column(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ArticleScreen(article: article),
                        ),
                      );
                    },
                    child: Stack(
                      children: [
                        Image.network(
                          article.urlToImage,
                          fit: BoxFit.cover,
                          alignment: Alignment.center,
                          width: double.infinity,
                          height: double.infinity,
                          loadingBuilder: (BuildContext context, Widget child,
                              ImageChunkEvent? loadingProgress) {
                            if (loadingProgress == null)
                              return child; // Image has loaded
                            return Container(
                              color: Palette.offWhite,
                              child: const Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Palette.grey),
                                ),
                              ),
                            );
                          },
                          errorBuilder: (BuildContext context, Object exception,
                              StackTrace? stackTrace) {
                            return Container(
                              color: Palette.grey, // Gray background on error
                              child: Center(
                                child: Icon(Icons.error),
                              ),
                            );
                          },
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.center,
                              colors: [
                                Palette.grey.withOpacity(0.4),
                                Colors.transparent,
                              ],
                              stops: [0.1, 0.9],
                            ),
                          ),
                        ),
                        // Text container for title
                        Center(
                          child: Container(
                            height: widget.height! * 0.75,
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: Container(
                                padding: EdgeInsets.all(10.sp),
                                child: Text(
                                  article.title,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Palette.offWhite,
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines:
                                      4, // Allows text to expand up to three lines
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 15.sp,
                          right: 15.sp,
                          child: Container(
                            padding: EdgeInsets.all(
                                2.sp), // Space between the CircleAvatar and its border, adjust as needed
                            decoration: BoxDecoration(
                              color: Palette.offWhite,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Palette.beige,
                                width: 2.sp, // Thickness of the border
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 30.sp,
                              backgroundImage: NetworkImage(
                                article.urlToAuthor,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (article.contentParagraphs != null &&
                    article.contentParagraphs!.isNotEmpty)
                  Container(
                    padding: EdgeInsets.all(5.sp),
                    height: widget.height! * 0.35,
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(5.sp, 1.sp, 5.sp, 1.sp),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              article.description,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Palette.black,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines:
                                  3, // Allows text to expand up to three lines
                              overflow: TextOverflow
                                  .ellipsis, // Adds '...' if text exceeds the space available in three lines
                            ),
                            SizedBox(height: 8.sp),
                            RichText(
                              text: TextSpan(
                                style: TextStyle(
                                    color: Palette.black, fontSize: 16.sp),
                                children: [
                                  TextSpan(
                                      text: article.contentParagraphs!.first
                                          .paragraphContent),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    ]);
  }
}
