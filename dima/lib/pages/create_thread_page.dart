import 'package:dima/managers/controllers/community_controller.dart';
import 'package:dima/managers/controllers/thread_controller.dart';
import 'package:dima/managers/controllers/user_controller.dart';
import 'package:dima/managers/provider/navigation_provider.dart';
import 'package:dima/model/community.dart';
import 'package:dima/model/globals.dart';
import 'package:dima/model/thread.dart';
import 'package:dima/model/user.dart';
import 'package:dima/pages/community_homepage.dart';
import 'package:dima/pages/thread_chat_page.dart';
import 'package:dima/utils/palette.dart';
import 'package:dima/widgets/community/community_list_item_mini.dart';
import 'package:dima/widgets/thread/thread_create_title.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class CreateThreadPage extends StatefulWidget {
  final String articleId;

  const CreateThreadPage({Key? key, required this.articleId}) : super(key: key);

  @override
  _CreateThreadPageState createState() => _CreateThreadPageState();
}

class _CreateThreadPageState extends State<CreateThreadPage> {
  String communityId = "";
  late Community community;

  @override
  void dispose() {
    super.dispose();
  }

  void _createThread() {
    Navigator.pop(context);
  }

  Future<void> _navigateToThread(BuildContext context, String threadId) async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        Navigator.pop(context);
        Navigator.pop(context);

        Provider.of<NavigationProvider>(context, listen: false).setIndex(3);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CommunityHomePage(community: community),
          ),
        );
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ThreadChatPage(
              threadId: threadId,
              currentUserId: Globals.instance.userUid.toString(),
            ),
          ),
        );
      } catch (e) {
        print('Error during navigation: $e');
      }
    });
  }

  Future<String> _checkThread() async {
    ThreadController threadController = ThreadController();
    CommunityController communityController = CommunityController();
    Future<List<Thread>> futureThreads =
        threadController.getThreadsByCommunityId(communityId);
    List<Thread> threads = await futureThreads;
    community = await communityController.getCommunityById(communityId);

    for (Thread thread in threads) {
      if (thread.articleIds.isEmpty) continue;
      if (thread.articleIds.first == widget.articleId) {
        return thread.id;
      }
    }
    return "";
  }

  Future<List<Community>> _fetchCommunities() async {
    CommunityController communityController = CommunityController();
    return communityController
        .getCommunitiesByUserId(Globals.instance.userUid.toString());
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: Size(360, 690), minTextAdapt: true);
    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          title: Text(
            'Crea Nuovo Thread',
            style: TextStyle(color: Palette.red, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Palette.offWhite,
          foregroundColor: Palette.black),
      body: FutureBuilder<List<Community>>(
        future: _fetchCommunities(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              return Container(
                  color: Palette.offWhite,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding:  EdgeInsets.all(16.sp),
                        child: Text(
                          "Seleziona la Community in cui vuoi creare il Thread",
                          style: TextStyle(
                              fontSize: 20.0, fontWeight: FontWeight.bold
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Expanded(
                        child: snapshot.data == null ?  Center(
                          child: Text(
                            textAlign: TextAlign.center,
                            "Non sei ancora iscritto ad una community",
                            style: TextStyle(fontSize: 16.sp, color: Colors.black),
                        ),
                      )
                          : _listView(context, snapshot.data!),
                      ),
                    ],
                  ));
            } else if (snapshot.hasError) {
              return Center(child: Text(snapshot.error.toString()));
            } else {
              return Center(child: Text('Error'));
            }
          } else {
            return _loadingCircle(context);
          }
        },
      ),
    );
  }

  Widget _loadingCircle(BuildContext context) {
    return Container(
      color: Palette.offWhite,
      child: const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Palette.grey),
        ),
      ),
    );
  }

  Widget _listView(BuildContext context, List<Community> communities) {
    UserController userController = UserController();
    return ListView.builder(
      itemCount: communities.length,
      padding:  EdgeInsets.all(5.sp),
      itemBuilder: (context, index) {
        Community community = communities[index];
        return FutureBuilder<User>(
          future: userController.getUserById(community.adminId),
          builder: (context, adminSnapshot) {
            if (adminSnapshot.connectionState == ConnectionState.done) {
              if (adminSnapshot.hasData) {
                User admin = adminSnapshot.data!;
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () async {
                    communityId = community.id;
                    String threadId = await _checkThread();
                    if (threadId.isNotEmpty) {
                      _navigateToThread(context, threadId);
                    } else {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return ThreadCreateTitle(
                              communityId: communityId,
                              articleId: widget.articleId,
                            );
                          });
                    }
                  },
                  child: AbsorbPointer(
                      absorbing: true,
                      child: CommunityListItemMini(
                          community: community, admin: admin)),
                );
              } else if (adminSnapshot.hasError) {
                return Center(child: Text('Error: ${adminSnapshot.error}'));
              } else {
                return Center(child: Text('Error'));
              }
            } else {
              return _loadingCircle(context);
            }
          },
        );
      },
    );
  }
}
