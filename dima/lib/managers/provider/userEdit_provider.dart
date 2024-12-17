import 'package:flutter/material.dart';

class UserEditProvider with ChangeNotifier {
  String selectedCategory = "";
  Set<String> _selectedCategories = {};
  Set<String> _selectedSources = {};

  Set<String> get selectedCategories => _selectedCategories;
  Set<String> get selectedSources => _selectedSources;

  void setSelctedCategory(String category) {
    selectedCategory = category;
  }

  void setSelectedCategories(Set<String> categories) {
    _selectedCategories = categories;
    notifyListeners();
  }

  void setSelectedSources(Set<String> sources) {
    _selectedSources = sources;
    notifyListeners();
  }
}
