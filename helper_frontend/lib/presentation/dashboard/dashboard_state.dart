import 'package:flutter/material.dart';
import 'package:helper_frontend/core/enums/dashboard_pages_enum.dart';

class DashboardState extends ChangeNotifier {
  final BuildContext context;

  DashboardState(this.context);

  final PageController pageController = PageController();
  final List<DashboardEnum> availablePages = const [
    DashboardEnum.home,
    DashboardEnum.settings,
  ];
  DashboardEnum currentPage = DashboardEnum.home;

  void changePage(DashboardEnum page) {
    final index = availablePages.indexOf(page);
    if (index == -1) return;

    currentPage = page;
    pageController.jumpToPage(index);
    notifyListeners();
  }

  void syncPage(int index) {
    if (index < 0 || index >= availablePages.length) return;

    currentPage = availablePages[index];
    notifyListeners();
  }

  bool isPageAvailable(DashboardEnum page) {
    return availablePages.contains(page);
  }
}
