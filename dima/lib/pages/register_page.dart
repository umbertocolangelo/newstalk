import 'package:dima/utils/alert_login_dialog.dart';
import 'package:dima/utils/palette.dart';
import 'package:dima/widgets/loginPage/register_fields.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:dima/utils/square_tile.dart';
import 'package:dima/managers/services/auth_service.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RegisterPage extends StatefulWidget {
  final Function()? onLoginTap;
  const RegisterPage({super.key, required this.onLoginTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // text editing controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  bool isEmailValid = true;
  bool isPasswordValid = true;
  String emailSnackBarText = 'Inserisci una email valida';
  String passwordSnackBarText = 'Le password non corrispodono';

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  // sign user up method
  void signUserUp() async {

    // try to create firebase account
    try {
      // check if passwords match
      if (passwordController.text == confirmPasswordController.text) {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: emailController.text, password: passwordController.text);
      } else {
        // show alert
        showDialog(
          context: context,
          builder: (context) =>
              AlertLoginDialog(text: 'Le password non corrispondono'),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (true) {
        //TODO specific exceptions

        if (e.code == 'channel-error') {
          showDialog(
            context: context,
            builder: (context) =>
                AlertLoginDialog(text: 'Riempi tutti i campi'),
          );
          return;
        }

        if (e.code == 'weak-password') {
          showDialog(
            context: context,
            builder: (context) => AlertLoginDialog(
                text: 'Inserisci una password di almeno 6 caratteri'),
          );
          return;
        }

        // General alert
        showDialog(
          context: context,
          builder: (context) =>
              AlertLoginDialog(text: 'Errore'),
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
                      SizedBox(height: constraints.maxHeight * 0.01),

                      // logo
                      Image.asset(
                        'assets/images/text.png',
                        width: constraints.maxWidth * 0.8,
                        height: constraints.maxHeight * 0.1,
                      ),

                      SizedBox(height: constraints.maxHeight * 0.02),

                      // lets create an account!
                      Text(
                        'Benvenuto! Iscriviti ora',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: constraints.maxHeight * 0.02,
                        ),
                      ),

                      SizedBox(height: constraints.maxHeight * 0.03),

                      // Text fields
                      RegisterFields(
                        emailController: emailController,
                        passwordController: passwordController,
                        confirmPasswordController: confirmPasswordController,
                        onSubmit: signUserUp,
                      ),

                      SizedBox(height: constraints.maxHeight * 0.03),

                      // or continue with
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: constraints.maxWidth * 0.05),
                        child: Row(
                          children: [
                            Expanded(
                              child: Divider(
                                thickness: 0.5,
                                color: Colors.grey[400],
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: constraints.maxWidth * 0.02),
                              child: Text(
                                'O continua con',
                                style: TextStyle(color: Colors.grey[700]),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                thickness: 0.5,
                                color: Colors.grey[400],
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: constraints.maxHeight * 0.02),

                      // google + apple sign in buttons
                      Padding(
                        padding: EdgeInsets.all(constraints.maxWidth * 0.05),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // google button
                            SquareTile(
                              imagePath: 'assets/images/google.png',
                              onTap: () => AuthService().signInWithGoogle(),
                            ),

                            SizedBox(width: constraints.maxWidth * 0.05),

                            // apple button
                            SquareTile(
                              imagePath: 'assets/images/apple.png',
                              onTap: () {}, // TODO ADD APPLE LOGIN
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: constraints.maxHeight * 0.015),

                      // not a member? register now
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Hai già un account?',
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                          SizedBox(width: constraints.maxWidth * 0.01),
                          GestureDetector(
                            onTap: widget.onLoginTap,
                            child: const Text(
                              'Accedi ora',
                              style: TextStyle(
                                color: Palette.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
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
