import 'package:dima/model/user.dart';
import 'package:dima/managers/services/user_service.dart';
import 'package:flutter/cupertino.dart';

class UserController with ChangeNotifier {
  final UserService _userService = UserService();
  List<User> users = [];

  Future<List<User>> fetchUsers() async {
    try {
      users = await _userService.getUsers();
      return users;
    } catch (error) {
      // Handle errors, e.g., show an error message to the User
      print('Error fetching Users: $error');
      rethrow;
    }
  }

  Future<void> addUser(Map<String, dynamic> userData, String uid) async {
    try {
      await _userService.addUser(userData, uid);
    } catch (error) {
      // Handle errors, e.g., show an error message to the User
      print('Error adding User: $error');
    }
  }

  Future<void> updateUser(String userId, Map<String, dynamic> newData) async {
    try {
      await _userService.updateUser(userId, newData);
    } catch (error) {
      // Handle errors, e.g., show an error message to the User
      print('Error updating User: $error');
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      await _userService.deleteUser(userId);
    } catch (error) {
      // Handle errors, e.g., show an error message to the User
      print('Error deleting User: $error');
    }
  }

  Future<User> getUserById(String userId) async {
    try {
      return await _userService.getUserById(userId);
    } catch (error) {
      // Handle errors, e.g., show an error message to the User
      print('Error getting User: $error');
      rethrow;
    }
  }

  Future<List<User>> getUsersByThreadId(String threadId) async {
    try {
      return await _userService.getUsersByThreadId(threadId);
    } catch (error) {
      // Handle errors, e.g., show an error message to the User
      print('Error getting Users: $error');
      rethrow;
    }
  }

  Future<List<User>> getUsersByCommunityId(String communityId) async {
    try {
      return await _userService.getUsersByCommunityId(communityId);
    } catch (error) {
      // Handle errors, e.g., show an error message to the User
      print('Error getting Users: $error');
      rethrow;
    }
  }

  Future<bool> doesUsernameExist(String username) async {
    try {
      return await _userService.doesUsernameExist(username);
    } catch (error) {
      // Handle errors, e.g., show an error message to the User
      print('Error getting response: $error');
      rethrow;
    }
  }

  Future<bool> doesUserExist(String userId) async {
    try {
      return await _userService.doesUserExist(userId);
    } catch (error) {
      // Handle errors, e.g., show an error message to the User
      print('Error getting response: $error');
      rethrow;
    }
  }

  Future<void> addCommunityToUser(String userId, String communityId) async {
    try {
      await _userService.addCommunityToUser(userId, communityId);
    } catch (error) {
      // Handle errors, e.g., show an error message to the User
      print('Error adding Community to User: $error');
    }
  }

  Future<void> removeCommunityFromUser(
      String userId, String communityId) async {
    try {
      await _userService.removeCommunityFromUser(userId, communityId);
    } catch (error) {
      // Handle errors, e.g., show an error message to the User
      print('Error removing Community from User: $error');
    }
  }

  Future<void> addThreadToUser(String userId, String threadId) async {
    try {
      await _userService.addThreadToUser(userId, threadId);
    } catch (error) {
      // Handle errors, e.g., show an error message to the User
      print('Error adding Thread to User: $error');
    }
  }

  Future<void> removeThreadFromUser(String userId, String threadId) async {
    try {
      await _userService.removeThreadFromUser(userId, threadId);
    } catch (error) {
      // Handle errors, e.g., show an error message to the User
      print('Error removing Thread from User: $error');
    }
  }

  Future<Set<String>> getSelectedCategorybyUser(
    String userId,
  ) async {
    try {
      Set<String> categories =
          await _userService.getUserSelectedCategories(userId);
      return categories;
    } catch (error) {
      // Handle errors, e.g., show an error message to the User
      print('Error retrieving categories from User: $error');
      return <String>{};
    }
  }

  Future<Set<String>> getSelectedSourcesbyUser(
    String userId,
  ) async {
    try {
      Set<String> categories =
          await _userService.getUserSelectedSources(userId);
      return categories;
    } catch (error) {
      // Handle errors, e.g., show an error message to the User
      print('Error retrieving sources from User: $error');
      return <String>{};
    }
  }

  Future<void> setSelctedCategorybyUser(
      String userId, List<String> selectedCategories) async {
    try {
      await _userService.setUserSelectedCategories(userId, selectedCategories);
    } catch (error) {
      // Handle errors, e.g., show an error message to the User
      print('Error setting category to User: $error');
    }
  }

  Future<void> setSelctedSourcesbyUser(
      String userId, List<String> selectedCategories) async {
    try {
      await _userService.setUserSelectedSources(userId, selectedCategories);
    } catch (error) {
      // Handle errors, e.g., show an error message to the User
      print('Error setting sources to User: $error');
    }
  }
}
