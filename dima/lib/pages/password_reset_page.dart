import 'package:dima/utils/palette.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PasswordResetPage extends StatefulWidget {
  @override
  _PasswordResetPageState createState() => _PasswordResetPageState();
}

class _PasswordResetPageState extends State<PasswordResetPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  String emailErrorText = "";
  Color emailBorderColor = Colors.black;
  bool _isEmailValid = false;

  bool checkEmail(String email) {
    String pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regExp = RegExp(pattern);
    if (email.isEmpty || !regExp.hasMatch(email)) {
      setState(() {
        emailBorderColor = Palette.red;
        emailErrorText = "Inserisci un indirizzo email valido";
        _isEmailValid = false;
      });
      return false;
    } else {
      setState(() {
        emailBorderColor = Palette.red;
        emailErrorText = "";
        _isEmailValid = true;
      });
      return true;
    }
  }

  void _resetPassword() async {
    String email = _emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Per favore inserisci un indirizzo email')),
      );
      return;
    }

    try {
      await _auth.sendPasswordResetEmail(email: email);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Email di recupero password inviata!')),
      );
    } on FirebaseAuthException catch (e) {
      String message = '';
      switch (e.code) {
        case 'invalid-email':
          message = 'Indirizzo non valido';
          break;
        case 'user-not-found':
          message = 'Indirizzo non valido';
          break;
        default:
          message = 'Si è verificato un errore';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: Size(360, 690), minTextAdapt: true);
    return Scaffold(
      backgroundColor: Palette.offWhite,
      appBar: AppBar(
        title: Text('Recupero Password', style: TextStyle(color: Palette.red, fontSize: 24.sp, fontWeight: FontWeight.bold)),
        backgroundColor: Palette.offWhite,
        foregroundColor: Palette.black,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.sp),
        child: Column(
          children: [
            buildEmailField(),
            SizedBox(height: 20.sp),
            ConfirmButton(),
          ],
        ),
      ),
    );
  }

  Widget buildEmailField() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 8.sp),
      child: TextField(
        controller: _emailController,
        decoration: InputDecoration(
          labelText: emailErrorText.isNotEmpty ? emailErrorText : "Email",
          labelStyle: TextStyle(color: emailBorderColor),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(color: emailBorderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(color: emailBorderColor),
          ),
          prefixIcon: Icon(Icons.email),
        ),
        onChanged: checkEmail,
        onTap: () {
          if (emailErrorText.isEmpty) {
            setState(() {
              emailBorderColor = Palette.black;
            });
          }
        },
        onEditingComplete: () {
          FocusScope.of(context).unfocus();
          if (emailErrorText.isEmpty) {
            setState(() {
              emailBorderColor = Palette.black;
            });
          }
        },
      ),
    );
  }

  Widget ConfirmButton() {
    return ElevatedButton(
      onPressed: _isEmailValid ? _resetPassword : null,
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(
            _isEmailValid ? Colors.red : Palette.grey),
        elevation: MaterialStateProperty.all(_isEmailValid ? 5.0 : 0.0),
        padding: MaterialStateProperty.all(
          EdgeInsets.symmetric(vertical: 16.0, horizontal: 64.0),
        ),
      ),
      child: Text(
        "Invia",
        style: TextStyle(color: Palette.offWhite, fontSize: 16),
      ),
    );
  }
}
