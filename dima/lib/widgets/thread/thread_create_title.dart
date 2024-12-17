import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima/managers/controllers/community_controller.dart';
import 'package:dima/managers/controllers/thread_controller.dart';
import 'package:dima/managers/controllers/user_controller.dart';
import 'package:dima/managers/provider/navigation_provider.dart';
import 'package:dima/model/community.dart';
import 'package:dima/model/globals.dart';
import 'package:dima/pages/community_homepage.dart';
import 'package:dima/pages/thread_chat_page.dart';
import 'package:dima/utils/animated_dialog.dart';
import 'package:dima/utils/palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class ThreadCreateTitle extends StatefulWidget {
  final String communityId;
  final String articleId;

  ThreadCreateTitle({required this.communityId, required this.articleId});

  @override
  State<ThreadCreateTitle> createState() => _ThreadCreateTitleState();
}

class _ThreadCreateTitleState extends State<ThreadCreateTitle> {
  final TextEditingController titleController = TextEditingController();
  final String threadId = Uuid().v4();
  bool isTitleValid = true;
  String titleErrorText = "";

  @override
  Widget build(BuildContext context) {
      ScreenUtil.init(context, designSize: Size(360, 690), minTextAdapt: true);
    return AnimatedDialog(
      child: Container(
        width: 300.sp,
        padding: EdgeInsets.all(20.sp),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Inserisci il nome del nuovo Thread',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20.sp),
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: titleErrorText,
                labelStyle:
                    TextStyle(color: isTitleValid ? Colors.grey : Colors.red),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(
                      color: isTitleValid ? Colors.grey : Colors.red),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(
                      color: isTitleValid ? Colors.grey : Colors.red),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: checkTitle,
            ),
            SizedBox(height: 20.sp),
            ConfirmButton(context)
          ],
        ),
      ),
    );
  }

  Widget ConfirmButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        !isTitleValid || titleController.text.isEmpty
            ? null
            : _createThread(context);
      },
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(
          !isTitleValid || titleController.text.isEmpty
              ? Palette.grey
              : Colors.green,
        ),
        elevation: MaterialStateProperty.all(isTitleValid ? 5.0 : 0.0),
        padding: MaterialStateProperty.all(
          EdgeInsets.symmetric(vertical: 16.sp, horizontal: 16.sp),
        ),
      ),
      child: Text(
        "Conferma",
        style: TextStyle(color: Colors.white, fontSize: 16.sp),
      ),
    );
  }

  void checkTitle(String title) async {
    if (title.isEmpty) {
      setState(() {
        titleErrorText = "Inserisci un nome valido";
        isTitleValid = false;
      });
      return;
    }
    setState(() {
      titleErrorText = "";
      isTitleValid = true;
    });
  }

  void _createThread(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) {
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

    ThreadController threadController = ThreadController();
    CommunityController communityController = CommunityController();
    UserController userController = UserController();

    Community community =
        await communityController.getCommunityById(widget.communityId);

    Map<String, dynamic> newThread = {
      "id": threadId,
      "articleIds": [widget.articleId],
      "authorId": Globals.instance.userUid.toString(),
      "participantIds": [Globals.instance.userUid.toString()],
      "communityId": widget.communityId,
      "title": titleController.text,
      "upvotes": 0,
      "downvotes": 0,
      "commentIds": [],
      "time": Timestamp.now(),
    };

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      // Create thread
      await threadController.addThread(newThread);
      await communityController.addThreadToCommunity(
          widget.communityId, threadId);
      await userController.addThreadToUser(
          Globals.instance.userUid.toString(), threadId);
    }).then((_) {
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Thread creato con successo')),
      );

      // Navigate to new thread
      Navigator.pop(context);
      Navigator.pop(context);
      Provider.of<NavigationProvider>(context, listen: false).setIndex(3);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CommunityHomePage(community: community),
        ),
      );
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ThreadChatPage(
            threadId: threadId,
            currentUserId: Globals.instance.userUid.toString(),
          ),
        ),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Errore durante la creazione del Thread: $error')),
      );
    });
  }
}
