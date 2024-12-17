import 'package:dima/managers/services/auth_service.dart';
import 'package:dima/utils/alert_login_dialog.dart';
import 'package:dima/utils/palette.dart';
import 'package:dima/widgets/loginPage/login_fields.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:dima/utils/square_tile.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LoginPage extends StatefulWidget {
  final Function()? onRegisterTap;
  const LoginPage({super.key, required this.onRegisterTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // text editing controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // sign user in method
  void signUserIn() async {

    // try firebase sign in
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text, password: passwordController.text);
    } on FirebaseAuthException {
      if (true) {
        // Show alert
        showDialog(
          context: context,
          builder: (context) =>
              AlertLoginDialog(text: 'Credenziali errate'),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: Size(360, 690), minTextAdapt: true);
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: Palette.offWhite
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: constraints.maxHeight * 0.03),

                      // logo
                      Image.asset(
                        'assets/images/text.png',
                        width: constraints.maxWidth * 0.8,
                        height: constraints.maxHeight * 0.1,
                      ),

                      SizedBox(height: constraints.maxHeight * 0.03),

                      // welcome back, you've been missed!
                      Text(
                        'Bentornato! Accedi per continuare',
                        style: TextStyle(
                          color: Palette.grey.withOpacity(0.8),
                          fontSize: constraints.maxHeight * 0.02,
                        ),
                      ),

                      SizedBox(height: constraints.maxHeight * 0.03),

                      // Input fields
                      LoginFields(
                        emailController: emailController,
                        passwordController: passwordController,
                        onSubmit: signUserIn,
                      ),

                      SizedBox(height: constraints.maxHeight * 0.04),

                      // or continue with
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: constraints.maxWidth * 0.05),
                        child: Row(
                          children: [
                            Expanded(
                              child: Divider(
                                thickness: 0.5,
                                color: Palette.grey,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: constraints.maxWidth * 0.02),
                              child: Text(
                                'Oppure continua con',
                                style: TextStyle(color: Palette.grey),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                thickness: 0.5,
                                color: Palette.grey,
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: constraints.maxHeight * 0.04),

                      // google + apple sign in buttons
                      Padding(
                        padding: EdgeInsets.all(constraints.maxWidth * 0.05),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // google button
                            SquareTile(
                                imagePath: 'assets/images/google.png',
                                onTap: () => AuthService().signInWithGoogle()),

                            SizedBox(width: constraints.maxWidth * 0.05),

                            // apple button
                            SquareTile(
                              imagePath: 'assets/images/apple.png',
                              onTap: () {}, // TODO ADD APPLE LOGIN
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: constraints.maxHeight * 0.03),

                      // not a member? register now
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Non sei un membro?',
                            style:
                                TextStyle(color: Palette.grey.withOpacity(0.8)),
                          ),
                          SizedBox(width: constraints.maxWidth * 0.01),
                          GestureDetector(
                            onTap: widget.onRegisterTap,
                            child: const Text(
                              'Registrati ora',
                              style: TextStyle(
                                color: Palette.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
