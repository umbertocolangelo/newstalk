import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../model/article.dart';

//class made to be a singleton, it stores the last document saw per each category
class ArticleRepository extends ChangeNotifier {

  //Article provider is a provider used specific ally b the news feed in order to handle all the transition done by the news feed
  //this include keeping a record of the documents seen 
  static final ArticleRepository _instance = ArticleRepository._internal();

  // Private constructor
  ArticleRepository._internal();

  // Map to hold the last document for each category
  Map<String, DocumentSnapshot> _lastDocuments = {};

  // Public factory
  factory ArticleRepository() {
    return _instance;
  }

  Future<List<Article>> fetchArticles(String category, int? batchSize) async {
    Query query = FirebaseFirestore.instance.collection('articles');

    // Apply category filter
    if (category != "Tutto") {
      query = query.where('category', isEqualTo: category.toLowerCase());
    }

    // Order by document ID for pagination
    query = query.orderBy(FieldPath.documentId);

    // Apply the batch size if provided
    if (batchSize != null) {
      query = query.limit(batchSize);
    }

    // Use the last document specific to the category for pagination
    DocumentSnapshot? lastDocument = _lastDocuments[category];
    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }

    QuerySnapshot querySnapshot = await query.get();
    List<Article> articles = querySnapshot.docs
        .map((doc) => Article.fromMap(doc.data() as Map<String, dynamic>))
        .toList();

    // Update the last document for the category
    if (querySnapshot.docs.isNotEmpty) {
      _lastDocuments[category] = querySnapshot.docs.last;
    }

    return articles;
  }

  Future<List<Article>> fetchArticlesFilteredBySources(
      String category, Set<String> sources, int? batchSize) async {
    Query query = FirebaseFirestore.instance.collection('articles');

    // Apply category filter
    if (category != "Tutto") {
      query = query.where('category', isEqualTo: category.toLowerCase());
    }

    // Apply sources filter
    if (sources.isNotEmpty) {
      query = query.where('source', whereIn: sources);
    }

    // Order by document ID for pagination
    query = query.orderBy(FieldPath.documentId);

    // Apply the batch size if provided
    if (batchSize != null) {
      query = query.limit(batchSize);
    }

    // Use the last document specific to the category for pagination
    DocumentSnapshot? lastDocument = _lastDocuments[category];
    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }

    QuerySnapshot querySnapshot = await query.get();
    List<Article> articles = querySnapshot.docs
        .map((doc) => Article.fromMap(doc.data() as Map<String, dynamic>))
        .toList();

    // Update the last document for the category
    if (querySnapshot.docs.isNotEmpty) {
      _lastDocuments[category] = querySnapshot.docs.last;
    }

    return articles;
  }

  void resetPagination({String? category}) {
    if (category != null) {
      _lastDocuments.remove(category);
    } else {
      _lastDocuments.clear();
    }
  }


Future<List<Article>> retrieveArticlesForCategory(String category) async {
  // Start with a base query
  Query query = FirebaseFirestore.instance
      .collection('articles')
      .where('category', isEqualTo: category.toLowerCase());
  QuerySnapshot querySnapshot = await query.get();

  List<Article> articles = querySnapshot.docs
      .map((doc) => Article.fromMap(doc.data() as Map<String, dynamic>))
      .toList();

  return articles;
}

Future<List<Article>> retrieveArticlesForArticleId(String articleId) async {
  // Start with a base query
  Query query = FirebaseFirestore.instance
      .collection('articles')
      .where('articleId', isEqualTo: articleId.toLowerCase());

  QuerySnapshot querySnapshot = await query.get();

  List<Article> articles = querySnapshot.docs
      .map((doc) => Article.fromMap(doc.data() as Map<String, dynamic>))
      .toList(); // Correcting the mapping to List<Article>

  return articles;
}

Future<List<List<Article>>> retrieveAllArticles() async {
  List<List<Article>> allCategoryArticles = [];
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('articles')
        .get();

    List<Article> articles = querySnapshot.docs
        .map((doc) => Article.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
    allCategoryArticles.add(articles);
  return allCategoryArticles;
}

Future<List<Article>> fetchArticlesInBatch(List<String> docIds) async {
  List<Article> articles = [];
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Process in chunks of 10 to adhere to Firestore's limitations
  const chunkSize = 10;
  for (var i = 0; i < docIds.length; i += chunkSize) {
    // Calculate the range for the current chunk
    int end = (i + chunkSize < docIds.length) ? i + chunkSize : docIds.length;
    List<String> chunk = docIds.sublist(i, end);

    // Perform a batched fetch from Firestore
    var snapshot = await firestore
        .collection('articles')
        .where(FieldPath.documentId, whereIn: chunk)
        .get();

    // Convert each document to an Article and add to the list
    for (var doc in snapshot.docs) {
      Article? article = Article.fromMap(doc.data() as Map<String, dynamic>);
      articles.add(article);
    }
  }

  return articles;
}
}
