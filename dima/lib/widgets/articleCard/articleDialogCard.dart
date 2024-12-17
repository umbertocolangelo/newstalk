import 'package:dima/utils/palette.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../model/article.dart';
import '../../pages/article_page.dart';
// Adjust this import based on your project structure

class ArticleCardDialog extends StatefulWidget {
  final Article article;
  final double? height;
  final double? width;

  const ArticleCardDialog({
    Key? key,
    required this.article,
    this.height,
    this.width,
  }) : super(key: key);

  @override
  ArticleCardDialogState createState() => ArticleCardDialogState();
}

class ArticleCardDialogState extends State<ArticleCardDialog> {
  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: Size(360, 690), minTextAdapt: true);
    final article = widget.article;
    return Stack(children: [
      Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                  height: widget.height,
                  color: Palette.offWhite,
                  child: Column(children: [
                    Expanded(
                        child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                ArticleScreen(article: article),
                          ),
                        );
                      },
                      child: Stack(children: [
                        Image.network(
                          article.urlToImage,
                          fit: BoxFit.cover,
                          alignment: Alignment.center,
                          width: double.infinity,
                          height: double.infinity,
                          loadingBuilder: (BuildContext context, Widget child,
                              ImageChunkEvent? loadingProgress) {
                            if (loadingProgress == null) {
                              return child; // Image has loaded
                            }
                            return Container(
                              color: Palette.grey,
                              child: Container(
                                color: Palette.offWhite,
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Palette.grey),
                                  ),
                                ),
                              ),
                            );
                          },
                          errorBuilder: (BuildContext context, Object exception,
                              StackTrace? stackTrace) {
                            return Container(
                              color: Palette.grey,
                              child: const Center(
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
                                Colors.transparent
                              ],
                              stops: [0.1, 0.9],
                            ),
                          ),
                        ),
                        // Text container for title
                        Positioned(
                          top: 15.sp,
                          right: 15.sp,
                          child: Container(
                            padding: EdgeInsets.all(2.sp),
                            decoration: BoxDecoration(
                              color: Palette
                                  .offWhite, // Background color behind the CircleAvatar
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Palette.black, // Color of the border
                                width: 2.sp,
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
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            height: widget.height! * 0.8,
                            child: SingleChildScrollView(
                              child: Container(
                                // Padding to ensure text is not at the very edge
                                child: Column(
                                  children: [
                                    SizedBox(
                                      height: widget.height! * 0.35,
                                    ),
                                    Padding(
                                      padding:
                                          EdgeInsets.only(right: 10.sp, left: 10.sp),
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
                                    SizedBox(height: 10.sp),
                                    Text(
                                      article.description,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Palette.offWhite,
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxLines:
                                          3, // Allows text to expand up to three lines
                                      overflow: TextOverflow
                                          .ellipsis, // Adds '...' if text exceeds the space available in three lines
                                    ),
                                    SizedBox(height: 8.sp),
                                    Container(
                                      decoration: const BoxDecoration(
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(20.0),
                                          topRight: Radius.circular(20.0),
                                        ),
                                        border: Border(
                                          top: BorderSide(
                                            color: Palette.black,
                                            width: 1.0,
                                          ),
                                          bottom: BorderSide(
                                            color: Palette.black,
                                            width: 1.0,
                                          ),
                                        ),
                                        color: Palette.offWhite,
                                      ),
                                      child: Padding(
                                        padding: EdgeInsets.all(10.sp),
                                        child: RichText(
                                          text: TextSpan(
                                              style: TextStyle(
                                                  color: Palette.black,
                                                  fontSize: 16.sp),
                                              children: [
                                                TextSpan(
                                                  text:
                                                      '${article.contentParagraphs!.first.paragraphTitle}\n', // Title with a newline
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium!
                                                      .copyWith(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                            fontSize: 16.sp
                                                      ),
                                                ),
                                                TextSpan(
                                                  text: article
                                                      .contentParagraphs!
                                                      .first
                                                      .paragraphContent, // Content
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium!
                                                      .copyWith(
                                                        fontWeight:
                                                            FontWeight.normal,
                                                            fontSize: 16.sp,
                                                       
                                                      ),
                                                ),
                                              ]),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ]),
                    ))
                  ]))))
    ]);
  }
}
