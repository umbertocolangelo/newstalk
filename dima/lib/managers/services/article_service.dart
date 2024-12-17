import 'package:dima/model/article.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ArticleService {
  
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<Article>> getArticles() async {
    var result = await _db.collection('articles').get();
    List<Article> articles =
        result.docs.map((doc) => Article.fromMap(doc.data())).toList();
    return articles;
  }

  Future<void> deleteArticle(String articleId) async {
    var result = await _db
        .collection('articles')
        .where('articleId', isEqualTo: articleId)
        .get();
    result.docs.first.reference.delete();
  }

  //get article by id
  Future<Article> getArticleById(String articleId) async {
    var result = await _db
        .collection('articles')
        .where('articleId', isEqualTo: articleId)
        .get();
    Article article = Article.fromMap(result.docs.first.data());
    return article;
  }

  //get articles by category
  Future<List<Article>> getArticlesByCategory(String category) async {
    var result = await _db
        .collection('articles')
        .where('category', isEqualTo: category)
        .get();
    List<Article> articles =
        result.docs.map((doc) => Article.fromMap(doc.data())).toList();
    return articles;
  }

  //get articles by source
  Future<List<Article>> getArticlesBySource(String source) async {
    var result = await _db
        .collection('articles')
        .where('source', isEqualTo: source)
        .get();
    List<Article> articles =
        result.docs.map((doc) => Article.fromMap(doc.data())).toList();
    return articles;
  }

  //get articles by author
  Future<List<Article>> getArticlesByAuthor(String author) async {
    var result = await _db
        .collection('articles')
        .where('author', isEqualTo: author)
        .get();
    List<Article> articles =
        result.docs.map((doc) => Article.fromMap(doc.data())).toList();
    return articles;
  }

  //get articles by language
  Future<List<Article>> getArticlesByLanguage(String language) async {
    var result = await _db
        .collection('articles')
        .where('language', isEqualTo: language)
        .get();
    List<Article> articles =
        result.docs.map((doc) => Article.fromMap(doc.data())).toList();
    return articles;
  }

  //get articles by country
  Future<List<Article>> getArticlesByCountry(String country) async {
    var result = await _db
        .collection('articles')
        .where('country', isEqualTo: country)
        .get();
    List<Article> articles =
        result.docs.map((doc) => Article.fromMap(doc.data())).toList();
    return articles;
  }

  // Get articles by thread id
  Future<List<Article>> getArticlesByThreadId(String threadId) async {
    var threadResult = await _db.collection('threads').where('id', isEqualTo: threadId).get();
    List<dynamic> ids = threadResult.docs.first.data()['articleIds'];
    var result = await _db.collection('articles').where('articleId', whereIn: ids).get();
    List<Article> articles = result.docs.map((doc) => Article.fromMap(doc.data())).toList();
    var articleMap = {for (var article in articles) article.articleId: article};
    // Reorder articles 
    List<Article> orderedArticles = ids
        .map((id) => articleMap[id])
        .where((article) => article != null)
        .cast<Article>()
        .toList();
    return orderedArticles;
  }

}
