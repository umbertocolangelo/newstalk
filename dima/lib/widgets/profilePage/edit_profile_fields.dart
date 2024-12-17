import 'dart:async';
import 'package:dima/managers/controllers/user_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EditProfileFields extends StatefulWidget {
  final TextEditingController usernameController;
  final TextEditingController nameController;
  final TextEditingController bioController;
  final String username; // current username of user
  final VoidCallback onSubmit;

  const EditProfileFields({
    Key? key,
    required this.username,
    required this.nameController,
    required this.usernameController,
    required this.bioController,
    required this.onSubmit,
  }) : super(key: key);

  @override
  _EditProfileFieldsState createState() => _EditProfileFieldsState();
}

class _EditProfileFieldsState extends State<EditProfileFields> {
  String usernameErrorText =
      ""; // with empty string, icon will not be shown, with " ", green icon else error
  String nameErrorText = "";
  UserController userController = UserController();
  Color usernameBorderColor =
      Colors.grey; // used to signal username availability and format
  IconData usernameIcon = Icons.check; // icon to show
  Timer? _debounce;

  bool _isUsernameValid = false;
  bool _isNameValid = false;
  bool _isBioValid = true;
  bool get _isFormValid => _isUsernameValid && _isNameValid && _isBioValid;

  void checkUsername(String newUsername) async {
    // Check if username only contains letters, numbers, . or _
    RegExp regex = RegExp(r'^[a-zA-Z0-9._]+$');
    if (newUsername.isEmpty) {
      setState(() {
        usernameBorderColor = Colors.red;
        usernameErrorText = "Inserisci un username";
        usernameIcon = Icons.error;
        _isUsernameValid = false;
      });
      return;
    }
    if (!regex.hasMatch(newUsername)) {
      setState(() {
        usernameBorderColor = Colors.red;
        usernameErrorText = "Inserisci lettere, numeri, '.' e '_'";
        usernameIcon = Icons.error;
        _isUsernameValid = false;
      });
    } else {
      // if username is different from previous one, check for its availability
      if (widget.username != newUsername) {
        bool available = !(await userController.doesUsernameExist(newUsername));
        setState(() {
          usernameBorderColor = available ? Colors.green : Colors.red;
          usernameIcon = available ? Icons.check_box_rounded : Icons.error;
          usernameErrorText = available ? " " : "Username no disponibile";
          _isUsernameValid = available;
        });
      } else {
        setState(() {
          usernameBorderColor = Colors.grey;
          usernameErrorText = "";
          _isUsernameValid = true;
        });
      }
    }
  }

  void onUsernameChanged(String value) {
    // cancel last timer
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      checkUsername(value);
    });
  }

  void onNameChanged(String value) {
    if (value.isEmpty) {
      setState(() {
        _isNameValid = false;
        nameErrorText = "Inserisci un nome";
      });
    } else {
      setState(() {
        _isNameValid = true;
        nameErrorText = "";
      });
    }
  }

  void onBioChanged(String value) {
    setState(() {
      //_isBioValid = value.isNotEmpty;
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (widget.nameController.text.isNotEmpty) {
      onNameChanged(widget.nameController.text);
      onUsernameChanged(widget.usernameController.text);
    }
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
            // name field
            buildNameField(widget.nameController),

            // username field
            buildUsernameField(),

            // bio field
            buildTextField(widget.bioController, "Bio", Icons.book, onBioChanged),

            // Confirm button
            SizedBox(height: 20.sp),
            ConfirmButton(),
          ],
        )
    );
  }

  Widget buildUsernameField() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 8.sp),
      child: TextField(
        controller: widget.usernameController,
        decoration: InputDecoration(
          labelText: usernameErrorText != "" && usernameErrorText != " "
              ? usernameErrorText
              : "Username",
          labelStyle: TextStyle(color: usernameBorderColor),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(color: usernameBorderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(color: usernameBorderColor),
          ),
          prefixIcon: Icon(Icons.account_circle),
          suffixIcon: usernameErrorText.isNotEmpty
              ? Tooltip(
                  message: usernameErrorText,
                  child: Icon(usernameIcon, color: usernameBorderColor),
                )
              : null,
        ),
        onChanged: onUsernameChanged,
        onTap: () {
          if (usernameErrorText.isEmpty) {
            setState(() {
              usernameBorderColor = Colors.grey;
            });
          }
        },
        onEditingComplete: () {
          FocusScope.of(context).unfocus();
          if (usernameErrorText.isEmpty) {
            setState(() {
              usernameBorderColor = Colors.grey;
            });
          }
        },
      ),
    );
  }

  Widget buildTextField(TextEditingController controller, String label,
      IconData icon, Function(String) onChanged) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 8.sp),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          prefixIcon: Icon(icon),
        ),
        style: TextStyle(fontSize: 16.sp, color: Colors.black),
        onChanged: onChanged,
      ),
    );
  }

  Widget buildNameField(TextEditingController controller) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 8.sp),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: nameErrorText != "" ? nameErrorText : "Nome",
          labelStyle:
              TextStyle(color: nameErrorText != "" ? Colors.red : Colors.grey),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(
                color: nameErrorText != "" ? Colors.red : Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(
                color: nameErrorText != "" ? Colors.red : Colors.grey),
          ),
          prefixIcon: Icon(Icons.person),
          suffixIcon: nameErrorText.isNotEmpty
              ? Tooltip(
                  message: nameErrorText,
                  child: Icon(Icons.error, color: Colors.red),
                )
              : null,
        ),
        style: TextStyle(fontSize: 16.sp, color: Colors.black),
        onChanged: onNameChanged,
      ),
    );
  }

  Widget ConfirmButton() {
    return ElevatedButton(
      onPressed: _isFormValid ? widget.onSubmit : null,
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(
            // ignore: unnecessary_null_comparison
            _isFormValid ? Colors.green : Colors.grey),
        elevation: MaterialStateProperty.all(_isFormValid ? 5.0 : 0.0),
        padding: MaterialStateProperty.all(
            EdgeInsets.symmetric(vertical: 16.sp, horizontal: 64.sp)),
      ),
      child: Text(
        "Conferma",
        style: TextStyle(color: Colors.white, fontSize: 16.sp),
      ),
    );
  }
}
