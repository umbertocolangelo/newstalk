import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String id;
  final String threadId;
  final String userId;
  final String content;
  final Timestamp time;

  Comment({
    required this.id,
    required this.threadId,
    required this.userId,
    required this.content,
    required this.time,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] ?? '',
      threadId: json['threadId'] ?? '',
      userId: json['userId'] ?? '',
      content: json['content'] ?? '',
      time: json['time'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'threadId': threadId,
      'userId': userId,
      'content': content,
      'time': time,
    };
  }
}
