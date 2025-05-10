


import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:irl_inventory/common/widgets/login_signup/success_screen/success_screen.dart';
import 'package:irl_inventory/data/repositories/authentication/authentication_repository.dart';
import 'package:irl_inventory/utils/constants/image_strings.dart';
import 'package:irl_inventory/utils/constants/text_strings.dart';

class VerifyEmailController extends GetxController {
  static VerifyEmailController get instance => Get.find();


  @override
  void onInit() {
    setTimerForAutoRedirect();
    super.onInit();
  }


  // send email verification link
  sendEmailVerification() async {
    try{
      await AuthenticationRepository.instance.sendEmailVerification();
      Get.snackbar(
      "Email Sent!",
      "Please check your inbox and verify your email.",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
    }catch (e) {
      Get.snackbar(
      "Error",
      "Oh snap! ${e.toString()}",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.yellow,
      colorText: Colors.white,
    );
    }

  }


  setTimerForAutoRedirect()   {
    Timer.periodic(const Duration(seconds: 1), (timer) async {
      await FirebaseAuth.instance.currentUser?.reload();
      final user = FirebaseAuth.instance.currentUser;
      if(user?.emailVerified ?? false){
        timer.cancel();
        Get.off(() => SuccessScreen(image: TImages.staticSuccessIllustration, title: TTexts.yourAccountCreatedTitle, subtitle: TTexts.yourAccountCreatedSubTitle,onPressed: () => AuthenticationRepository.instance.screenRedirect(),));
      }
    },);
  }

  checkEmailVerification() {
    final currentuser = FirebaseAuth.instance.currentUser;
    if(currentuser != null && currentuser.emailVerified){
      Get.off(
        () => SuccessScreen(image: TImages.staticSuccessIllustration, title: TTexts.yourAccountCreatedTitle, subtitle: TTexts.yourAccountCreatedSubTitle, onPressed: () => AuthenticationRepository.instance.screenRedirect(),)
      );
    }
  }
}