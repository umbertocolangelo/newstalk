import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima/managers/controllers/user_controller.dart';
import 'package:dima/model/globals.dart';
import 'package:dima/pages/community_homepage.dart';
import 'package:dima/utils/palette.dart';
import 'package:dima/widgets/community/edit_community_fields.dart';
import 'package:flutter/material.dart';
import 'package:dima/managers/controllers/community_controller.dart';
import 'package:dima/model/community.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uuid/uuid.dart';

class CreateCommunityPage extends StatefulWidget {
  @override
  _CreateCommunityPageState createState() => _CreateCommunityPageState();
}

class _CreateCommunityPageState extends State<CreateCommunityPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final CommunityController _communityController = CommunityController();
  final UserController _userController = UserController();
  final String communityId = Uuid().v4();
  LatLng initial_coordinates = LatLng(45.478200, 9.228430);

  void _createCommunity(
      List<String> selectedCategories,
      String type,
      LatLng position,
      String profileImagePath,
      String backgroundImagePath) async {

    final newCommunity = Community(
      id: communityId,
      name: _nameController.text,
      categories: selectedCategories,
      bio: _bioController.text,
      backgroundImagePath: backgroundImagePath,
      profileImagePath: profileImagePath,
      type: type,
      threadIds: [],
      memberIds: [Globals.instance.userUid.toString()],
      adminId: Globals.instance.userUid.toString(),
      requestStatus: {},
      createdAt: Timestamp.now(),
      coordinates: "${position.latitude},${position.longitude}",
    );

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      // Create community
      await _communityController.addCommunity(newCommunity.toJson());
      // Add current user
      await _userController.addCommunityToUser(Globals.instance.userUid.toString(), newCommunity.id);
    }).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Community creata con successo')),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => CommunityHomePage(community: newCommunity),
        ),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('Errore durante la creazione della community: $error')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    
    ScreenUtil.init(context, designSize: Size(360, 690), minTextAdapt: true);
    return Scaffold(
      appBar: AppBar(
        title: Text('Crea Community',
            style: TextStyle(
              color: Palette.red,
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
            )),
        centerTitle: true,
        backgroundColor: Palette.offWhite,
        foregroundColor: Palette.black,
      ),
      body: Container(
        color: Palette.offWhite,
        child: SingleChildScrollView(
            padding: EdgeInsets.all(16.sp),
            child: CreateCommunityFields(
                communityId: communityId,
                name: "",
                nameController: _nameController,
                bioController: _bioController,
                selectedCategories: List.empty(),
                profileImagePath: "",
                backgroundImagePath: "",
                position: initial_coordinates,
                onSubmit: _createCommunity)),
      ),
    );
  }
}
