import 'package:get/get.dart';

class SimpleHomeController extends GetxController {
  static SimpleHomeController get instance => Get.find();

  final carouselCurrentIndex = 0.obs;

  void updatePageIndicator(index) {
    carouselCurrentIndex.value = index;
  }
}
