import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:irl_inventory/data/repositories/authentication/authentication_repository.dart';
import 'package:irl_inventory/data/repositories/user/user_repository.dart';
import 'package:irl_inventory/features/authentication/controllers/onboarding/models/user_model.dart';

// import 'package:irl_inventory/utils/loaders/loaders.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:irl_inventory/features/authentication/screens/login/login.dart';
import 'package:irl_inventory/features/authentication/screens/signup/network_manager.dart';
import 'package:irl_inventory/features/personalization/screens/settings/profile/reauthenticate_login_form.dart';
import 'package:irl_inventory/utils/constants/sizes.dart';
import 'package:irl_inventory/utils/popups/fullscreenloader.dart';

class UserController extends GetxController {
  static UserController get instance => Get.find();

  Rx<UserModel> user = UserModel.empty().obs;
  final profileLoading = false.obs;
  final userRepository = Get.put(UserRepository());

  final hidePassword = false.obs;
  final verifyEmail = TextEditingController();
  final verifyPassword = TextEditingController();
  GlobalKey<FormState> reAuthFormKey = GlobalKey<FormState>();


  @override
  void onInit(){
    super.onInit();
    fetchUserRecord();
  }

  Future<void> fetchUserRecord() async {
    try{
      profileLoading.value = true;
      final user = await userRepository.fetchUserData();
      this.user(user);
    } catch (e) {
      user(UserModel.empty());
    }
    finally {
      profileLoading.value = false;
    }
  }

  /// Save user record from any registration provider
  Future<void> saveUserRecord(UserCredential? userCredentials) async {
    try {
      if (userCredentials != null && userCredentials.user != null) {
        // Convert name to first and last name
        final nameParts = UserModel.nameParts(userCredentials.user!.displayName ?? '');
        final username = generateUsername(userCredentials.user!.displayName ?? '');

        // Map data
        final user = UserModel(
          id: userCredentials.user!.uid,
          firstName: nameParts[0],
          lastName: nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '',
          username: username,
          email: userCredentials.user!.email ?? '',
          phoneNumber: userCredentials.user!.phoneNumber ?? '',
          profilePicture: userCredentials.user!.photoURL ?? '',
        );

        // Save user data
        await userRepository.saveUserRecord(user);
      }
    } catch (e) {
      Get.snackbar(
      "Data not Saved",
      "Something went wrong! ${e.toString()}",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.yellow,
      colorText: Colors.white,
    );
    }
  }


  /// Generates a username from display name
  static String generateUsername(String displayName) {
    // Remove special characters and spaces
    final cleanName = displayName.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').toLowerCase();
    // Add random numbers if name is too short
    if (cleanName.length < 6) {
      return cleanName + DateTime.now().millisecondsSinceEpoch.toString().substring(0, 4);
    }
    return cleanName;
  }

  void deleteAccountWarningPopup() {
  Get.defaultDialog(
    contentPadding: const EdgeInsets.all(TSizes.md),
    title: 'Delete Account',
    middleText: 'Are you sure you want to delete your account permanently? This action is not reversible and all of your data will be removed permanently.',
    confirm: ElevatedButton(
      onPressed: () async => deleteUserAccount(),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        side: const BorderSide(color: Colors.red),
      ),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: TSizes.lg),
        child: Text('Delete'),
      ),
    ),
    cancel: OutlinedButton(
      child: const Text('Cancel'),
      onPressed: () => Navigator.of(Get.overlayContext!).pop(),
    ),
  );
}

Future<void> deleteUserAccount() async {
  try {
    TFullScreenLoader.openLoadingDialog('Processing');
    
    final auth = AuthenticationRepository.instance;
    final provider = auth.authUser!.providerData.map((e) => e.providerId).first;
    
    
        TFullScreenLoader.stopLoading();
        Get.to(() => const ReAuthenticateUserLoginForm());
      
    
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

Future<void> reAuthenticateEmailAndPasswordUser() async {
  try {
    TFullScreenLoader.openLoadingDialog('Processing');

    // Check Internet
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
    if (!reAuthFormKey.currentState!.validate()) {
      TFullScreenLoader.stopLoading();
      return;
    }

    // Re-authenticate and delete
    await AuthenticationRepository.instance.reAuthenticateWithEmailAndPassword(
      verifyEmail.text.trim(), 
      verifyPassword.text.trim()
    );
    await AuthenticationRepository.instance.deleteAccount();
    
    TFullScreenLoader.stopLoading();
    Get.offAll(() => const LoginScreen());
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