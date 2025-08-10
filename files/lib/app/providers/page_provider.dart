import 'package:flutter/material.dart';
import 'package:webinar/common/enums/page_name_enum.dart';

class PageProvider extends ChangeNotifier {
  // Initialize the PageController in the constructor
  late final PageController pageController;

  // Constructor to initialize the PageController
  PageProvider() : pageController = PageController();

  PageNames page = PageNames.home;

  // Dispose method to clean up resources
  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  void setPage(PageNames data, {bool emit = true}) {
    page = data;
    if (emit && hasListeners) {
      notifyListeners();
    }
  }
}
