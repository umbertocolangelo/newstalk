import 'package:dima/managers/controllers/thread_controller.dart';
import 'package:dima/managers/controllers/user_controller.dart';
import 'package:dima/model/globals.dart';
import 'package:dima/model/thread.dart';
import 'package:dima/utils/palette.dart';
import 'package:dima/widgets/profilePage/communities_view.dart';
import 'package:dima/widgets/profilePage/threads_view.dart';
import 'package:flutter/material.dart';
import 'package:dima/model/user.dart';
import 'package:dima/utils/alert_login_dialog.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PublicView extends StatefulWidget {
  final String userId;

  const PublicView({super.key, required this.userId});

  @override
  State<PublicView> createState() => _PublicViewState();
}

class _PublicViewState extends State<PublicView> {
  late User? userData;
  late User? loggedInUser;
  late List<Thread> visibleThreads = [];

  Future<void> _getUsersData(BuildContext context) async {
    try {
      UserController userController = UserController();
      ThreadController threadController = ThreadController();
      // Retrieve Users
      loggedInUser =
          await userController.getUserById(Globals.instance.userUid.toString());
      userData = await userController.getUserById(widget.userId);

      // Retrieve visible threads
      List<Thread> userThreads =
          await threadController.getThreadsByAuthorId(widget.userId);
      visibleThreads = userThreads
          .where((thread) =>
              loggedInUser!.communityIds.contains(thread.communityId))
          .toList();
    } catch (error) {
      Navigator.pop(context);
      showDialog(
        context: context,
        builder: (context) =>
            AlertLoginDialog(text: ('An unexpected error occurred: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
        ScreenUtil.init(context, designSize: Size(360, 690), minTextAdapt: true);

    return FutureBuilder<void>(
      future: _getUsersData(context),
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return Container(
            color: Palette.offWhite,
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Palette.grey),
              ),
            ),
          );
        } else if (userSnapshot.hasError) {
          return Center(
              child: Text('An error occurred: ${userSnapshot.error}'));
        } else {
          if (userData != null && loggedInUser != null) {
            return _profileView(context, userData!, loggedInUser!);
          } else {
            return Center(child: Text('Nessun utente trovato'));
          }
        }
      },
    );
  }

  Widget _profileView(
      BuildContext context, User userData, User watchingUserData) {
    return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            backgroundColor: Palette.offWhite,
            foregroundColor: Palette.black,
            title: Text(
              'Profilo',
              style: TextStyle(
                color: Palette.black,
                fontSize: 24.sp,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
          body: Container(
            color: Palette.offWhite,
            child: Column(
              children: [
                // profile picture
                Container(
                  height: 120.sp,
                  width: 120.sp,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Palette.grey,
                  ),
                  child: ClipOval(
                    child: userData.profileImagePath
                            .startsWith('assets')
                        ? Image.asset(
                            userData.profileImagePath,
                            fit: BoxFit.cover,
                          )
                        : Image.network(
                            userData.profileImagePath,
                            fit: BoxFit.cover,
                            loadingBuilder: (BuildContext context,
                                Widget child,
                                ImageChunkEvent? loadingProgress) {
                              if (loadingProgress == null)
                                return child; // L'immagine è stata caricata
                              return Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                children: [
                                  Container(
                                    color: Palette.grey,
                                    child:
                                        CircularProgressIndicator(
                                      value: loadingProgress
                                                  .expectedTotalBytes !=
                                              null
                                          ? loadingProgress
                                                  .cumulativeBytesLoaded /
                                              loadingProgress
                                                  .expectedTotalBytes!
                                          : null,
                                      valueColor:
                                          AlwaysStoppedAnimation(
                                        Palette.offWhite,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                            errorBuilder: (BuildContext context,
                                Object exception,
                                StackTrace? stackTrace) {
                              return Icon(Icons.error, size: 50.0);
                            },
                          ),
                  ),
                ),


                // username
                Padding(
                  padding: EdgeInsets.all(20.0.sp),
                  child: Text(
                    userData.username,
                    style: TextStyle(
                        color: Palette.red,
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold),
                  ),
                ),

                // Bio
                Text(
                  userData.bio,
                  style: TextStyle(color: Palette.black, fontSize: 17.sp),
                  textAlign: TextAlign.center,
                ),
                 SizedBox(height: 15.sp),

                // Communities and threads
                Container(
                  height: 80.sp,
                  child: TabBar(
                    tabs: [
                      // Communities tab
                      Tab(
                        height: 60.sp,
                        child: Column(
                          children: [
                            Text(
                              '${userData.communityIds.where((id) => watchingUserData.communityIds.contains(id)).toList().length}',
                              style: TextStyle(
                                  color: Palette.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24.sp),
                            ),
                            Text(
                              'Community',
                              style:
                                  TextStyle(color: Palette.black, fontSize: 15.sp),
                            ),
                          ],
                        ),
                      ),

                      // Threads tab
                      Tab(
                        height: 60.sp,
                        child: Column(
                          children: [
                            Text(
                              '${visibleThreads.length}',
                              style: TextStyle(
                                  color: Palette.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24.sp),
                            ),
                            Text(
                              'Threads',
                              style:
                                  TextStyle(color: Palette.black, fontSize: 15.sp),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Widgets to show
                Expanded(
                  child: TabBarView(
                    children: [
                      CommunitiesView(userId: widget.userId),
                      ThreadsView(userId: widget.userId),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
