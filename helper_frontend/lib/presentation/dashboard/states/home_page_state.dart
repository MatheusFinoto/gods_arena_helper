import 'package:flutter/material.dart';

class HomePageState extends ChangeNotifier {
  bool hideSensitiveData = false;

  void toggleSensitiveDataVisibility() {
    hideSensitiveData = !hideSensitiveData;
    notifyListeners();
  }
}
