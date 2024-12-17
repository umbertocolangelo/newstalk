import 'package:flutter/material.dart';

class RebuildNotifier with ChangeNotifier {
  Key key = UniqueKey();

  void rebuild() {
    key = UniqueKey();
    notifyListeners();
  }
}
