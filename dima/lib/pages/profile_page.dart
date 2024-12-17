import 'package:dima/widgets/profilePage/personal_view.dart';
import 'package:dima/widgets/profilePage/public_view.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  final String userId;

  ProfilePage({this.userId = ""});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isLoading = true;
  bool _isPersonalView = false;

  @override
  void initState() {
    super.initState();
    _checkUserId();
  }

  Future<void> _checkUserId() async {
    // Load private page if no userId is given
    if (widget.userId == "") {
      setState(() {
        _isPersonalView = true;
        _isLoading = false;
      });
      return;
    }
    setState(() {
      _isPersonalView = false;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Container(),
      );
    } else {
      return _isPersonalView
          ? PersonalView()
          : PublicView(userId: widget.userId);
    }
  }
}
