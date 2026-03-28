import 'package:flutter/material.dart';
import 'package:helper_frontend/core/enums/dashboard_pages_enum.dart';

class DashboardState extends ChangeNotifier {
  final BuildContext context;

  DashboardState(this.context);

  PageController pageController = PageController();
  int currentPageIndex = 0;
  final int availablePagesCount = 1;

  void changePage(int index) {
    if (index < 0 || index >= availablePagesCount) return;

    currentPageIndex = index;
    pageController.jumpToPage(index);
    notifyListeners();
  }

  bool isPageAvailable(DashboardEnum page) {
    final index = DashboardEnum.values.indexOf(page);
    return index >= 0 && index < availablePagesCount;
  }
}
