import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima/managers/controllers/comment_controller.dart';
import 'package:dima/managers/provider/navigation_provider.dart';
import 'package:dima/model/comment.dart';
import 'package:dima/pages/edit_community_page.dart';
import 'package:dima/utils/palette.dart';
import 'package:dima/widgets/community/community_header.dart';
import 'package:flutter/material.dart';
import 'package:dima/model/community.dart';
import 'package:dima/managers/controllers/community_controller.dart';
import 'package:dima/managers/controllers/thread_controller.dart';
import 'package:dima/managers/controllers/user_controller.dart';
import 'package:dima/model/thread.dart';
import 'package:dima/model/user.dart';
import 'package:dima/widgets/community/members_list.dart';
import 'package:dima/widgets/community/thread_list.dart';
import 'package:badges/badges.dart' as badges;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class CommunityAdminHomePage extends StatefulWidget {
  Community community;

  CommunityAdminHomePage({required this.community});

  @override
  _CommunityAdminHomePageState createState() => _CommunityAdminHomePageState();
}

class _CommunityAdminHomePageState extends State<CommunityAdminHomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final CommunityController _communityController = CommunityController();
  final UserController _userController = UserController();
  final ThreadController _threadController = ThreadController();
  final CommentController _commentController = CommentController();
  bool _isLoading = true;

  @override
  void initState() {
    _loadCommunity();
    super.initState();
  }

  Future<void> _loadCommunity() async {
    try {
      Community community =
          await _communityController.getCommunityById(widget.community.id);
      setState(() {
        widget.community = community;
        _isLoading = false;
      });
    } catch (e) {
      print("Errore durante il caricamento della community: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _approveRequest(String userId) async {
    try {
      await _communityController.approveRequest(widget.community.id, userId);
      await _communityController.addMemberToCommunity(
          widget.community.id, userId);
      await _userController.addCommunityToUser(userId, widget.community.id);
      await _loadCommunity(); // Ricarica la community con i dati aggiornati
      Navigator.pop(context);
      _showPendingRequests();
    } catch (e) {
      print("Errore durante l'approvazione della richiesta: $e");
    }
  }

  Future<void> _rejectRequest(String userId) async {
    try {
      await _communityController.rejectRequest(widget.community.id, userId);
      await _loadCommunity(); // Ricarica la community con i dati aggiornati
      Navigator.pop(context);
      _showPendingRequests();
    } catch (e) {
      print("Errore durante il rifiuto della richiesta: $e");
    }
  }

  Future<void> _showPendingRequests() async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16.sp),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Richieste in attesa di approvazione',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.01),
              Expanded(
                child: ListView.builder(
                  itemCount: widget.community.requestStatus.length,
                  itemBuilder: (context, index) {
                    String userId =
                        widget.community.requestStatus.keys.elementAt(index);
                    String status = widget.community.requestStatus[userId]!;
                    if (status == 'pending') {
                      return FutureBuilder<User>(
                        future: _userController.getUserById(userId),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            Container(
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
                          } else if (!snapshot.hasData) {
                            return Center(
                                child: Text('Nessun utente trovato.'));
                          }
                          User user = snapshot.data!;
                          return Column(
                            children: [
                              Padding(
                                padding: EdgeInsets.all(8.sp),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 30.sp,
                                          backgroundImage:
                                              AssetImage(user.profileImagePath),
                                        ),
                                        SizedBox(width: 15.sp),
                                        Column(
                                          children: [
                                            Text(
                                              user.username,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16.sp),
                                            ),
                                            Text(user.name,
                                                style:
                                                    TextStyle(fontSize: 14.sp)),
                                          ],
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Column(
                                          children: [
                                            IconButton(
                                              icon: Icon(Icons.check,
                                                  color: Palette.red),
                                              onPressed: () =>
                                                  _approveRequest(userId),
                                            ),
                                          ],
                                        ),
                                        SizedBox(width: 10.sp),
                                        Column(
                                          children: [
                                            IconButton(
                                              icon: Icon(Icons.close,
                                                  color: Palette.black),
                                              onPressed: () =>
                                                  _rejectRequest(userId),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                  height: MediaQuery.of(context).size.height *
                                      0.01),
                            ],
                          );
                        },
                      );
                    } else {
                      return SizedBox.shrink();
                    }
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _editCommunity() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => EditCommunityPage(
                communityId: widget.community.id,
              )),
    );
  }

  void _deleteCommunity(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Sei sicuro di voler procedere?"),
          content:
              Text("Questa azione eliminerà definitivamente la community."),
          actions: [
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _deleteConfirmed();
                      Navigator.of(context).pop();
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Palette.red),
                      foregroundColor: MaterialStateProperty.all(Colors.white),
                    ),
                    child: Text("Elimina Community"),
                  ),
                  SizedBox(width: 10.sp),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ButtonStyle(
                      side: MaterialStateProperty.all(
                          BorderSide(color: Colors.black)),
                      foregroundColor: MaterialStateProperty.all(Colors.black),
                    ),
                    child: Text("Annulla"),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteConfirmed() async {
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      List<User> userIds =
          await _userController.getUsersByCommunityId(widget.community.id);
      for (User user in userIds) {
        _userController.removeCommunityFromUser(user.id, widget.community.id);
      }
      _userController.removeCommunityFromUser(widget.community.adminId, widget.community.id);
      List<Thread> threads = await _threadController.getThreadsByCommunityId(widget.community.id);
      for (Thread thread in threads) {
        List<Comment> comments = await _commentController.getCommentsByThreadId(thread.id);
        for (Comment comment in comments) {
          _commentController.deleteComment(comment.id);
        }
        _userController.removeThreadFromUser(thread.authorId, thread.id);
        _threadController.deleteThread(thread.id);
      }
      _communityController.deleteCommunity(widget.community.id);
    }).then((_) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Community eliminata con successo')),
      );
      Provider.of<NavigationProvider>(context, listen: false).setIndex(3);
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Errore nella creazione della community: $error')),
      );
    });
  }

  Future<void> _onRefresh() async {
    await _loadCommunity();
  }

  @override
  Widget build(BuildContext context) {
        ScreenUtil.init(context, designSize: Size(360, 690), minTextAdapt: true);

    int pendingRequestsCount = widget.community.requestStatus.values
        .where((status) => status == 'pending')
        .length;

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text(widget.community.name,
              style: TextStyle(
                  color: Palette.red,
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold)),
          backgroundColor: Palette.offWhite,
          foregroundColor: Palette.black,
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(Icons.menu),
              onPressed: () {
                _scaffoldKey.currentState?.openEndDrawer();
              },
            ),
          ],
        ),
        body: _isLoading
            ? Container(
                color: Palette.offWhite,
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Palette.grey),
                  ),
                ),
              )
            : Container(
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

                      // Description
                      Text(
                        'Descrizione',
                        textAlign: TextAlign.start,
                        style: TextStyle(
                            fontSize: 20.sp, fontWeight: FontWeight.bold),
                      ),
                      // Bio
                      Text(
                        widget.community.bio,
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          color: Palette.black,
                          fontSize: 16.sp, // Adjust font size as needed
                          fontWeight: FontWeight.normal,
                        ),
                      ),

                      SizedBox(height: constraints.maxHeight * 0.01),

                      // Pending requests
                      widget.community.type == "private" ? Center(
                        child: badges.Badge(
                          badgeContent: Text(
                            '$pendingRequestsCount',
                            style: TextStyle(color: Colors.white),
                          ),
                          child: IconButton(
                            icon: Icon(Icons.person_add, size: 32),
                            onPressed: _showPendingRequests,
                          ),
                        ),
                      ) : SizedBox(height: 0),

                      widget.community.type == "private" ? SizedBox(height: constraints.maxHeight * 0.01)
                       : SizedBox(height: 0),

                      // Members
                      Padding(
                        padding: EdgeInsets.all(0),
                        child: Text(
                          'Membri',
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      FutureBuilder<List<User>>(
                        future: _userController
                            .getUsersByCommunityId(widget.community.id),
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

                      SizedBox(height: constraints.maxHeight * 0.01),
                      // Recent threads
                      Padding(
                        padding: EdgeInsets.all(0),
                        child: Text(
                          'Threads recenti',
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      FutureBuilder<List<Thread>>(
                        future: _threadController
                            .getThreadsByCommunityId(widget.community.id),
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
                                child: Text('Nessun thread trovato.', style: TextStyle(fontSize: 16.sp),));
                          } else {
                            return CommunityThreadList(threads: snapshot.data!);
                          }
                        },
                      ),
                      SizedBox(height: constraints.maxHeight * 0.01),
                      // Most popular threads
                      Padding(
                        padding: EdgeInsets.all(0),
                        child: Text(
                          'Threads popolari',
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      FutureBuilder<List<Thread>>(
                        future: _threadController
                            .getThreadsByCommunityId(widget.community.id),
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
                                child: Text('Nessun thread trovato.',  style: TextStyle(fontSize: 16.sp),));
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
        endDrawer: Drawer(
          backgroundColor: Palette.offWhite,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(16.sp, 50.sp, 16.sp, 8.sp),
                child: Text(
                  'Impostazioni',
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // Divider
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.sp),
                child: Divider(color: Colors.black),
              ),
              Expanded(
                child: ListView(
                  children: [
                    // Settings button
                    Padding(
                      padding: EdgeInsets.all(8.sp),
                      child: ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.white),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: Colors.black, width: 1),
                            ),
                          ),
                        ),
                        onPressed: _editCommunity,
                        child: Text(
                          'Modifica Community',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ),

                    // Delete community button
                    Padding(
                      padding: EdgeInsets.all(8.sp),
                      child: ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.red),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        onPressed: () {
                          _deleteCommunity(context);
                        },
                        child: Text(
                          'Elimina Community',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Thread> _orderThreadsByUpvotes(List<Thread> threads) {
    if (threads.every((element) => element.upvotes == 0)) return threads;
    threads.sort((a, b) => b.upvotes.compareTo(a.upvotes));
    return threads;
  }
}
