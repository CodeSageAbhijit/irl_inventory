


import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:irl_inventory/data/repositories/authentication/authentication_repository.dart';
import 'package:irl_inventory/features/authentication/screens/signup/network_manager.dart';
import 'package:irl_inventory/utils/popups/fullscreenloader.dart';

class LoginController extends GetxController{


  final rememberMe = false.obs;
  final hidePassword = true.obs;
  final localstorage = GetStorage();
  final email = TextEditingController();
  final password = TextEditingController();
  GlobalKey<FormState> LoginFormKey = GlobalKey<FormState>();


  @override
  void onInit(){
    // Handle potential null values from storage
    final storedEmail = localstorage.read('REMEMBER_ME_EMAIL');
    final storedPassword = localstorage.read('REMEMBER_ME_PASSWORD');
    
    if (storedEmail != null) email.text = storedEmail;
    if (storedPassword != null) password.text = storedPassword;
    super.onInit();
  }



Future<void> emailAndPasswordSignIn() async {
  try {
    // Start Loading
    TFullScreenLoader.openLoadingDialog('Logging you in...',);

    // Check Internet Connectivity
    // Check internet connection
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

    // Form Validation
    if (!LoginFormKey.currentState!.validate()) {
      TFullScreenLoader.stopLoading();
      return;
    }

    // Save Data if Remember Me is selected
    if (rememberMe.value) {
      localstorage.write('REMEMBER_ME_EMAIL', email.text.trim());
      localstorage.write('REMEMBER_ME_PASSWORD', password.text.trim());
    }

    // Login user using EMAIL & Password Authentication
    final userCredentials = await AuthenticationRepository.instance
        .loginWithEmailAndPassword(email.text.trim(), password.text.trim());

    // Remove Loader
    TFullScreenLoader.stopLoading();

    // Redirect
    AuthenticationRepository.instance.screenRedirect();
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