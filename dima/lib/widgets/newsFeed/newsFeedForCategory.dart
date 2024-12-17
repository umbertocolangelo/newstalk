import 'package:flutter/material.dart';
import 'package:flutter_swiper_null_safety/flutter_swiper_null_safety.dart';
import 'package:provider/provider.dart';
import '../../managers/controllers/article_controller.dart';
import '../../model/article.dart';
import '../../utils/placeholder_flipCard.dart'; // Assuming this is your placeholder widget
import '../articleCard/articleHomeCard.dart';

class NewsFeedForCategory extends StatefulWidget {
  final ScrollController controller;
  final String category;
  final Set<String> sources;
  final Map<String, int> swiperIndex;

  const NewsFeedForCategory({
    super.key,
    required this.controller,
    required this.category,
    required this.swiperIndex,
    required this.sources,
  });

  @override
  NewsForCategoryState createState() => NewsForCategoryState();
}

class NewsForCategoryState extends State<NewsFeedForCategory> {
  final Map<String, List<Article>> _categoryArticles =
      {}; // Dizionario per gli articoli per categoria
  bool _isFetchingInitialData = false;
  bool _isLoadingMore = false;
  bool _isInitialized = false;
  final SwiperController swiperController = SwiperController();

  @override
  void initState() {
    super.initState();
    _fetchInitialArticles();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(NewsFeedForCategory oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.sources != widget.sources) {
      _isInitialized = false;
      _categoryArticles[widget.category] = [];
      _fetchInitialArticles();
    } else {
      final articles = _categoryArticles[widget.category] ?? [];
      if (articles.isEmpty) {
        _fetchInitialArticles();
      } else {
        swiperController.move(widget.swiperIndex[widget.category] ?? 0,
            animation: false);
      }
    }
  }

  Future<void> _fetchInitialArticles() async {
    setState(() {
      _isFetchingInitialData = true;
      _isInitialized = false;
    });
    await Provider.of<ArticleController>(context, listen: false)
        .fetchArticlesForCategoryFilteredBySources(
            widget.category, widget.sources);
    if (mounted) {
      setState(() {
        _categoryArticles[widget.category] =
            Provider.of<ArticleController>(context, listen: false)
                .getArticlesForCategory(widget.category);
        _isFetchingInitialData = false;
        _isInitialized = true;
      });
    }
  }

  Future<void> _loadMoreArticles() async {
    if (!_isLoadingMore) {
      setState(() => _isLoadingMore = true);
      await Provider.of<ArticleController>(context, listen: false)
          .loadMoreArticlesFilteredBySources(widget.category, widget.sources);
      if (mounted) {
        setState(() {
          _categoryArticles[widget.category] =
              Provider.of<ArticleController>(context, listen: false)
                  .getArticlesForCategory(widget.category);
          _isLoadingMore = false;
        });
      }
    }
  }

  void refreshNewsFeed() async {
    if (_categoryArticles[widget.category]?.isNotEmpty ?? false) {
      swiperController.move(
        _categoryArticles[widget.category]!.length - 2,
        animation: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    final articles = _categoryArticles[widget.category] ?? [];
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        int itemCount = _isFetchingInitialData ? 5 : articles.length + 1;
        return Center(
          child: SizedBox(
            height: constraints.maxHeight,
            child: Swiper(
              controller: swiperController,
              itemCount: itemCount,
              onIndexChanged: (int index) {
                if (index == articles.length &&
                    !_isLoadingMore &&
                    articles.isNotEmpty) {
                  _loadMoreArticles();
                }
                widget.swiperIndex[widget.category] = index;
              },
              itemBuilder: (context, index) {
                if (_isFetchingInitialData) {
                  return buildArticlePlaceholder(context);
                } else if (index >= articles.length) {
                  return buildArticlePlaceholder(context);
                } else {
                  return ArticleCardHome(
                    article: articles[index],
                    height: constraints.maxHeight,
                    width: constraints.maxWidth * 0.8,
                  );
                }
              },
              itemWidth: constraints.maxWidth * 0.9,
              itemHeight: constraints.maxHeight,
              viewportFraction: 0.85,
              scale: 0.8,
              loop: false,
              duration: 1000,
              curve: Curves.easeInOut,
            ),
          ),
        );
      },
    );
  }
}
