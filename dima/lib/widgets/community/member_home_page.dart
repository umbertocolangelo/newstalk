import 'package:dima/managers/controllers/community_controller.dart';
import 'package:dima/utils/palette.dart';
import 'package:flutter/material.dart';
import 'package:dima/managers/controllers/thread_controller.dart';
import 'package:dima/managers/controllers/user_controller.dart';
import 'package:dima/model/community.dart';
import 'package:dima/model/thread.dart';
import 'package:dima/model/user.dart';
import 'package:dima/widgets/community/members_list.dart';
import 'package:dima/widgets/community/thread_list.dart';
import 'package:dima/widgets/community/community_header.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MemberHomePage extends StatefulWidget {
  final Community community;

  const MemberHomePage({
    Key? key,
    required this.community,
  }) : super(key: key);

  @override
  _MemberHomePageState createState() => _MemberHomePageState();
}

final List<Map<String, String>> _categories = [
  {'emoji': '🌐', 'name': 'Attualità'},
  {'emoji': '🏅', 'name': 'Sport'},
  {'emoji': '🎬', 'name': 'Intrattenimento'},
  {'emoji': '💪', 'name': 'Salute'},
  {'emoji': '💼', 'name': 'Economia'},
  {'emoji': '💻', 'name': 'Tecnologia'}
];

String _getCategoryEmoji(String categoryName) {
  return _categories.firstWhere((category) => category['name'] == categoryName,
      orElse: () => {'emoji': '❓'})['emoji']!;
}

class _MemberHomePageState extends State<MemberHomePage> {
  final UserController _userController = UserController();
  final ThreadController _threadController = ThreadController();
  final CommunityController _communityController = CommunityController();
  late Community community;

  @override
  void initState() {
    _loadCommunity();
    super.initState();
  }

  Future<void> _loadCommunity() async {
    try {
      Community loadedCommunity =
          await _communityController.getCommunityById(widget.community.id);
      community = loadedCommunity;
    } catch (e) {
      print("Errore durante il caricamento della community: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _loadCommunity(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Errore: ${snapshot.error}')),
          );
        } else {
          return Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: Text(
                community.name,
                style: TextStyle(
                  color: Palette.red,
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: Palette.offWhite,
              foregroundColor: Palette.black,
            ),
            body: RefreshIndicator(
              onRefresh: _refreshCommunity,
              child: Container(
                color: Palette.offWhite,
                child: LayoutBuilder(
                  builder: (context, constraints) => ListView(
                    padding: EdgeInsets.all(16.sp),
                    children: [
                      CommunityHeader(
                        backgroundImageUrl:
                            widget.community.backgroundImagePath,
                        profileImageUrl: widget.community.profileImagePath,
                        title: widget.community.name,
                        height: constraints.maxHeight * 0.5,
                        width: constraints.maxWidth,
                      ),
                      SizedBox(height: constraints.maxHeight * 0.01),
                      Text(
                        'Descrizione',
                        textAlign: TextAlign.start,
                        style: TextStyle(
                            color: Palette.black,
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        community.bio,
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          color: Palette.black,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      SizedBox(height: constraints.maxHeight * 0.01),
                      Padding(
                        padding: EdgeInsets.all(0),
                        child: Text(
                          'Membri',
                          style: TextStyle(
                            color: Palette.black,
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(height: constraints.maxHeight * 0.005),
                      FutureBuilder<List<User>>(
                        future:
                            _userController.getUsersByCommunityId(community.id),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Center(
                                child: Text('Errore: ${snapshot.error}'));
                          } else if (!snapshot.hasData ||
                              snapshot.data!.isEmpty) {
                            return Center(
                                child: Text('Nessun membro trovato.'));
                          } else {
                            return CommunityMembersList(
                                members: snapshot.data!);
                          }
                        },
                      ),
                      Text(
                        'Categorie',
                        style: TextStyle(
                            fontSize: 20.0, fontWeight: FontWeight.bold),
                      ),
                      Wrap(
                        spacing: 8.0,
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
                      SizedBox(height: constraints.maxHeight * 0.01),
                      Padding(
                        padding: EdgeInsets.all(0),
                        child: Text(
                          'Thread recenti',
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      FutureBuilder<List<Thread>>(
                        future: _threadController
                            .getThreadsByCommunityId(community.id),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Center(
                                child: Text('Errore: ${snapshot.error}'));
                          } else if (!snapshot.hasData ||
                              snapshot.data!.isEmpty) {
                            return Center(
                                child: Text('Nessun thread trovato.'));
                          } else {
                            return CommunityThreadList(threads: snapshot.data!);
                          }
                        },
                      ),
                      SizedBox(height: constraints.maxHeight * 0.01),
                      Padding(
                        padding: EdgeInsets.all(0),
                        child: Text(
                          'Thread popolari',
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      FutureBuilder<List<Thread>>(
                        future: _threadController
                            .getThreadsByCommunityId(community.id),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Container(
                              color: Palette.offWhite,
                              child: const Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Palette.grey),
                                ),
                              ),
                            );
                          } else if (snapshot.hasError) {
                            return Center(
                                child: Text('Errore: ${snapshot.error}'));
                          } else if (!snapshot.hasData ||
                              snapshot.data!.isEmpty) {
                            return Center(
                                child: Text('Nessun thread trovato.'));
                          } else {
                            return CommunityThreadList(
                              threads: _orderThreadsByUpvotes(snapshot.data!),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }
      },
    );
  }

  Future<void> _refreshCommunity() async {
    await _loadCommunity().then((value) => setState(() {}));
  }

  List<Thread> _orderThreadsByUpvotes(List<Thread> threads) {
    if (threads.every((element) => element.upvotes == 0)) return threads;
    threads.sort((a, b) => b.upvotes.compareTo(a.upvotes));
    return threads;
  }
}
