import 'package:dima/model/thread.dart';
import 'package:dima/managers/services/thread_service.dart';
import 'package:flutter/cupertino.dart';

class ThreadController with ChangeNotifier {
  final ThreadService _threadService = ThreadService();
  List<Thread> threads = [];

  Future<List<Thread>> fetchThreads() async {
    try {
      threads = await _threadService.getThreads();
      return threads;
    } catch (error) {
      // Handle errors, e.g., show an error message to the Thread
      print('Error fetching Threads: $error');
      rethrow;
    }
  }

  Future<void> addThread(Map<String, dynamic> threadData) async {
    try {
      await _threadService.addThread(threadData);
    } catch (error) {
      // Handle errors, e.g., show an error message to the Thread
      print('Error adding Thread: $error');
    }
  }

  Future<void> updateThread(
      String threadId, Map<String, dynamic> newData) async {
    try {
      await _threadService.updateThread(threadId, newData);
    } catch (error) {
      // Handle errors, e.g., show an error message to the Thread
      print('Error updating Thread: $error');
    }
  }

  Future<void> deleteThread(String threadId) async {
    try {
      await _threadService.deleteThread(threadId);
    } catch (error) {
      // Handle errors, e.g., show an error message to the Thread
      print('Error deleting Thread: $error');
    }
  }

  Future<Thread> getThreadById(String threadId) async {
    try {
      return await _threadService.getThreadById(threadId);
    } catch (error) {
      // Handle errors, e.g., show an error message to the Thread
      print('Error getting Thread: $error');
      rethrow;
    }
  }

  Future<List<Thread>> getThreadsByCommunityId(String communityId) async {
    try {
      return await _threadService.getThreadsByCommunityId(communityId);
    } catch (error) {
      // Handle errors, e.g., show an error message to the Thread
      print('Error getting Threads: $error');
      rethrow;
    }
  }

  Future<List<Thread>> getThreadsByAuthorId(String authorId) async {
    try {
      return await _threadService.getThreadsByAuthorId(authorId);
    } catch (error) {
      // Handle errors, e.g., show an error message to the Thread
      print('Error getting Threads: $error');
      rethrow;
    }
  }

  Future<List<Thread>> getThreadsByParticipantId(String participantId) async {
    try {
      return await _threadService.getThreadsByParticipantId(participantId);
    } catch (error) {
      // Handle errors, e.g., show an error message to the Thread
      print('Error getting Threads: $error');
      rethrow;
    }
  }

  //get thread by comment id
  Future<Thread> getThreadByCommentId(String commentId) async {
    try {
      return await _threadService.getThreadByCommentId(commentId);
    } catch (error) {
      // Handle errors, e.g., show an error message to the Thread
      print('Error getting Thread: $error');
      rethrow;
    }
  }

  Future<void> addCommentToThread(String threadId, String commentId) async {
    try {
      await _threadService.addCommentToThread(threadId, commentId);
    } catch (error) {
      // Handle errors, e.g., show an error message to the Thread
      print('Error adding Comment to Thread: $error');
    }
  }

  Future<void> removeCommentFromThread(
      String threadId, String commentId) async {
    try {
      await _threadService.removeCommentFromThread(threadId, commentId);
    } catch (error) {
      // Handle errors, e.g., show an error message to the Thread
      print('Error removing Comment from Thread: $error');
    }
  }

  Future<void> addParticipantToThread(
      String threadId, String participantId) async {
    try {
      await _threadService.addParticipantToThread(threadId, participantId);
    } catch (error) {
      // Handle errors, e.g., show an error message to the Thread
      print('Error adding Participant to Thread: $error');
    }
  }

  Future<void> addArticleToThread(
      String threadId, String articleId) async {
    try {
      await _threadService.addArticleToThread(threadId, articleId);
    } catch (error) {
      // Handle errors, e.g., show an error message to the Thread
      print('Error adding Participant to Thread: $error');
    }
  }
}
