import 'package:dima/model/community.dart';
import 'package:dima/managers/services/community_service.dart';
import 'package:flutter/cupertino.dart';

class CommunityController with ChangeNotifier {
  final CommunityService _communityService = CommunityService();
  List<Community> communities = [];

  Future<List<Community>> fetchCommunities() async {
    try {
      communities = await _communityService.getCommunities();
      return communities;
    } catch (error) {
      // Handle errors, e.g., show an error message to the Community
      print('Error fetching Communities: $error');
      rethrow;
    }
  }

  Future<void> addCommunity(Map<String, dynamic> communityData) async {
    try {
      await _communityService.addCommunity(communityData);
    } catch (error) {
      // Handle errors, e.g., show an error message to the Community
      print('Error adding Community: $error');
    }
  }

  Future<void> addThreadToCommunity(String communityId, String threadId) async {
    try {
      await _communityService.addThreadToCommunity(communityId, threadId);
    } catch (error) {
      // Handle errors, e.g., show an error message to the Community
      print('Error adding thread to Community: $error');
    }
  }

  Future<void> removeThreadFromCommunity(
      String communityId, String threadId) async {
    try {
      await _communityService.removeThreadFromCommunity(communityId, threadId);
    } catch (error) {
      // Handle errors, e.g., show an error message to the Community
      print('Error removing thread from Community: $error');
    }
  }

  Future<void> addMemberToCommunity(String communityId, String userId) async {
    try {
      await _communityService.addMemberToCommunity(communityId, userId);
    } catch (error) {
      // Handle errors, e.g., show an error message to the Community
      print('Error adding member to Community: $error');
    }
  }

  Future<void> removeMemberFromCommunity(
      String communityId, String userId) async {
    try {
      await _communityService.removeMemberFromCommunity(communityId, userId);
    } catch (error) {
      // Handle errors, e.g., show an error message to the Community
      print('Error removing member from Community: $error');
    }
  }

  Future<void> updateCommunity(
      String communityId, Map<String, dynamic> newData) async {
    try {
      await _communityService.updateCommunity(communityId, newData);
    } catch (error) {
      // Handle errors, e.g., show an error message to the Community
      print('Error updating Community: $error');
    }
  }

  Future<void> deleteCommunity(String communityId) async {
    try {
      await _communityService.deleteCommunity(communityId);
    } catch (error) {
      // Handle errors, e.g., show an error message to the Community
      print('Error deleting Community: $error');
    }
  }

  Future<Community> getCommunityById(String communityId) async {
    try {
      return await _communityService.getCommunityById(communityId);
    } catch (error) {
      // Handle errors, e.g., show an error message to the Community
      print('Error getting Community: $error');
      rethrow;
    }
  }

  Future<List<Community>> getCommunitiesByIds(List<String> communityIds) async {
    try {
      return await _communityService.getCommunitiesByIds(communityIds);
    } catch (error) {
      // Handle errors, e.g., show an error message to the Community
      print('Error getting Communities: $error');
      rethrow;
    }
  }

  Future<List<Community>> getCommunityByThreadId(String threadId) async {
    try {
      return await _communityService.getCommunityByThreadId(threadId);
    } catch (error) {
      // Handle errors, e.g., show an error message to the Community
      print('Error getting Communities: $error');
      rethrow;
    }
  }

  Future<List<Community>> getCommunitiesByUserId(String userId) async {
    try {
      return await _communityService.getCommunitiesByUserId(userId);
    } catch (error) {
      // Handle errors, e.g., show an error message to the Community
      print('Error getting Communitys: $error');
      rethrow;
    }
  }

  Future<void> requestAccess(String communityId, String userId) async {
    try {
      await _communityService.requestAccess(communityId, userId);
    } catch (error) {
      // Handle errors, e.g., show an error message to the Community
      print('Error requesting access: $error');
    }
  }

  Future<void> approveRequest(String communityId, String userId) async {
    try {
      await _communityService.approveRequest(communityId, userId);
    } catch (error) {
      // Handle errors, e.g., show an error message to the Community
      print('Error approving request: $error');
    }
  }

  Future<void> rejectRequest(String communityId, String userId) async {
    try {
      await _communityService.rejectRequest(communityId, userId);
    } catch (error) {
      // Handle errors, e.g., show an error message to the Community
      print('Error rejecting request: $error');
    }
  }

  Future<void> cancelRequest(String communityId, String userId) async {
    try {
      await _communityService.cancelRequest(communityId, userId);
    } catch (error) {
      // Handle errors, e.g., show an error message to the Community
      print('Error canceling request: $error');
    }
  }

  //remove user from community
  Future<void> removeUserFromCommunity(
      String communityId, String userId) async {
    try {
      await _communityService.cancelRequest(communityId, userId);
    } catch (error) {
      // Handle errors, e.g., show an error message to the Community
      print('Error removing user from community: $error');
    }
  }

  Future<bool> doesCommunityExist(String name) async {
    try {
      return await _communityService.doesCommunityExist(name);
    } catch (error) {
      // Handle errors, e.g., show an error message to the Community
      print('Error checking for community availablity: $error');
      rethrow;
    }
  }

  Future<List<Community>> fetchCommunityDocID(List<String> docIds) async {
    try {
      return await _communityService.fetchCommunitesDocId(docIds);
    } catch (error) {
      // Handle errors, e.g., show an error message to the Community
      print('Error checking for community availablity: $error');
      rethrow;
    }
  }
}
