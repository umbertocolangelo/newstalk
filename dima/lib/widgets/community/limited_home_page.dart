import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima/managers/controllers/community_controller.dart';
import 'package:dima/managers/controllers/user_controller.dart';
import 'package:dima/model/community.dart';
import 'package:dima/pages/community_homepage.dart';
import 'package:dima/utils/palette.dart';
import 'package:dima/widgets/community/community_header.dart';
import 'package:dima/widgets/community/member_limited_list.dart';
import 'package:dima/widgets/community/thread_limited_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LimitedHomePage extends StatefulWidget {
  Community community;
  final String userId; // Get this from your auth provider

  LimitedHomePage({
    required this.community,
    required this.userId,
  });

  @override
  _LimitedHomePageState createState() => _LimitedHomePageState();
}

class _LimitedHomePageState extends State<LimitedHomePage> {
  final CommunityController communityController = CommunityController();
  final UserController userController = UserController();
  late Community community;

  final List<Map<String, String>> _categories = [
    {'emoji': '🌐', 'name': 'Attualità'},
    {'emoji': '🏅', 'name': 'Sport'},
    {'emoji': '🎬', 'name': 'Intrattenimento'},
    {'emoji': '💪', 'name': 'Salute'},
    {'emoji': '💼', 'name': 'Economia'},
    {'emoji': '💻', 'name': 'Tecnologia'}
  ];

  String _getCategoryEmoji(String categoryName) {
    return _categories.firstWhere(
        (category) => category['name'] == categoryName,
        orElse: () => {'emoji': '❓'})['emoji']!;
  }

  @override
  void initState() {
    _loadCommunity();
    super.initState();
  }

  Future<void> _loadCommunity() async {
    try {
      Community loadedCommunity =
          await communityController.getCommunityById(widget.community.id);
      setState(() {
        community = loadedCommunity;
      });
    } catch (e) {
      print("Errore durante il caricamento della community: $e");
    }
  }

