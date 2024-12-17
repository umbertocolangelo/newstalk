import 'package:dima/model/globals.dart';
import 'package:dima/pages/create_thread_page.dart';
import 'package:dima/utils/palette.dart';
import 'package:dima/utils/popup_login_prompt.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../model/article.dart';
import '../utils/custom_tag.dart';
import '../utils/image_container.dart';

class ArticleScreen extends StatelessWidget {
  final Article article;
  const ArticleScreen({super.key, required this.article});

  static const routeName = '/article';
  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: Size(360, 690), minTextAdapt: true);
    return ImageContainer(
      width: double.infinity,
      imageUrl: article.urlToImage,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          iconTheme: const IconThemeData(color: Palette.offWhite),
          elevation: 10,
          forceMaterialTransparency: true,
        ),
        extendBodyBehindAppBar: true,
        body: ListView(
          children: [
            _NewsHeadline(article: article),
            _NewsBody(article: article)
          ],
        ),
      ),
    );
  }
}

class _NewsBody extends StatelessWidget {
  const _NewsBody({
    Key? key,
    required this.article,
  }) : super(key: key);

  final Article article;

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: Size(360, 690), minTextAdapt: true);
    String author;
    if (article.author.length > 25) {
      author = article.author.substring(0, article.author.length - 3) + '...';
    } else {
      author =
          article.author.isNotEmpty ? article.author : "Autore Sconosciuto";
    }
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      return Container(
        padding: EdgeInsets.all(20.sp),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.sp),
            topRight: Radius.circular(20.sp),
          ),
          color: Palette.offWhite,
        ),
        child: Column(
          //crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Author
                CustomTag(
                  backgroundColor: Palette.beige,
                  borderColor: Palette.black,
                  children: [
                    CircleAvatar(
                  radius: 15.sp,
                  backgroundColor: Palette.black,
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(article.urlToAuthor),
                    onBackgroundImageError: (exception, stackTrace) {
                      Text("Errore");
                    },
                    foregroundColor: Colors.transparent,
                    child: Text("Errore"),
                  ),
                ),
                    SizedBox(width: 10.sp),
                    Text(
                      article.author.isNotEmpty ? author : "Autore Sconosciuto",
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            color: Palette.black,
                            fontSize: 16.sp
                          ),
                    ),
                  ],
                ),

                Spacer(),

                Container(
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      // Create thread
                      CustomTag(
                          backgroundColor: Palette.beige,
                          borderColor: Palette.black,
                          children: [
                            GestureDetector(
                              onTap: () {
                                _createThread(context);
                              },
                              child: Icon(FontAwesomeIcons.commentDots,
                                  color: Color.fromRGBO(8, 9, 11, 1),
                                  size: 15.sp),
                            )
                          ]),

                      SizedBox(width: 5.sp),

                      // Copy link
                      CustomTag(
                          backgroundColor: Palette.beige,
                          borderColor: Palette.black,
                          children: [
                            GestureDetector(
                              onTap: () {
                                Clipboard.setData(ClipboardData(
                                    text: "%%" + article.articleId + "%%"));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content:
                                        Text('Articolo copiato sugli appunti!'),
                                  ),
                                );
                              },
                              child: Icon(FontAwesomeIcons.shareNodes,
                                  color: Palette.black, size: 15.sp),
                            )
                          ]),

                      SizedBox(width: 5.sp),

                      // Go to article page
                      CustomTag(
                          backgroundColor: Palette.beige,
                          borderColor: Palette.black,
                          children: [
                            GestureDetector(
                              onTap: () {
                                launchURL(article.url);
                              },
                              child: Icon(FontAwesomeIcons.globe,
                                  size: 15.sp, color: Palette.black),
                            )
                          ]),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.sp),
            if (article.contentParagraphs != null &&
                article.contentParagraphs!.isNotEmpty)
              ...article.contentParagraphs!.map((p) => Padding(
                    padding: EdgeInsets.only(bottom: 10.sp),
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text:
                                '${p.paragraphTitle}\n', // Title with a newline
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.sp
                                ),
                          ),
                          TextSpan(
                            text: p.paragraphContent, // Content
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                  fontWeight: FontWeight.normal,
                            fontSize: 16.sp
                                ),
                          ),
                        ],
                      ),
                    ),
                  )),
          ],
        ),
      );
    });
  }

  void _createThread(BuildContext context) {
    if (Globals.instance.userUid != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CreateThreadPage(articleId: article.articleId),
        ),
      );
    } else {
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) => popupLoginPrompt(),
      );
    }
  }
}

class _NewsHeadline extends StatelessWidget {
  const _NewsHeadline({
    Key? key,
    required this.article,
  }) : super(key: key);

  final Article article;

  @override
  Widget build(BuildContext context) {
    const Map<String, String> CATEGORIES = {
      'attualità': 'Attualità',
      'sport': 'Sport',
      'intrattenimento': 'Intrattenimento',
      'salute': 'Salute',
      'economia': 'Business',
      'tecnologia': 'Tecnologia',
    };

    final List<Map<String, String>> _categories = [
      {'emoji': '🌐', 'name': 'Attualità'},
      {'emoji': '🏅', 'name': 'Sport'},
      {'emoji': '🎬', 'name': 'Intrattenimento'},
      {'emoji': '💪', 'name': 'Salute'},
      {'emoji': '💼', 'name': 'Business'},
      {'emoji': '💻', 'name': 'Tecnologia'}
    ];

    String getCategoryEmoji(String categoryName) {
      return _categories.firstWhere(
          (category) => category['name'] == categoryName,
          orElse: () => {'emoji': '❓'})['emoji']!;
    }

    return Stack(
      children: [
        // Gradiente sfocato nero
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.center,
                end: Alignment.topCenter,
                colors: [
                  Palette.grey.withOpacity(0.4),
                  Colors.transparent,
                ],
                stops: const [0.1, 0.9],
              ),
            ),
          ),
        ),

        // Contenuto della pagina (Testo e altro)
        Padding(
          padding: EdgeInsets.all(20.sp),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.15,
              ),
              CustomTag(
                  backgroundColor: Colors.transparent,
                  borderColor: Palette.offWhite,
                  children: [
                    Text(
                      '${getCategoryEmoji(CATEGORIES[article.category]!)} ${CATEGORIES[article.category]}',
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            color: Palette.offWhite,
                            fontWeight: FontWeight.bold,
                            fontSize: 18.sp
                          ),
                    ),
                  ]),
              SizedBox(height: 10.sp),
              Text(
                article.title,
                style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Palette.offWhite,
                      fontSize: 20.sp,
                     
                    ),
              ),
              SizedBox(height: 10.sp),
              Text(
                article.description,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium!
                    .copyWith(fontSize: 18.sp, color: Palette.offWhite),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

void launchURL(String url) async {
  final websiteUri = Uri.parse(url);
  await launchUrl(websiteUri, mode: LaunchMode.platformDefault);
}
