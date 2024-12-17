import 'package:dima/managers/controllers/article_controller.dart';
import 'package:dima/model/article.dart';
import 'package:dima/model/globals.dart';
import 'package:dima/model/thread.dart';
import 'package:dima/pages/thread_chat_page.dart';
import 'package:dima/utils/palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class WidgetThreadCard extends StatelessWidget {
  final Thread thread;
  final double? height;
  final double? width;

  const WidgetThreadCard({
    required this.thread,
    this.height,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    ArticleController articleController = ArticleController();
    return FutureBuilder<List<Article>>(
      future: articleController.getArticlesByThreadId(thread.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingPlaceholder();
        } else if (snapshot.hasError) {
          return _buildErrorPlaceholder();
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyPlaceholder();
        } else {
          return InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ThreadChatPage(
                    threadId: thread.id,
                    currentUserId: Globals.instance.userUid!,
                  ),
                ),
              );
            },
            child: _buildThreadPreview(snapshot.data!, thread),
          );
        }
      },
    );
  }

  Widget _buildLoadingPlaceholder() {
    return Container(
      height: height,
      width: width,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          color: Palette.offWhite,
          child: const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Palette.grey),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorPlaceholder() {
    return Container(
      height: height,
      width: width,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(
            'Errore nel caricamento degli articoli',
            style: TextStyle(color: Colors.black),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyPlaceholder() {
    return Container(
      height: height,
      width: width,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(
            'Nessun articolo trovato',
            style: TextStyle(color: Palette.black),
          ),
        ),
      ),
    );
  }

  Widget _buildThreadPreview(List<Article> articles, Thread thread) {
    return Container(
      height: height,
      width: width,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // Background image
              Positioned.fill(
                child: Image.network(
                  articles.first.urlToImage,
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
              // Gradient overlay
              Positioned.fill(
                child: Container(
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
              ),
              // Forum icon
              Positioned(
                top: 10.sp,
                left: 10.sp,
                child: CircleAvatar(
                  radius: 20.sp,
                  backgroundColor: Palette.offWhite,
                  child: Icon(Icons.forum, color: Palette.black),
                ),
              ),
              // Thread title
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  child: Text(
                    thread.title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Palette.offWhite,
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
