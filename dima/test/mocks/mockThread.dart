import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima/model/thread.dart';

// Function to create a mock Thread object
Thread createMockThread({
  String? id,
  List<String>? articleIds,
  String? authorId,
  List<String>? participantIds,
  String? communityId,
  String? title,
  int? upvotes,
  int? downvotes,
  List<String>? commentIds,
  Timestamp? time,
}) {
  return Thread(
    id: id ?? 'mock_thread_id',
    articleIds: articleIds ?? ['mock_article_id_1', 'mock_article_id_2'],
    authorId: authorId ?? 'mock_author_id',
    participantIds: participantIds ?? ['mock_participant_id_1', 'mock_participant_id_2'],
    communityId: communityId ?? 'mock_community_id',
    title: title ?? 'Mock Thread Title',
    upvotes: upvotes ?? 10,
    downvotes: downvotes ?? 2,
    commentIds: commentIds ?? ['mock_comment_id_1', 'mock_comment_id_2'],
    time: time ?? Timestamp.now(),
  );
}
