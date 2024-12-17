import 'package:dima/model/globals.dart';
import 'package:dima/pages/user_init_page.dart';
import 'package:dima/managers/controllers/user_controller.dart';
import 'package:dima/utils/alert_login_dialog.dart';
import 'package:dima/utils/palette.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:flutter/material.dart';
import 'home_page.dart';
import 'package:dima/model/user.dart';

class AuthPage extends StatelessWidget {
  static const routeName = '/';
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    //signUserOut(context);
    return Scaffold(
      body: StreamBuilder<firebase.User?>(
        stream: firebase.FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            if (snapshot.hasData) {
              // If user is logged in
              String uid = snapshot.data!.uid;
              Globals.instance.userUid = uid;
              return FutureBuilder<void>(
                future: _handleUserState(context, uid, snapshot.data!.email!),
                builder: (context, userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return Container(
                      color: Palette.offWhite,
                      child: const Center(
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Palette.grey),
                        ),
                      ),
                    );
                  } else if (userSnapshot.hasError) {
                    return Center(
                        child:
                            Text('An error occurred: ${userSnapshot.error}'));
                  } else {
                    return Container(
                      color: Palette.offWhite,
                      child: const Center(
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Palette.grey),
                        ),
                      ),
                    );
                  }
                },
              );
            } else {
              // If user is not logged in
              Globals.instance.userUid = null;
              return const HomePage();
            }
          } else {
            return Container(
              color: Palette.offWhite,
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Palette.grey),
                ),
              ),
            );
          }
        },
      ),
    );
  }

  Future<void> _handleUserState(
      BuildContext context, String uid, String email) async {
    try {
      UserController userController = UserController();

      if (!(await userController.doesUserExist(uid))) {
        // User does not exist in DB, create new user
        await createUser(context, uid, email);
        Navigator.pushReplacementNamed(context, UserInitPage.routeName);
      } else {
        User user = await userController.getUserById(uid);
        // User exists in DB, check if initialized
        if (!user.initialized) {
          Navigator.pushReplacementNamed(context, UserInitPage.routeName);
        } else {
          Navigator.pushReplacementNamed(context, HomePage.routeName);
        }
      }
    } catch (error) {
      Navigator.pop(context);
      showDialog(
        context: context,
        builder: (context) =>
            AlertLoginDialog(text: ('An unexpected error occurred : $error')),
      );
    }
  }

  Future<void> createUser(
      BuildContext context, String uid, String email) async {
    UserController userController = UserController();
    List<String> emptyList = [];
    Map<String, String> emptyMap = Map();

    final List<String> categories = [
      'Tutto',
      'Attualità',
      'Sport',
      'Intrattenimento',
      'Salute',
      'Economia',
      'Tecnologia',
    ];

    final List<String> sources = [
      "gazzetta_sport",
      "fatto_quotidiano",
      "della_sera",
      "il_giornale",
      "foglio",
      "sole24",
      "fanpage",
      "libero",
      "sky_tg",
      "ansa",
      "micro_bio",
      "donna_moderna"
    ];

    // Prepare data
    Map<String, dynamic> newData = {
      'id': uid,
      'name': "",
      'email': email,
      'password': "",
      'username': "",
      'profileImagePath': "assets/images/avatar_4.png",
      'bio': "",
      'communityIds': emptyList,
      'threadIds': emptyList,
      'initialized': false,
      'communityRequests': emptyMap,
      'selectedCategories': categories,
      'selectedSources': sources
    };

    // Update data
    await userController.addUser(newData, uid).catchError((error) {
      // If failed
      Navigator.pop(context);
      showDialog(
        context: context,
        builder: (context) =>
            AlertLoginDialog(text: ('Failed to create profile: $error')),
      );
    });
  }

  void signUserOut(BuildContext context) async {
    await firebase.FirebaseAuth.instance.signOut();
    // Navigate to AuthPage after sign out
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const AuthPage()),
    );
  }
}
