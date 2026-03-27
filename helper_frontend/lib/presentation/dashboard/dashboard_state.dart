import 'package:flutter/material.dart';

class DashboardState extends ChangeNotifier {
  final BuildContext context;

  DashboardState(this.context);

  PageController pageController = PageController();

  void changePage(int index) {
    pageController.jumpToPage(index);
    notifyListeners();
  }
}
