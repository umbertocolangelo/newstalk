import 'package:dima/managers/controllers/user_controller.dart';
import 'package:dima/pages/password_reset_page.dart';
import 'package:dima/utils/palette.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RegisterFields extends StatefulWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final VoidCallback onSubmit;

  const RegisterFields({
    Key? key,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.onSubmit,
  }) : super(key: key);

  @override
  _RegisterFieldsState createState() => _RegisterFieldsState();
}

class _RegisterFieldsState extends State<RegisterFields> {
  String emailErrorText = "";
  String passwordErrorText = "";
  String confirmPasswordErrorText = "";
  UserController userController = UserController();
  Color emailBorderColor = Colors.black;
  Color passwordBorderColor = Colors.black;
  Color confirmPasswordBorderColor = Colors.black;
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;
  bool _isEmailValid = false;
  bool _isPasswordValid = false;
  bool _isConfirmPasswordValid = false;
  bool get _isFormValid =>
      _isEmailValid && _isPasswordValid && _isConfirmPasswordValid;

  // returns true if email is correctly formatted
  bool checkEmail(String newEmail) {
    String pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regExp = RegExp(pattern);
    if (newEmail.isEmpty || !regExp.hasMatch(newEmail)) {
      setState(() {
        emailBorderColor = Palette.red;
        emailErrorText = "Inserisci un indirizzo email valido";
        _isEmailValid = false;
      });
      return false;
    } else {
      setState(() {
        emailBorderColor = Palette.black;
        emailErrorText = "";
        _isEmailValid = true;
      });
      return true;
    }
  }

  // returns true if password is correctly formatted
  bool checkPassword(String newPassword) {
    if (newPassword.isEmpty) {
      setState(() {
        passwordErrorText = "Inserisci una password";
        _isPasswordValid = false;
      });
      return false;
    } else if (newPassword.length < 6) {
      setState(() {
        passwordErrorText = "Inserisci almeno 6 caratteri";
        _isPasswordValid = false;
      });
      return true;
    } else {
      setState(() {
        passwordErrorText = "";
        _isPasswordValid = true;
      });
      return true;
    }
  }

  // returns true if password is correctly formatted and matches
  bool checkConfirmPassword(String confirmPassword) {
    if (confirmPassword.isEmpty) {
      setState(() {
        confirmPasswordErrorText = "Inserisci nuovamente la password";
        _isConfirmPasswordValid = false;
      });
      return false;
    } else if (widget.passwordController.text != confirmPassword) {
      setState(() {
        confirmPasswordErrorText = "Le password non corrispondono";
        _isConfirmPasswordValid = false;
      });
      return false;
    } else {
      setState(() {
        confirmPasswordErrorText = "";
        _isConfirmPasswordValid = true;
      });
      return true;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          // Close keyboard when clicking out of inputs
          FocusScope.of(context).unfocus();
        },
        child: Column(
        children: [
          // email field
          buildEmailField(),

          // password field
          buildPasswordField(),

          // confirm password field
          buildConfirmPasswordField(),

          // forgot password?
          Padding(
            padding:  EdgeInsets.symmetric(horizontal: 25.sp),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () {
                    // Verifica che PasswordResetPage sia correttamente importato
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => PasswordResetPage(),
                      ),
                    );
                  },
                  child: Text(
                    'Password dimenticata?',
                    style: TextStyle(
                      color: Colors.grey[600],
                      //decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Confirm button
          SizedBox(height: 20.sp),
          ConfirmButton(),
        ],
      )
    );
  }

  Widget buildEmailField() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 8.sp),
      child: TextField(
        controller: widget.emailController,
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
          prefixIcon: Icon(Icons.account_circle),
          suffixIcon: emailErrorText.isNotEmpty
              ? Tooltip(
                  message: emailErrorText,
                  child: Icon(Icons.error, color: emailBorderColor),
                )
              : null,
        ),
        onChanged: checkEmail,
        onTap: () {
          if (emailErrorText.isEmpty) {
            setState(() {
              emailBorderColor = Colors.black;
            });
          }
        },
        onEditingComplete: () {
          FocusScope.of(context).unfocus();
          if (emailErrorText.isEmpty) {
            setState(() {
              emailBorderColor = Colors.black;
            });
          }
        },
      ),
    );
  }

  Widget buildPasswordField() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 8.sp),
      child: TextField(
        controller: widget.passwordController,
        obscureText: !_passwordVisible,
        decoration: InputDecoration(
          labelText:
              passwordErrorText.isNotEmpty ? passwordErrorText : "Password",
          labelStyle: TextStyle(
              color: passwordErrorText != "" ? Palette.red : Palette.black),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(
                color: passwordErrorText != "" ? Palette.red : Palette.black),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(
                color: passwordErrorText != "" ? Palette.red : Palette.black),
          ),
          prefixIcon: IconButton(
            icon: Icon(
              // Based on passwordVisible state choose the icon
              _passwordVisible ? Icons.visibility : Icons.visibility_off,
            ),
            onPressed: () {
              setState(() {
                _passwordVisible = !_passwordVisible;
              });
            },
          ),
          suffixIcon: passwordErrorText.isNotEmpty
              ? Tooltip(
                  message: passwordErrorText,
                  child: Icon(Icons.error, color: Palette.red),
                )
              : null,
        ),
        style: TextStyle(fontSize: 16.sp, color: Palette.black),
        onChanged: checkPassword,
      ),
    );
  }

  Widget buildConfirmPasswordField() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 8.sp),
      child: TextField(
        controller: widget.confirmPasswordController,
        obscureText: !_confirmPasswordVisible,
        decoration: InputDecoration(
          labelText: confirmPasswordErrorText.isNotEmpty
              ? confirmPasswordErrorText
              : "Conferma Password",
          labelStyle: TextStyle(
              color:
                  confirmPasswordErrorText != "" ? Palette.red : Palette.black),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(
                color:
                    confirmPasswordErrorText != "" ? Palette.red : Palette.black),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(
                color:
                    confirmPasswordErrorText != "" ? Palette.red : Palette.black),
          ),
          prefixIcon: IconButton(
            icon: Icon(
              // Based on passwordVisible state choose the icon
              _confirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
            ),
            onPressed: () {
              setState(() {
                _confirmPasswordVisible = !_confirmPasswordVisible;
              });
            },
          ),
          suffixIcon: confirmPasswordErrorText.isNotEmpty
              ? Tooltip(
                  message: confirmPasswordErrorText,
                  child: Icon(Icons.error, color: Palette.red),
                )
              : null,
        ),
        style: TextStyle(fontSize: 16.sp, color: Palette.black),
        onChanged: checkConfirmPassword,
      ),
    );
  }

  Widget ConfirmButton() {
    return ElevatedButton(
      onPressed: _isFormValid ? widget.onSubmit : null,
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(
            // ignore: unnecessary_null_comparison
            _isFormValid ? Palette.red : Palette.grey),
        elevation: MaterialStateProperty.all(_isFormValid ? 5.0 : 0.0),
        padding: MaterialStateProperty.all(
            EdgeInsets.symmetric(vertical: 16.sp, horizontal: 64.sp)),
      ),
      child: Text(
        "Registrati",
        style: TextStyle(color: Colors.white, fontSize: 16.sp),
      ),
    );
  }
}
