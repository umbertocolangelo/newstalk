import 'package:flutter/material.dart';
import 'package:flutter_swiper_null_safety/flutter_swiper_null_safety.dart';
import '../../model/article.dart';
import '../../utils/placeholder_flipCard.dart';
import '../articleCard/articleDiscoveryCard.dart';

class ThreadScrollArticleCards extends StatelessWidget {
  final double height;
  final List<Article> threadArticles;
  const ThreadScrollArticleCards(
      {super.key, required this.height, required this.threadArticles});

  @override
  Widget build(BuildContext context) {
    return Swiper(
        itemBuilder: (context, index) {
          if (threadArticles.isEmpty) {
            return buildArticlePlaceholder(context);
          } else {
            Article article = threadArticles[index];
            return ArticleCardDiscovery(article: article, height: height
                // width: constraints.maxWidth*0.55,
                );
          }
        },
        itemHeight: height,
        viewportFraction: 0.5,
        scale: 0.9,
        loop: false,
        itemCount: threadArticles.isEmpty ? 6 : threadArticles.length);
  }
}
