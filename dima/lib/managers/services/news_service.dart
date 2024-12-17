import 'package:cloud_firestore/cloud_firestore.dart';
import '../../model/article.dart';

Future<void> writeArticlesToFirestore(List<Article> articles) async {
  final CollectionReference articlesRef =
      FirebaseFirestore.instance.collection('articles');

  for (Article article in articles) {
    try {
      await articlesRef.add({
        'source': article.source,
        'author': article.author,
        'title': article.title,
        'description': article.description,
        'url': article.url,
        'urlToImage': article.urlToImage,
        'publishedAt': article.publishedAt,
        // 'content': article.content,
        'language': article.language,
        'country': article.country,
        'category': article.category,
        'apiSource': article.apiSource,
      });
    } catch (e) {
      print('Error writing article to Firestore: $e');
    }
  }
}

Future<void> removeAllArticles() async {
  try {
    // Get a reference to the collection
    CollectionReference collection =
        FirebaseFirestore.instance.collection("articles");

    // Get all documents in the collection
    QuerySnapshot snapshot = await collection.get();

    // Iterate through all documents and delete them one by one
    for (QueryDocumentSnapshot doc in snapshot.docs) {
      await doc.reference.delete();
    }

    print('Items successfully removed from collection artciles');
  } catch (e) {
    print('An error occurred while removing items: $e');
  }
}

Future<void> removeAllArticlesExceptCategory(String excludeCategory) async {
  try {
    // Get a reference to the collection
    CollectionReference collection =
        FirebaseFirestore.instance.collection("articles");

    // Use the .where() method to filter documents with a category not equal to the excluded one
    QuerySnapshot snapshot =
        await collection.where('category', isNotEqualTo: excludeCategory).get();

    // Iterate through the filtered documents and delete them one by one
    for (QueryDocumentSnapshot doc in snapshot.docs) {
      await doc.reference.delete();
    }

    print(
        'Items successfully removed from collection articles, except those in category: $excludeCategory');
  } catch (e) {
    print('An error occurred while removing items: $e');
  }
}
