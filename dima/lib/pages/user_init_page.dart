import 'dart:io';

import 'package:dima/managers/controllers/user_controller.dart';
import 'package:dima/managers/services/image_service.dart';
import 'package:dima/model/globals.dart';
import 'package:dima/model/user.dart';
import 'package:dima/pages/home_page.dart';
import 'package:dima/utils/alert_login_dialog.dart';
import 'package:dima/utils/palette.dart';
import 'package:dima/widgets/profilePage/edit_profile_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class UserInitPage extends StatefulWidget {
  const UserInitPage({super.key});
  static const routeName = '/init';

  @override
  State<UserInitPage> createState() => _UserInitPageState();
}

class _UserInitPageState extends State<UserInitPage> {
  String userId = Globals.instance.userUid.toString();
  late User userData;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  String selectedImage = 'assets/images/avatar_4.png'; // Default profile image

  bool _isImagePicking = false;

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

    return Container(
      padding: const EdgeInsets.all(0),
      child: FutureBuilder(
        future: Future.wait([userController.getUserById(userId)]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              userData = snapshot.data?[0] as User;
              _nameController.text = '';
              _usernameController.text = '';
              _bioController.text = '';
              return _editProfileView(context);
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

  Widget _editProfileView(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.offWhite,
      appBar: AppBar(
        centerTitle: true,
        title: Text('Crea Profilo',
            style: TextStyle(
                color: Palette.red,
                fontSize: 24.sp,
                fontWeight: FontWeight.bold)),
        backgroundColor: Palette.offWhite,
        foregroundColor: Palette.black,
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
        setState(() {
          selectedImage = imageUrl;
        });
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

  void onConfirmPressed() async {
    // Circular progress indicator
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

    // Prepare data

    Map<String, dynamic> newData = {
      'id': userData.id,
      'name': _nameController.text,
      'email': userData.email,
      'username': _usernameController.text,
      'profileImagePath': selectedImage,
      'bio': _bioController.text,
      'communityIds': userData.communityIds,
      'threadIds': userData.threadIds,
      'initialized': true,
      'selectedCategories': userData.selectedCategories,
      'selectedSources': userData.selectedSources
    };

    // Update data
    userController.updateUser(userId, newData).then((_) {
      // if successful
      print('User updated successfully');
      Navigator.pop(context);
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => HomePage()),
        (Route<dynamic> route) => false,
      );
    }).catchError((error) {
      Navigator.pop(context);
      showDialog(
        context: context,
        builder: (context) =>
            AlertLoginDialog(text: ('Failed to create profile: $error')),
      );
    });
  }
}
