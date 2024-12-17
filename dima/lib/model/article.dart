import 'package:google_maps_flutter/google_maps_flutter.dart';

class Article {
  //final String id;
  final String source;
  final String author;
  final String title;
  final String description;
  final String url;
  final String urlToImage;
  final String publishedAt;
  final List<ContentParagraph>? contentParagraphs;
  final String language;
  final String country;
  final String category;
  final String apiSource;
  final String urlToAuthor;
  final LatLng coordinates;
  final String articleId;

  Article(
      {this.source = "",
      this.author = "",
      this.title = "",
      this.description = "",
      this.url = "",
      this.urlToImage = "",
      this.publishedAt = "",
      this.contentParagraphs,
      this.language = "",
      this.country = "",
      this.category = "",
      this.apiSource = "",
      this.urlToAuthor = "",
      this.coordinates = const LatLng(0, 0),
      this.articleId = ""});

  factory Article.fromMap(Map<String, dynamic> map) {
    var coords = map['coordinates']?.split(',') ?? ['0', '0'];
    LatLng coordinates =
        LatLng(double.parse(coords[0]), double.parse(coords[1]));

    List<ContentParagraph>? contentParagraphs;
    var content = map['content'];
    contentParagraphs = content
        .map<ContentParagraph>((item) => ContentParagraph.fromMap(item))
        .toList();
    map['content'] = "";

    return Article(
        source: map['source'] ?? "",
        author: map['author'] ?? "",
        title: map['title'] ?? "",
        description: map['description'] ?? "",
        url: map['url'] ?? "",
        urlToImage: map['urlToImage'] ?? "",
        publishedAt: map['publishedAt'] ?? "",
        contentParagraphs: contentParagraphs,
        language: map['language'] ?? "",
        country: map['country'] ?? "",
        category: map['category'] ?? "",
        apiSource: map['apiSource'] ?? "",
        urlToAuthor: map['urlToAuthor'] ?? map['urlToImage'] ?? "",
        coordinates: coordinates,
        articleId: map['articleId']);
  }
}

class ContentParagraph {
  final String paragraphTitle;
  final String paragraphContent;

  ContentParagraph({
    required this.paragraphTitle,
    required this.paragraphContent,
  });

  factory ContentParagraph.fromMap(Map<String, dynamic> map) {
    return ContentParagraph(
      paragraphTitle: map['paragraphTitle'] ?? "",
      paragraphContent: map['paragraphContent'] ?? "",
    );
  }
}
