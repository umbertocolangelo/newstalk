import 'package:dima/managers/controllers/thread_controller.dart';
import 'package:dima/model/thread.dart';
import 'package:dima/utils/animated_dialog.dart';
import 'package:dima/utils/palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ThreadModifyTitle extends StatefulWidget {
  final String threadId;

  ThreadModifyTitle({required this.threadId});

  @override
  State<ThreadModifyTitle> createState() => _ThreadModifyTitleState();
}

class _ThreadModifyTitleState extends State<ThreadModifyTitle> {
  final TextEditingController titleController = TextEditingController();
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
              'Inserisci il nome del Thread',
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
            : _modifyThread(context);
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
    RegExp regex = RegExp(
        r'^(?! )[a-zA-Z0-9,._\s]*(?<! )(?=.*[a-zA-Z])[a-zA-Z0-9,._\s]*$');
    if (title.isEmpty) {
      setState(() {
        titleErrorText = "Inserisci un nome valido";
        isTitleValid = false;
      });
      return;
    }
    if (!regex.hasMatch(title)) {
      setState(() {
        titleErrorText = "Solo lettere, numeri, '.' e '_' sono ammessi";
        isTitleValid = false;
      });
      return;
    }
    setState(() {
      titleErrorText = "";
      isTitleValid = true;
    });
  }

  void _modifyThread(BuildContext context) async {
    ThreadController threadController = ThreadController();

    // Retrieve thread
    Thread thread = await threadController.getThreadById(widget.threadId);

    Map<String, dynamic> newThread = thread.toJson();

    newThread.update("title", (value) => titleController.text);

    // Update thread
    await threadController.updateThread(widget.threadId, newThread).then((_) {
      Navigator.pop(context); // pop popup
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Titolo modificato con successo')),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Errore durante la modifica del Thread: $error')),
      );
    });
  }
}
