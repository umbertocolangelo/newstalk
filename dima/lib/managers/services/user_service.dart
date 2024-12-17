import 'package:dima/model/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<User>> getUsers() async {
    var result = await _db.collection('users').get();
    List<User> customers =
        result.docs.map((doc) => User.fromJson(doc.data())).toList();
    return customers;
  }

  Future<void> addUser(Map<String, dynamic> customerData, String uid) async {
    await _db.collection('users').doc(uid).set(customerData);
  }

  Future<void> updateUser(String userId, Map<String, dynamic> newData) async {
    var result =
        await _db.collection('users').where('id', isEqualTo: userId).get();
    await _db.collection('users').doc(result.docs.first.id).update(newData);
  }

  Future<void> deleteUser(String userId) async {
    var result =
        await _db.collection('users').where('id', isEqualTo: userId).get();
    await _db.collection('users').doc(result.docs.first.id).delete();
  }

  //get user by id
  Future<User> getUserById(String userId) async {
    var result =
        await _db.collection('users').where('id', isEqualTo: userId).get();
    User user = User.fromJson(result.docs.first.data());
    return user;
  }

  Future<bool> doesUserExist(String userId) async {
    var result =
        await _db.collection('users').where('id', isEqualTo: userId).get();
    if (result.docs.isEmpty) {
      return false;
    }
    return true;
  }

  //get users by thread id
  Future<List<User>> getUsersByThreadId(String threadId) async {
    var result =
        await _db.collection('threads').where('id', isEqualTo: threadId).get();
    var thread = result.docs.first.data();
    List<String> userIds = List<String>.from(thread['participantIds']);
    List<User> users = [];
    for (var userId in userIds) {
      var user = await getUserById(userId);
      users.add(user);
    }
    return users;
  }

  //get users by community id
  Future<List<User>> getUsersByCommunityId(String communityId) async {
    var result = await _db
        .collection('communities')
        .where('id', isEqualTo: communityId)
        .get();
    var community = result.docs.first.data();
    List<String> userIds = List<String>.from(community['memberIds']);
    List<User> users = [];
    for (var userId in userIds) {
      var user = await getUserById(userId);
      users.add(user);
    }
    return users;
  }

  // Check if a username is available
  Future<bool> doesUsernameExist(String username) async {
    var result = await _db
        .collection('users')
        .where('username', isEqualTo: username)
        .get();
    return result.docs.isNotEmpty;
  }

  Future<void> addCommunityToUser(String userId, String communityId) async {
    var result =
        await _db.collection('users').where('id', isEqualTo: userId).get();
    var user = User.fromJson(result.docs.first.data());
    user.communityIds.add(communityId);
    updateUser(userId, user.toJson());
  }

  Future<void> removeCommunityFromUser(
      String userId, String communityId) async {
    var result =
        await _db.collection('users').where('id', isEqualTo: userId).get();
    var user = User.fromJson(result.docs.first.data());
    user.communityIds.remove(communityId);
    updateUser(userId, user.toJson());
  }

  Future<void> addThreadToUser(String userId, String threadId) async {
    var result =
        await _db.collection('users').where('id', isEqualTo: userId).get();
    var user = User.fromJson(result.docs.first.data());
    user.threadIds.add(threadId);
    updateUser(userId, user.toJson());
  }

  Future<void> removeThreadFromUser(String userId, String threadId) async {
    var result =
        await _db.collection('users').where('id', isEqualTo: userId).get();
    var user = User.fromJson(result.docs.first.data());
    user.threadIds.remove(threadId);
    updateUser(userId, user.toJson());
  }

  Future<Set<String>> getUserSelectedCategories(String userId) async {
    // Fetch the user document based on the userId
    var result = await FirebaseFirestore.instance
        .collection('users')
        .where('id', isEqualTo: userId)
        .get();

    // Check if any documents were returned
    if (result.docs.isNotEmpty) {
      // Get the first user document from the query result
      var userDoc = result.docs.first;

      // Check if the document contains data and if 'selectedCategories' key exists
      var user = userDoc.data();
      if (user.containsKey('selectedCategories')) {
        List<dynamic> categories = user['selectedCategories'];
        return categories.cast<String>().toSet();
      }
    }

    // Return an empty set if no categories found
    return <String>{};
  }

  Future<Set<String>> getUserSelectedSources(String userId) async {
    // Fetch the user document based on the userId
    var result = await FirebaseFirestore.instance
        .collection('users')
        .where('id', isEqualTo: userId)
        .get();

    // Check if any documents were returned
    if (result.docs.isNotEmpty) {
      // Get the first user document from the query result
      var userDoc = result.docs.first;
      var user = userDoc.data();
      if (user.containsKey('selectedSources')) {
        List<dynamic> categories = user['selectedSources'];
        return categories.cast<String>().toSet();
      }
    }
    return <String>{};
  }

  Future<void> setUserSelectedCategories(
      String userId, List<String> selectedCategories) async {
    try {
      // Get the user's document based on the userId
      var result = await FirebaseFirestore.instance
          .collection('users')
          .where('id', isEqualTo: userId)
          .get();

      if (result.docs.isNotEmpty) {
        // Update the user's document with new data
        await FirebaseFirestore.instance
            .collection('users')
            .doc(result.docs.first.id)
            .update({
          'selectedCategories': selectedCategories,
        });

        print("Selected categories saved successfully.");
      } else {
        print("User not found.");
      }
    } catch (error) {
      print("Error saving selected categories: $error");
    }
  }

  Future<void> setUserSelectedSources(
      String userId, List<String> selectedCategories) async {
    try {
      // Get the user's document based on the userId
      var result = await FirebaseFirestore.instance
          .collection('users')
          .where('id', isEqualTo: userId)
          .get();

      if (result.docs.isNotEmpty) {
        // Update the user's document with new data
        await FirebaseFirestore.instance
            .collection('users')
            .doc(result.docs.first.id)
            .update({
          'selectedSources': selectedCategories,
        });

        print("Selected sources saved successfully.");
      } else {
        print("User not found.");
      }
    } catch (error) {
      print("Error saving selected sources: $error");
    }
  }
}
