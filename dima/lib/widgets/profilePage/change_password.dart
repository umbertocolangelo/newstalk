import 'package:dima/utils/palette.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ChangePassword extends StatefulWidget {
  @override
  _ChangePasswordState createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  
  String _currentPasswordError = '';
  String _newPasswordError = '';
  String _confirmPasswordError = '';
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool get _isFormValid {
    return _newPasswordController.text.isNotEmpty &&
           _newPasswordController.text.length >= 6 &&
           _newPasswordController.text == _confirmPasswordController.text;
  }

  Future<void> _updatePassword() async {
    try {
      // User's current authenticated user
      User? user = _auth.currentUser;

      if (user == null) {
        throw FirebaseAuthException(code: 'user-not-found', message: 'User not found');
      }

      // Re-authenticate the user
      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: _currentPasswordController.text,
      );

      await user.reauthenticateWithCredential(credential);

      // Update the password
      await user.updatePassword(_newPasswordController.text);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Password aggiornata con successo!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Errore: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.transparent,
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final double horizontalPadding = constraints.maxWidth * 0.05;
          final double verticalSpacing = constraints.maxHeight * 0.05;
          final double buttonHeight = 48.0;

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: verticalSpacing),

                  TextField(
                    controller: _currentPasswordController,
                    obscureText: !_isPasswordVisible,
                    decoration: InputDecoration(
                      labelText: 'Password Attuale',
                      errorText: _currentPasswordError.isNotEmpty ? _currentPasswordError : null,
                      labelStyle: TextStyle(color: _currentPasswordError.isNotEmpty ? Palette.red : Palette.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(color: _currentPasswordError.isNotEmpty ? Palette.red : Palette.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(color: _currentPasswordError.isNotEmpty ? Palette.red : Palette.grey),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _currentPasswordError = value.isEmpty ? 'Inserisci la password attuale' : '';
                      });
                    },
                    style: TextStyle(fontSize: 16.sp),
                  ),
                  
                  SizedBox(height: verticalSpacing),

                  TextField(
                    controller: _newPasswordController,
                    obscureText: !_isPasswordVisible,
                    decoration: InputDecoration(
                      labelText: 'Nuova Password',
                      errorText: _newPasswordError.isNotEmpty ? _newPasswordError : null,
                      labelStyle: TextStyle(color: _newPasswordError.isNotEmpty ? Palette.red : Palette.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(color: _newPasswordError.isNotEmpty ? Palette.red : Palette.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(color: _newPasswordError.isNotEmpty ? Palette.red : Palette.grey),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _newPasswordError = value.isEmpty || value.length < 6
                            ? 'La password deve contenere almeno 6 caratteri'
                            : '';
                        _confirmPasswordError = value != _newPasswordController.text
                            ? 'Le password non corrispondono'
                            : '';
                      });
                    },
                    style: TextStyle(fontSize: 16.sp),
                  ),

                  SizedBox(height: verticalSpacing),

                  TextField(
                    controller: _confirmPasswordController,
                    obscureText: !_isConfirmPasswordVisible,
                    decoration: InputDecoration(
                      labelText: 'Conferma Nuova Password',
                      errorText: _confirmPasswordError.isNotEmpty ? _confirmPasswordError : null,
                      labelStyle: TextStyle(color: _confirmPasswordError.isNotEmpty ? Palette.red : Palette.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(color: _confirmPasswordError.isNotEmpty ? Palette.red : Palette.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(color: _confirmPasswordError.isNotEmpty ? Palette.red : Palette.grey),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                          });
                        },
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _confirmPasswordError = value != _newPasswordController.text
                            ? 'Le password non corrispondono'
                            : '';
                        _newPasswordError = value.isEmpty || value.length < 6
                            ? 'La password deve contenere almeno 6 caratteri'
                            : '';
                      });
                    },
                    style: TextStyle(fontSize: 16.sp),
                  ),

                  SizedBox(height: verticalSpacing),

                  ElevatedButton(
                    onPressed: _isFormValid ? _updatePassword : null,
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                          _isFormValid ? Colors.green : Palette.grey),
                      elevation: MaterialStateProperty.all(_isFormValid ? 5.0 : 0.0),
                      minimumSize: MaterialStateProperty.all(Size(double.infinity, buttonHeight)),
                      padding: MaterialStateProperty.all(EdgeInsets.symmetric(vertical: 16.sp)),
                    ),
                    child: Text(
                      "Aggiorna Password",
                      style: TextStyle(color: Colors.white, fontSize: 16.sp),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
