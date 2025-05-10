

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:irl_inventory/data/repositories/authentication/authentication_repository.dart';
import 'package:irl_inventory/features/authentication/screens/password_configuration/reset_password.dart';
import 'package:irl_inventory/features/authentication/screens/signup/network_manager.dart';
import 'package:irl_inventory/utils/popups/fullscreenloader.dart';

class ForgetPasswordController extends GetxController {
    static ForgetPasswordController get instance => Get.find();

    // Variables
    final email = TextEditingController();
    GlobalKey<FormState> forgetPasswordFormKey = GlobalKey<FormState>();

    // Send Reset Password Email
    sendPasswordResetEmail() async {
        try {
            TFullScreenLoader.openLoadingDialog('Processing your request....');

            final isConnected = await Get.find<NetworkManager>().isConnected();
    if (!isConnected) {
      Get.snackbar(
        "No Internet",
        "Please check your internet connection.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if(!forgetPasswordFormKey.currentState!.validate()){
      TFullScreenLoader.stopLoading();
      return;
    }

    await AuthenticationRepository.instance.sendPasswordResetEmail(email.text.trim());

    TFullScreenLoader.stopLoading();

    Get.snackbar(
      "Success",
      "Email Link Sent to Reset Your Password.",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );

    Get.to(() =>ResetPassword(email: email.text.trim()));
        } catch (e) {
          TFullScreenLoader.stopLoading();
          Get.snackbar(
      "Error",
      "Oh snap! ${e.toString()}",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.yellow,
      colorText: Colors.white,
    );  
        }
    }

    resendPasswordResetEmail(String email) async {
        try {
            TFullScreenLoader.openLoadingDialog('Processing your request....');

            final isConnected = await Get.find<NetworkManager>().isConnected();
    if (!isConnected) {
      Get.snackbar(
        "No Internet",
        "Please check your internet connection.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    

    await AuthenticationRepository.instance.sendPasswordResetEmail(email);

    TFullScreenLoader.stopLoading();

    Get.snackbar(
      "Success",
      "Email Link Sent to Reset Your Password.",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );

    
        } catch (e) {
          TFullScreenLoader.stopLoading();
          Get.snackbar(
      "Error",
      "Oh snap! ${e.toString()}",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.yellow,
      colorText: Colors.white,
    );  
        }
    }
}