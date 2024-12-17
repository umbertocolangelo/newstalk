import 'package:dima/pages/community_homepage.dart';
import 'package:dima/utils/palette.dart';
import 'package:dima/widgets/community/edit_community_fields.dart';
import 'package:flutter/material.dart';
import 'package:dima/managers/controllers/community_controller.dart';
import 'package:dima/model/community.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class EditCommunityPage extends StatefulWidget {
  final String communityId;

  const EditCommunityPage({
    Key? key,
    required this.communityId,
  }) : super(key: key);

  @override
  _EditCommunityPageState createState() => _EditCommunityPageState();
}

class _EditCommunityPageState extends State<EditCommunityPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final CommunityController _communityController = CommunityController();
  late Community newCommunity;

  void _editCommunity(
      List<String> selectedCategories,
      String type,
      LatLng position,
      String backgroundImagePath,
      String profileImagePath) async {
    try {
      // Retrieve community data
      Community currentCommunity =
          await _communityController.getCommunityById(widget.communityId);

      // Prepare data
      newCommunity = Community(
        id: currentCommunity.id,
        name: _nameController.text,
        categories: selectedCategories,
        bio: _bioController.text,
        backgroundImagePath: backgroundImagePath,
        profileImagePath: profileImagePath,
        type: type,
        threadIds: currentCommunity.threadIds,
        memberIds: currentCommunity.memberIds,
        adminId: currentCommunity.adminId,
        requestStatus: currentCommunity.requestStatus,
        createdAt: currentCommunity.createdAt,
        coordinates: "${position.latitude},${position.longitude}",
      );

      await _communityController.updateCommunity(newCommunity.id, newCommunity.toJson());

      _reloadCommunityPage(context);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('Errore durante la modifica della community: $error')),
      );
    }
  }
  
  Future<void> _reloadCommunityPage(BuildContext context) async {
    Navigator.pop(context);
    Navigator.pop(context);
    await Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => CommunityHomePage(community: newCommunity),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Palette.offWhite,
      child: FutureBuilder(
        future: Future.wait(
            [_communityController.getCommunityById(widget.communityId)]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              Community community = snapshot.data?[0] as Community;
              _nameController.text = community.name;
              _bioController.text = community.bio;
              var coords = community.coordinates.split(',');
              LatLng coordinates = LatLng(double.parse(coords[0]), double.parse(coords[1]));
              return Scaffold(
                appBar: AppBar(
                  centerTitle: true,
                  title: Text('Modifica',
                      style: TextStyle(
                          color: Palette.red,
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold)),
                  backgroundColor: Palette.offWhite,
                  foregroundColor: Palette.black,
                  elevation: 0,
                ),
                body: Container(
                  color: Palette.offWhite,
                  child: SingleChildScrollView(
                      padding: EdgeInsets.all(16.sp),
                      child: CreateCommunityFields(
                          communityId: widget.communityId,
                          name: community.name,
                          nameController: _nameController,
                          bioController: _bioController,
                          selectedCategories: community.categories,
                          backgroundImagePath: community.backgroundImagePath,
                          profileImagePath: community.profileImagePath,
                          position: coordinates,
                          onSubmit: _editCommunity)),
                ),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text(snapshot.error.toString()),
              );
            } else {
              return const Center(child: Text('Error'));
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
}
