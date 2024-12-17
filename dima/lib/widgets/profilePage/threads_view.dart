import 'package:dima/managers/controllers/thread_controller.dart';
import 'package:dima/managers/controllers/user_controller.dart';
import 'package:dima/model/globals.dart';
import 'package:dima/model/thread.dart';
import 'package:dima/model/user.dart';
import 'package:dima/utils/palette.dart';
import 'package:dima/widgets/community/thread_list.dart';
import 'package:flutter/material.dart';

class ThreadsView extends StatelessWidget {
  final String userId;

  const ThreadsView({
    required this.userId,
  });

  Future<List<Thread>> _getThreads(
      ThreadController threadController, UserController userController) async {
    final loggedInUserId = Globals.instance.userUid.toString();
    if (userId.isEmpty) {
      // Show threads of the logged-in user
      return threadController.getThreadsByAuthorId(loggedInUserId);
    } else {
      // Filter threads based on community
      User? loggedInUser = await userController.getUserById(loggedInUserId);
      List<Thread> userThreads =
          await threadController.getThreadsByAuthorId(userId);
      return userThreads
          .where((thread) =>
              loggedInUser.communityIds.contains(thread.communityId))
          .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    ThreadController threadController = ThreadController();
    UserController userController = UserController();

    return Container(
      padding: const EdgeInsets.all(0),
      child: FutureBuilder<List<Thread>>(
        future: _getThreads(threadController, userController),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container(
              color: Palette.offWhite,
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Palette.grey),
                ),
              ),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Errore: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Nessun thread trovato'));
          } else {
            return CommunityThreadList(threads: snapshot.data!);
          }
        },
      ),
    );
  }
}
