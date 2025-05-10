

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:irl_inventory/data/repositories/authentication/authentication_repository.dart';
import 'package:irl_inventory/data/repositories/user/user_repository.dart';
import 'package:irl_inventory/features/authentication/controllers/onboarding/models/user_model.dart';
import 'package:irl_inventory/features/authentication/screens/signup/network_manager.dart';
import 'package:irl_inventory/features/authentication/screens/signup/verify_email.dart';
import 'package:irl_inventory/features/authentication/screens/signup/verify_email_controller.dart';
import 'package:irl_inventory/utils/constants/image_strings.dart';
import 'package:irl_inventory/utils/popups/fullscreenloader.dart';

class SignupController extends GetxController {
  static SignupController get instance => Get.find();

  // var
  final hidePassword = true.obs;
  final privacyPolicy = true.obs;
  final email = TextEditingController();
  final lastName = TextEditingController();
  final username = TextEditingController();
  final password = TextEditingController();
  final firstName = TextEditingController();
  final phoneNumber = TextEditingController();
  GlobalKey<FormState> signupFormKey = GlobalKey<FormState>();

  void signup() async {
  try {
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

    // Validate form
    if (!signupFormKey.currentState!.validate()) return;

    // Check privacy policy
    if (!privacyPolicy.value) {
      Get.snackbar(
        "Accept Privacy Policy",
        "In order to create account, you must accept the Privacy Policy & Terms of Use.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Now show the loader
    TFullScreenLoader.openLoadingDialog('We are processing your information');

    // Register user
    final userCredential = await AuthenticationRepository.instance
        .registerWithEmailAndPassword(email.text.trim(), password.text.trim());

    // Send email verification
    await AuthenticationRepository.instance.sendEmailVerification();

    final newUser = UserModel(
      id: userCredential.user!.uid,
      firstName: firstName.text.trim(),
      lastName: lastName.text.trim(),
      username: username.text.trim(),
      email: email.text.trim(),
      phoneNumber: phoneNumber.text.trim(),
      profilePicture: '',
    );

    final userRepository = Get.put(UserRepository());
    await userRepository.saveUserRecord(newUser);

    TFullScreenLoader.stopLoading();

    Get.snackbar(
      "Success",
      "You have successfully created an Account! Verify your email to continue.",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );

    Get.to(() => VerifyEmailScreen(email: email.text.trim(),));

  } on FirebaseAuthException catch (e) {
    TFullScreenLoader.stopLoading();
    await Future.delayed(const Duration(milliseconds: 200));
    if (e.code == 'weak-password') {
      Get.snackbar(
        "Weak Password",
        "Password should be at least 6 characters.",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  } catch (e) {
    TFullScreenLoader.stopLoading();
    await Future.delayed(const Duration(milliseconds: 200));
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