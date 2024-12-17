import 'package:cloud_firestore/cloud_firestore.dart';

class Thread {
  final String id;
  List<String> articleIds;
  String authorId; //creator of the thread
  List<String> participantIds; //users who have commented on the thread
  String communityId;
  String title;
  int upvotes;
  int downvotes;
  List<String> commentIds;
  Timestamp time;

  Thread({
    required this.id,
    required this.articleIds,
    required this.authorId,
    required this.participantIds,
    required this.communityId,
    required this.title,
    required this.upvotes,
    required this.downvotes,
    required this.commentIds,
    required this.time,
  });

  factory Thread.fromJson(Map<String, dynamic> json) {
    // Assicurati che ogni lista venga inizializzata correttamente se i dati sono null
    List<String> participantIds = [];
    if (json['participantIds'] != null) {
      var participants = json['participantIds'] as List;
      participantIds =
          participants.map((participant) => participant.toString()).toList();
    }

    List<String> commentIds = [];
    if (json['commentIds'] != null) {
      var comments = json['commentIds'] as List;
      commentIds = comments.map((comment) => comment.toString()).toList();
    }

    List<String> articleIds = [];
    if (json['articleIds'] != null) {
      var articles = json['articleIds'] as List;
      articleIds = articles.map((article) => article.toString()).toList();
    }

    return Thread(
      id: json['id'] ?? '', // Default to empty string if id is null
      articleIds: articleIds,
      authorId:
          json['authorId'] ?? '', // Default to empty string if authorId is null
      participantIds: participantIds,
      communityId: json['communityId'] ??
          '', // Default to empty string if communityId is null
      title: json['title'] ?? '', // Default to empty string if title is null
      upvotes: json['upvotes'] ?? 0, // Default to 0 if upvotes is null
      downvotes: json['downvotes'] ?? 0, // Default to 0 if downvotes is null
      commentIds: commentIds,
      time: json['time'] ??
          Timestamp.now(), // Default to current timestamp if time is null
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'articleIds': articleIds,
      'authorId': authorId,
      'participantIds': participantIds,
      'communityId': communityId,
      'title': title,
      'upvotes': upvotes,
      'downvotes': downvotes,
      'commentIds': commentIds,
      'time': time,
    };
  }
}
