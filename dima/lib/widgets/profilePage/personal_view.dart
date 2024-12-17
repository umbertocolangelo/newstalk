import 'package:dima/managers/controllers/user_controller.dart';
import 'package:dima/managers/services/image_service.dart';
import 'package:dima/pages/login_or_register_page.dart';
import 'package:dima/utils/palette.dart';
import 'package:dima/widgets/profilePage/communities_view.dart';
import 'package:dima/widgets/profilePage/edit_profile_fields.dart';
import 'package:dima/widgets/profilePage/settings_drawer.dart';
import 'package:dima/widgets/profilePage/threads_view.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:flutter/material.dart';
import 'package:dima/model/user.dart';
import 'package:dima/utils/alert_login_dialog.dart';
import 'dart:io';

import 'package:flutter_screenutil/flutter_screenutil.dart';

class PersonalView extends StatefulWidget {
  const PersonalView({super.key});

  @override
  State<PersonalView> createState() => _PersonalViewState();
}

class _PersonalViewState extends State<PersonalView> {
  String userId = '';
  bool isLoggedIn = true;
  late User userData;
  bool isEditing = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  late String selectedImage =
      'assets/images/avatar_4.png'; // Default profile image

  bool _isImagePicking = false;

  @override
  void initState() {
    super.initState();
    firebase.FirebaseAuth.instance
        .authStateChanges()
        .listen((firebase.User? user) {
      if (user != null) {
        if (mounted) {
          setState(() {
            userId = user.uid;
          });
        }
      } else {
        setState(() {
          isLoggedIn = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
        ScreenUtil.init(context, designSize: Size(360, 690), minTextAdapt: true);

    UserController userController = UserController();

    if (!isLoggedIn) {
      return LoginOrRegisterPage(context);
    }

    return Container(
      padding: const EdgeInsets.all(0),
      color: Palette.offWhite,
      child: FutureBuilder(
        future: Future.wait([userController.getUserById(userId)]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              userData = snapshot.data?[0] as User;
              _nameController.text = userData.name;
              _usernameController.text = userData.username;
              _bioController.text = userData.bio;
              if (!isEditing) {
                selectedImage = userData.profileImagePath;
              }
              return isEditing
                  ? _editProfileView(context)
                  : _profileView(context, userData);
            } else if (snapshot.hasError) {
              return Center(
                child: Text(snapshot.error.toString()),
              );
            } else {
              return const Center(child: Text('Errore'));
            }
          } else {
            return Container(
              color: Palette.offWhite,
              child: Center(
                child: SizedBox(
                  width: 80.sp,
                  height: 80.sp,
                  child: CircularProgressIndicator(
                    strokeWidth: 5,
                    valueColor: AlwaysStoppedAnimation<Color>(Palette.grey),
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _editProfileView(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.offWhite,
      appBar: AppBar(
        centerTitle: true,
        title: Text('Modifica',
            style: TextStyle(
                color: Palette.red,
                fontSize: 24.sp,
                fontWeight: FontWeight.bold)),
        backgroundColor: Palette.offWhite,
        foregroundColor: Palette.black,
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () => setState(() => isEditing = false),
        ),
      ),
      body: ListView(
        children: [
          // profile avatar selection
          GestureDetector(
            onTap: () => _selectProfileAvatar(context),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                    height: 120.sp,
                    width: 120.sp,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Palette.grey,
                    ),
                    child: ClipOval(
                      child: _isImagePicking
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(),
                                SizedBox(height: 5.sp),
                                Text("Attendere...")
                              ],
                            )
                          : selectedImage.startsWith('assets')
                              ? Image.asset(
                                  selectedImage,
                                  fit: BoxFit.cover,
                                )
                              : Image.network(
                                  selectedImage,
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
                                          child: CircularProgressIndicator(
                                            value: loadingProgress
                                                        .expectedTotalBytes !=
                                                    null
                                                ? loadingProgress
                                                        .cumulativeBytesLoaded /
                                                    loadingProgress
                                                        .expectedTotalBytes!
                                                : null,
                                            valueColor: AlwaysStoppedAnimation(
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
                    ))
              ],
            ),
          ),

          SizedBox(height: 15.sp),

          // Edit profile fields
          EditProfileFields(
            username: userData.username,
            nameController: _nameController,
            usernameController: _usernameController,
            bioController: _bioController,
            onSubmit: onConfirmPressed,
          )
        ],
      ),
    );
  }

  void _selectProfileAvatar(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return Container(
          height: 300.sp,
          child: Column(
            children: [
              SizedBox(height: 20.sp),
              ElevatedButton.icon(
                onPressed: () async {
                  _handleProfileImagePick();
                  Navigator.pop(context);
                },
                icon: Icon(Icons.photo),
                label: Text('Seleziona l\'immagine dalla galleria'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[300],
                  foregroundColor: Colors.grey[700],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  padding: EdgeInsets.symmetric(
                      vertical: 16.sp,
                      horizontal: 24.sp), // Padding interno del bottone
                ),
              ),
              SizedBox(height: 20.sp),
              Expanded(
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 6,
                  itemBuilder: (context, index) {
                    String imgPath = 'assets/images/avatar_${index + 1}.png';
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedImage = imgPath;
                        });
                        Navigator.pop(context);
                      },
                      child: Padding(
                        padding: EdgeInsets.all(8.sp),
                        child: CircleAvatar(
                          backgroundImage: AssetImage(imgPath),
                          radius: 60.sp,
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 20.sp),
            ],
          ),
        );
      },
    );
  }

  Future<void> _profileImagePick() async {
    ImageService imageService = ImageService();
    File? imageFile = await imageService.pickImageFromGallery();
    if (imageFile != null) {
      String? imageUrl = await imageService.uploadImage(
          imageFile, 'user_profiles/$userId/profile_image');
      if (imageUrl != null) {
          selectedImage = imageUrl;
      }
    }
  }

  Future<void> _handleProfileImagePick() async {

    setState(() {
      _isImagePicking = true;
    });
    await _profileImagePick();
    setState(() {
      _isImagePicking = false;
    });

  }

  Widget _profileView(BuildContext context, User userData) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Palette.offWhite,
      key: _scaffoldKey,
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          physics:
              AlwaysScrollableScrollPhysics(), // Ensure the scroll view is always scrollable
          child: DefaultTabController(
            length: 2,
            child: Column(
              children: [
                AppBar(
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
                  elevation: 0,
                  leading: IconButton(
                    icon: Icon(Icons.settings, size: 30.sp),
                    onPressed: () {
                      _scaffoldKey.currentState?.openDrawer();
                    },
                  ),
                ),
                isEditing
                    ? Container()
                    : Container(
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

                            SizedBox(height: 15.sp),

                            // username
                            Text(
                              userData.username,
                              style: TextStyle(
                                  color: Palette.red,
                                  fontSize: 24.sp,
                                  fontWeight: FontWeight.bold),
                            ),

                            SizedBox(height: 5.sp),
                            // Bio
                            Text(
                              userData.bio,
                              style: TextStyle(
                                  color: Palette.black, fontSize: 17.sp),
                              textAlign: TextAlign.center,
                            ),

                            SizedBox(height: 25.sp),

                            // edit profile
                            GestureDetector(
                              onTap: () => setState(() => isEditing = true),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(10.sp),
                                    decoration: BoxDecoration(
                                      color: Palette.beige,
                                      border: Border.all(color: Palette.black),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.edit, color: Palette.black),
                                        SizedBox(width: 5.sp),
                                        Text(
                                          'Modifica profilo',
                                          style: TextStyle(
                                              color: Palette.black,
                                              fontSize: 16.sp),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: 15.sp),

                            // Communities and threads
                            Container(
                              height: 80.sp,
                              child: TabBar(
                                indicatorColor: Palette.red,
                                tabs: [
                                  // Tab Community
                                  Tab(
                                    height: 60.sp,
                                    child: Column(
                                      children: [
                                        Text(
                                          '${userData.communityIds.length}',
                                          style: TextStyle(
                                            color: Palette.black,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 24.sp,
                                          ),
                                        ),
                                        Text(
                                          'Community',
                                          style: TextStyle(
                                            color: Palette.black,
                                            fontSize: 15.sp,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Tab Thread
                                  Tab(
                                    height: 60.sp,
                                    child: Column(
                                      children: [
                                        Text(
                                          '${userData.threadIds.length}',
                                          style: TextStyle(
                                            color: Palette.black,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 24.sp,
                                          ),
                                        ),
                                        Text(
                                          'Thread',
                                          style: TextStyle(
                                            color: Palette.black,
                                            fontSize: 15.sp,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Widgets to show
                            Container(
                              height: MediaQuery.of(context).size.height * 0.37,
                              child: TabBarView(
                                children: [
                                  CommunitiesView(userId: userId),
                                  ThreadsView(userId: userId),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),

      // Settings drawer
      drawer: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
        return SettingsDrawer(
          userId: userId,
          width: constraints.maxWidth,
        );
      }),
    );
  }

  void onConfirmPressed() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Container(
          color: Palette.offWhite,
          child: const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Palette.grey),
            ),
          ),
        );
      },
    );

    UserController userController = UserController();

    Map<String, dynamic> newData = {
      'id': userData.id,
      'name': _nameController.text,
      'email': userData.email,
      'username': _usernameController.text,
      'profileImagePath': selectedImage,
      'bio': _bioController.text,
      'communityIds': userData.communityIds,
      'threadIds': userData.threadIds,
      'selectedCategories': userData.selectedCategories,
      'selectedSources': userData.selectedSources
    };

    userController.updateUser(userId, newData).then((_) {
      print('Utente modificato con successo');
      Navigator.pop(context);
      setState(() => isEditing = false);
    }).catchError((error) {
      Navigator.pop(context);
      showDialog(
        context: context,
        builder: (context) => AlertLoginDialog(
            text: ('Errore nella modifica del profilo: $error')),
      );
    });
  }

  Future<void> _refreshData() async {
    setState(() {});
  }
}
