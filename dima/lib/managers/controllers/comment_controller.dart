import 'package:dima/model/comment.dart';
import 'package:dima/managers/services/comment_service.dart';
import 'package:flutter/cupertino.dart';

class CommentController with ChangeNotifier {
  final CommentService _commentService = CommentService();
  List<Comment> comments = [];

  Future<List<Comment>> fetchComments() async {
    try {
      comments = await _commentService.getComments();
      return comments;
    } catch (error) {
      // Handle errors, e.g., show an error message to the Comment
      print('Error fetching Comments: $error');
      rethrow;
    }
  }

  Future<void> addComment(Map<String, dynamic> commentData) async {
    try {
      await _commentService.addComment(commentData);
    } catch (error) {
      // Handle errors, e.g., show an error message to the Comment
      print('Error adding Comment: $error');
    }
  }

  Future<void> updateComment(
      String commentId, Map<String, dynamic> newData) async {
    try {
      await _commentService.updateComment(commentId, newData);
    } catch (error) {
      // Handle errors, e.g., show an error message to the Comment
      print('Error updating Comment: $error');
    }
  }

  Future<void> deleteComment(String commentId) async {
    try {
      await _commentService.deleteComment(commentId);
    } catch (error) {
      // Handle errors, e.g., show an error message to the Comment
      print('Error deleting Comment: $error');
    }
  }

  Future<Comment> getCommentById(String commentId) async {
    try {
      return await _commentService.getCommentById(commentId);
    } catch (error) {
      // Handle errors, e.g., show an error message to the Comment
      print('Error getting Comment: $error');
      rethrow;
    }
  }

  Future<List<Comment>> getCommentsByThreadId(String threadId) async {
    try {
      return await _commentService.getCommentsByThreadId(threadId);
    } catch (error) {
      // Handle errors, e.g., show an error message to the Comment
      print('Error getting Comments: $error');
      rethrow;
    }
  }

  Future<List<Comment>> getCommentsByUserId(String userId) async {
    try {
      return await _commentService.getCommentsByUserId(userId);
    } catch (error) {
      // Handle errors, e.g., show an error message to the Comment
      print('Error getting Comments: $error');
      rethrow;
    }
  }
}
