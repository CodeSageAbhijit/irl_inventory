import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:irl_inventory/features/authentication/screens/login/login.dart';

class OnboardingController extends GetxController {
  static OnboardingController get instance => Get.find();

  /// Variables
  final pageController = PageController();
  RxInt currentPageIndex = 0.obs;

  /// Update current index when the page scrolls
  void updatePageIndicator(int index) {
    currentPageIndex.value = index;
  }

  /// Jump to a specific dot-selected page
  void dotNavigationClick(int index) {
    currentPageIndex.value = index;
    pageController.jumpToPage(index);
  }

  /// Update current index & jump to the next page
  void nextPage() {
    if (currentPageIndex.value == 2) {
      // Navigate to login screen
      final storage = GetStorage();
      storage.write('IsFirstTime', false);
      Get.offAll(() => const LoginScreen());
    } else {
      pageController.jumpToPage(currentPageIndex.value + 1);
    }
  }

  /// Update current index & jump to the last page
  void skipPage() {
    currentPageIndex.value = 2;
    pageController.jumpToPage(2);
  }
}
