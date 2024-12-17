import 'package:dima/model/community.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CommunityService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<Community>> getCommunities() async {
    var result = await _db.collection('communities').get();
    List<Community> communities =
        result.docs.map((doc) => Community.fromJson(doc.data())).toList();
    return communities;
  }

  Future<List<Community>> getCommunitiesByIds(List<String> communityIds) async {
    List<Community> communities = await getCommunities();
    return communities
        .where((community) => communityIds.contains(community.id))
        .toList();
  }

  Future<void> addCommunity(Map<String, dynamic> communityData) async {
    await _db.collection('communities').add(communityData);
  }

  Future<void> addThreadToCommunity(String communityId, String threadId) async {
    var result = await _db
        .collection('communities')
        .where('id', isEqualTo: communityId)
        .get();
    result.docs.first.reference.update({
      'threadIds': FieldValue.arrayUnion([threadId]),
    });
  }

  Future<void> removeThreadFromCommunity(
      String communityId, String threadId) async {
    var result = await _db
        .collection('communities')
        .where('id', isEqualTo: communityId)
        .get();
    result.docs.first.reference.update({
      'threadIds': FieldValue.arrayRemove([threadId]),
    });
  }

  Future<void> addMemberToCommunity(String communityId, String userId) async {
    var result = await _db
        .collection('communities')
        .where('id', isEqualTo: communityId)
        .get();
    result.docs.first.reference.update({
      'memberIds': FieldValue.arrayUnion([userId]),
    });
  }

  Future<void> removeMemberFromCommunity(
      String communityId, String userId) async {
    var result = await _db
        .collection('communities')
        .where('id', isEqualTo: communityId)
        .get();
    result.docs.first.reference.update({
      'memberIds': FieldValue.arrayRemove([userId]),
    });
  }

  Future<void> updateCommunity(
      String communityId, Map<String, dynamic> newData) async {
    var result = await _db
        .collection('communities')
        .where('id', isEqualTo: communityId)
        .get();
    result.docs.first.reference.update(newData);
  }

  Future<void> deleteCommunity(String communityId) async {
    var result = await _db
        .collection('communities')
        .where('id', isEqualTo: communityId)
        .get();
    result.docs.first.reference.delete();
  }

  Future<Community> getCommunityById(String communityId) async {
    var result = await _db
        .collection('communities')
        .where('id', isEqualTo: communityId)
        .get();
    Community community = Community.fromJson(result.docs.first.data());
    return community;
  }

  Future<List<Community>> getCommunityByThreadId(String threadId) async {
    var result = await _db
        .collection('communities')
        .where('threadIds', arrayContains: threadId)
        .get();
    List<Community> communities =
        result.docs.map((doc) => Community.fromJson(doc.data())).toList();
    return communities;
  }

  Future<List<Community>> getCommunitiesByUserId(String userId) async {
    var result = await _db
        .collection('communities')
        .where('memberIds', arrayContains: userId)
        .get();
    List<Community> communities =
        result.docs.map((doc) => Community.fromJson(doc.data())).toList();
    return communities;
  }

  Future<void> requestAccess(String communityId, String userId) async {
    var communityResult = await _db
        .collection('communities')
        .where('id', isEqualTo: communityId)
        .get();

    communityResult.docs.first.reference.update({
      'requestStatus.$userId': 'pending',
    });

    var userResult =
        await _db.collection('users').where('id', isEqualTo: userId).get();

    userResult.docs.first.reference.update({
      'communityRequests.$communityId': 'pending',
    });
  }

  Future<void> approveRequest(String communityId, String userId) async {
    var communityResult = await _db
        .collection('communities')
        .where('id', isEqualTo: communityId)
        .get();

    communityResult.docs.first.reference.update({
      'requestStatus.$userId': 'approved',
    });

    var userResult =
        await _db.collection('users').where('id', isEqualTo: userId).get();

    userResult.docs.first.reference.update({
      'communityRequests.$communityId': 'approved',
    });
  }

  Future<void> rejectRequest(String communityId, String userId) async {
    var communityResult = await _db
        .collection('communities')
        .where('id', isEqualTo: communityId)
        .get();

    communityResult.docs.first.reference.update({
      'requestStatus.$userId': 'rejected',
    });

    var userResult =
        await _db.collection('users').where('id', isEqualTo: userId).get();

    userResult.docs.first.reference.update({
      'communityRequests.$communityId': 'rejected',
    });
  }

  Future<void> cancelRequest(String communityId, String userId) async {
    var communityResult = await _db
        .collection('communities')
        .where('id', isEqualTo: communityId)
        .get();

    communityResult.docs.first.reference.update({
      'requestStatus.$userId': FieldValue.delete(),
    });

    var userResult =
        await _db.collection('users').where('id', isEqualTo: userId).get();

    userResult.docs.first.reference.update({
      'communityRequests.$communityId': FieldValue.delete(),
    });
  }

  // Check if a community name is available
  Future<bool> doesCommunityExist(String name) async {
    var result = await _db
        .collection('communities')
        .where('name', isEqualTo: name)
        .get();
    return result.docs.isNotEmpty;
  }

  Future<List<Community>> fetchCommunitesDocId(List<String> docIds) async {
    List<Community> communities = [];
    // Process in chunks of 10 to adhere to Firestore's limitations
    const chunkSize = 10;
    for (var i = 0; i < docIds.length; i += chunkSize) {
      // Calculate the range for the current chunk
      int end = (i + chunkSize < docIds.length) ? i + chunkSize : docIds.length;
      List<String> chunk = docIds.sublist(i, end);

      // Perform a batched fetch from Firestore
      var snapshot = await _db
          .collection('communities')
          .where(FieldPath.documentId, whereIn: chunk)
          .get();

      // Convert each document to an Article and add to the list
      for (var doc in snapshot.docs) {
        Community? article = Community.fromJson(doc.data());
        communities.add(article);
      }
    }
    return communities;
  }
}
