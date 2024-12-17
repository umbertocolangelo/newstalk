import 'package:dima/model/article.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

// Mock content paragraphs for testing
List<ContentParagraph> mockContentParagraphs = [
  ContentParagraph(
    paragraphTitle: 'Introduction',
    paragraphContent: 'This is the introduction of the article.',
  ),
  ContentParagraph(
    paragraphTitle: 'Main Content',
    paragraphContent: 'This section contains the main content of the article.',
  ),
  ContentParagraph(
    paragraphTitle: 'Conclusion',
    paragraphContent: 'This is the conclusion of the article.',
  ),
];

// Mock article instance
Article mockArticle = Article(
  source: 'Mock Source',
  author: 'Mock Author',
  title: 'Mock Article Title',
  description: 'This is a mock description for the article.',
  url: 'https://www.ansa.it/sito/notizie/mondo/2024/08/28/medio-oriente-israele-approva-tregue-temporanee-per-i-vaccini.-vasta-operazione_096d0594-7669-4190-b4ce-e14b0ad71b57.html',
  urlToImage: 'https://www.ansa.it/webimages/news_base/2024/8/28/d7bba70dcd42a494ddec1965a4a43789.jpg',
  publishedAt: '2024-08-28T12:34:56Z',
  contentParagraphs: mockContentParagraphs,
  language: 'en',
  country: 'US',
  category: 'tecnologia',
  apiSource: 'Mock API Source',
  urlToAuthor: 'https://www.ansa.it/webimages/news_base/2024/8/28/d7bba70dcd42a494ddec1965a4a43789.jpg',
  coordinates: LatLng(37.7749, -122.4194),
  articleId: 'mock-article-001',
);

// Mock list of articles for testing
List<Article> mockArticleList = [
  Article(
    source: 'Mock Source 1',
    author: 'Mock Author 1',
    title: 'Mock Article Title 1',
    description: 'This is the first mock description.',
    url: 'https://www.example.com/mock-article-1',
    urlToImage: 'https://www.example.com/mock-image-1.jpg',
    publishedAt: '2024-08-27T10:20:30Z',
    contentParagraphs: mockContentParagraphs,
    language: 'en',
    country: 'US',
    category: 'Science',
    apiSource: 'Mock API Source 1',
    urlToAuthor: 'https://www.example.com/mock-author-1',
    coordinates: LatLng(40.7128, -74.0060),
    articleId: 'mock-article-002',
  ),
  Article(
    source: 'Mock Source 2',
    author: 'Mock Author 2',
    title: 'Mock Article Title 2',
    description: 'This is the second mock description.',
    url: 'https://www.example.com/mock-article-2',
    urlToImage: 'https://www.example.com/mock-image-2.jpg',
    publishedAt: '2024-08-26T08:15:45Z',
    contentParagraphs: mockContentParagraphs,
    language: 'es',
    country: 'ES',
    category: 'Health',
    apiSource: 'Mock API Source 2',
    urlToAuthor: 'https://www.example.com/mock-author-2',
    coordinates: LatLng(41.3851, 2.1734),
    articleId: 'mock-article-003',
  ),
  Article(
    source: 'Mock Source 3',
    author: 'Mock Author 3',
    title: 'Mock Article Title 3',
    description: 'This is the third mock description.',
    url: 'https://www.example.com/mock-article-3',
    urlToImage: 'https://www.example.com/mock-image-3.jpg',
    publishedAt: '2024-08-25T07:12:30Z',
    contentParagraphs: mockContentParagraphs,
    language: 'fr',
    country: 'FR',
    category: 'Business',
    apiSource: 'Mock API Source 3',
    urlToAuthor: 'https://www.example.com/mock-author-3',
    coordinates: LatLng(48.8566, 2.3522),
    articleId: 'mock-article-004',
  ),
];