  Future<void> _approveRequest() async {
    Community community;
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      await communityController.approveRequest(
          widget.community.id, widget.userId);
      await communityController.addMemberToCommunity(
          widget.community.id, widget.userId);
      await userController.addCommunityToUser(
          widget.userId, widget.community.id);
    }).then((_) async {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Iscrizione effettuata con successo!')),
      );
      community =
          await communityController.getCommunityById(widget.community.id);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => CommunityHomePage(
            community: community,
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('communities')
          .where('id', isEqualTo: widget.community.id)
          .snapshots(),
      builder: (context, threadSnapshot) {
        if (!threadSnapshot.hasData) {
          return Container(
            color: Palette.offWhite,
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Palette.grey),
              ),
            ),
          );
        }
        if (threadSnapshot.hasError) {
          return Center(child: Text('Errore nel caricamento della community'));
        }

        community = Community.fromJson(threadSnapshot.data!.docs.first.data());
        String? requestStatus = community.requestStatus[widget.userId];

        if (requestStatus == "approved") {
          return CommunityHomePage(community: community);
        }

        return Scaffold(
          backgroundColor: Palette.offWhite,
          appBar: AppBar(
            centerTitle: true,
            title: Text(community.name,
                style: TextStyle(
                    color: Palette.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 24.sp)),
            backgroundColor: Palette.offWhite,
            foregroundColor: Palette.black,
          ),
          body: LayoutBuilder(
            builder: (context, constraints) => ListView(
              padding: EdgeInsets.all(16.sp),
              children: [
                CommunityHeader(
                  backgroundImageUrl: widget.community.backgroundImagePath,
                  profileImageUrl: widget.community.profileImagePath,
                  title: widget.community.name,
                  height: constraints.maxHeight * 0.5,
                  width: constraints.maxWidth,
                ),
                SizedBox(height: constraints.maxHeight * 0.01),
                Text(
                  'Descrizione',
                  textAlign: TextAlign.start,
                  style:
                      TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                ),
                // Subtitle
                Text(
                  community.bio,
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    color: Palette.black,
                    fontSize: 16.sp, // Adjust font size as needed
                    fontWeight: FontWeight.normal,
                  ),
                ),
                SizedBox(height: constraints.maxHeight * 0.01),
                community.type == 'public'
                    ? Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 0, horizontal: 36.sp),
                        child: ElevatedButton(
                            onPressed: _approveRequest,
                            child: Text('Accedi'),
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              backgroundColor: Palette.red,
                              foregroundColor: Palette.offWhite,
                              padding: EdgeInsets.all(8.sp),
                            )))
                    : requestStatus == 'pending'
                        ? PendingRequest()
                        : Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 0, horizontal: 36.sp),
                            child: ElevatedButton(
                              onPressed: () async {
                                await communityController.requestAccess(
                                    widget.community.id, widget.userId);
                                Community community = await communityController
                                    .getCommunityById(widget.community.id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          'Richiesta inviata con successo!')),
                                );
                                setState(() {
                                  widget.community = community;
                                });
                              },
                              child: Text('Richiedi Accesso'),
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                backgroundColor: Palette.red,
                                foregroundColor: Palette.offWhite,
                                padding: EdgeInsets.all(8.sp),
                              ),
                            ),
                          ),
                SizedBox(height: constraints.maxHeight * 0.01),
                Text(
                  'Membri',
                  style:
                      TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${community.memberIds.length} membri iscritti!',
                  style: TextStyle(fontSize: 16.sp),
                ),
                SizedBox(height: constraints.maxHeight * 0.01),
                CommunityLimitedMemberList(
                  size: community.memberIds.length,
                  height: constraints.maxHeight * 0.1,
                ),
                Text(
                  'Categorie',
                  style:
                      TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
                ),
                Wrap(
                  spacing: 8.sp,
                  children: community.categories
                      .map((category) => Chip(
                            label: Text(
                                '${_getCategoryEmoji(category)} $category'),
                            backgroundColor: Palette.beige,
                            labelStyle: TextStyle(
                              color: Palette.black,
                              fontSize: 16.sp,
                            ),
                          ))
                      .toList(),
                ),
                SizedBox(height: constraints.maxHeight * 0.009),
                Text(
                  'Thread Preview',
                  style:
                      TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${community.threadIds.length} thread attivi nell\'ultimo periodo!',
                  style: TextStyle(fontSize: 16.sp),
                ),
                SizedBox(height: constraints.maxHeight * 0.009),
                CommunityLimitedThreadList(size: community.threadIds.length),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget PendingRequest() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.sp, horizontal: 24.sp),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: Colors.white,
        elevation: 8,
        child: Padding(
          padding: EdgeInsets.all(24.sp),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.hourglass_empty,
                color: Palette.black,
                size: 64,
              ),
              SizedBox(height: 16.sp),
              Text(
                textAlign: TextAlign.center,
                'Richiesta in attesa',
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: Palette.black,
                ),
              ),
              SizedBox(height: 16.sp),
              Text.rich(
                TextSpan(
                  text: 'La tua richiesta di accesso a ',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Palette.grey,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: widget.community.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Palette.black,
                      ),
                    ),
                    TextSpan(
                      text:
                          ' è in attesa di approvazione da parte dell\'amministratore.',
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: Palette.grey,
                      ),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24.sp),
              ElevatedButton.icon(
                onPressed: () async {
                  await communityController.cancelRequest(
                      widget.community.id, widget.userId);
                  Community community = await communityController
                      .getCommunityById(widget.community.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Richiesta annullata correttamente')),
                  );
                  setState(() {
                    widget.community = community;
                  });
                },
                icon: Icon(
                  Icons.cancel,
                  color: Palette.offWhite,
                ),
                label: Text(
                  'Annulla Richiesta',
                  style: TextStyle(
                    color: Palette.offWhite,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Palette.red,
                  padding:
                      EdgeInsets.symmetric(horizontal: 24.sp, vertical: 12.sp),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
