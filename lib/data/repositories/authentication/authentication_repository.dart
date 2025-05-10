

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:irl_inventory/data/repositories/user/user_repository.dart';
import 'package:irl_inventory/features/authentication/screens/login/login.dart';
import 'package:irl_inventory/features/authentication/screens/onboarding/onboarding.dart';
import 'package:irl_inventory/features/authentication/screens/signup/verify_email.dart';
import 'package:irl_inventory/navigation_menu.dart';
import 'package:irl_inventory/utils/local_storage/storage_utility.dart';

class AuthenticationRepository extends GetxController{
  static AuthenticationRepository get instance => Get.find();

  final deviceStorage = GetStorage();
  final _auth = FirebaseAuth.instance;

  User? get authUser => _auth.currentUser;

  @override
  void onReady(){
    FlutterNativeSplash.remove();
    screenRedirect();
  }

  screenRedirect() async {
    final user = _auth.currentUser;
    if(user != null){
      if(user.emailVerified){

        await LocalStorage.init(user.uid);

        Get.offAll(() => const NavigationMenu());
      } else {
        Get.offAll(() => VerifyEmailScreen(email: _auth.currentUser?.email,));
      }
    }
    else{
      deviceStorage.writeIfNull('IsFirstTime', true);
    deviceStorage.read('IsFirstTime') != true ? Get.offAll(() => const LoginScreen()) : Get.offAll(const OnBoardingScreen());
    }
    
  }

  Future<UserCredential> loginWithEmailAndPassword(String email, String password) async {
  try {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  } on FirebaseAuthException catch (e) {
    Get.snackbar("Error", "FirebaseAuthException: ${e.message}");
    throw e; // ✅ Add this
  } on FirebaseException catch (e) {
    Get.snackbar("Error", "FirebaseException: ${e.message}");
    throw e;
  } on FormatException catch (e) {
    Get.snackbar("Error", "FormatException: ${e.message}");
    throw e;
  } on PlatformException catch (e) {
    Get.snackbar("Error", "PlatformException: ${e.message}");
    throw e;
  } catch (e) {
    Get.snackbar("Error", "Unknown error: ${e.toString()}");
    throw e;
  }
}


  Future<UserCredential> registerWithEmailAndPassword(String email, String password) async {
  try {
    final credential =  await _auth.createUserWithEmailAndPassword(email: email, password: password);
     debugPrint("✅ Firebase UserCredential: ${credential.user?.uid}");
     return credential;
  } on FirebaseAuthException catch (e) {
    Get.snackbar("Error", "FirebaseAuthException: ${e.message}");
    throw e; // ✅ Add this
  } on FirebaseException catch (e) {
    Get.snackbar("Error", "FirebaseException: ${e.message}");
    throw e;
  } on FormatException catch (e) {
    Get.snackbar("Error", "FormatException: ${e.message}");
    throw e;
  } on PlatformException catch (e) {
    Get.snackbar("Error", "PlatformException: ${e.message}");
    throw e;
  } catch (e) {
    Get.snackbar("Error", "Unknown error: ${e.toString()}");
    throw e;
  }


}

/// [EmailVerification] - MAIL VERIFICATION
Future<void> sendEmailVerification() async {
  try {
    await _auth.currentUser?.sendEmailVerification();
  } on FirebaseAuthException catch (e) {
    Get.snackbar("Error", "FirebaseAuthException: ${e.message}");
    throw e; // ✅ Add this
  } on FirebaseException catch (e) {
    Get.snackbar("Error", "FirebaseException: ${e.message}");
    throw e;
  } on FormatException catch (e) {
    Get.snackbar("Error", "FormatException: ${e.message}");
    throw e;
  } on PlatformException catch (e) {
    Get.snackbar("Error", "PlatformException: ${e.message}");
    throw e;
  } catch (e) {
    Get.snackbar("Error", "Unknown error: ${e.toString()}");
    throw e;
  }
}

Future<void> sendPasswordResetEmail(String email) async {
  try {
    await _auth.sendPasswordResetEmail(email: email);
  } on FirebaseAuthException catch (e) {
    Get.snackbar("Error", "FirebaseAuthException: ${e.message}");
    throw e; // ✅ Add this
  } on FirebaseException catch (e) {
    Get.snackbar("Error", "FirebaseException: ${e.message}");
    throw e;
  } on FormatException catch (e) {
    Get.snackbar("Error", "FormatException: ${e.message}");
    throw e;
  } on PlatformException catch (e) {
    Get.snackbar("Error", "PlatformException: ${e.message}");
    throw e;
  } catch (e) {
    Get.snackbar("Error", "Unknown error: ${e.toString()}");
    throw e;
  }
}


Future<void> logout() async {
  try {
    await FirebaseAuth.instance.signOut();
    Get.offAll(() => const LoginScreen());
  } on FirebaseAuthException catch (e) {
    Get.snackbar("Error", "FirebaseAuthException: ${e.message}");
    throw e; // ✅ Add this
  } on FirebaseException catch (e) {
    Get.snackbar("Error", "FirebaseException: ${e.message}");
    throw e;
  } on FormatException catch (e) {
    Get.snackbar("Error", "FormatException: ${e.message}");
    throw e;
  } on PlatformException catch (e) {
    Get.snackbar("Error", "PlatformException: ${e.message}");
    throw e;
  } catch (e) {
    Get.snackbar("Error", "Unknown error: ${e.toString()}");
    throw e;
  }

}

/// Re-authenticates user with email and password before sensitive operations
Future<void> reAuthenticateWithEmailAndPassword(String email, String password) async {
  try {
    // Create a credential
    final AuthCredential credential = EmailAuthProvider.credential(
      email: email,
      password: password,
    );

    // Re-authenticate user
    await _auth.currentUser!.reauthenticateWithCredential(credential);
    
  } on FirebaseAuthException catch (e) {
    Get.snackbar("Error", "FirebaseAuthException: ${e.message}");
    throw e; // ✅ Add this
  } on FirebaseException catch (e) {
    Get.snackbar("Error", "FirebaseException: ${e.message}");
    throw e;
  } on FormatException catch (e) {
    Get.snackbar("Error", "FormatException: ${e.message}");
    throw e;
  } on PlatformException catch (e) {
    Get.snackbar("Error", "PlatformException: ${e.message}");
    throw e;
  } catch (e) {
    Get.snackbar("Error", "Unknown error: ${e.toString()}");
    throw e;
  }
}

/// Permanently deletes user account from both Authentication and Firestore
Future<void> deleteAccount() async {
  try {
    // First delete user data from Firestore
    await UserRepository.instance.removeUserRecord(_auth.currentUser!.uid);
    
    // Then delete auth account
    await _auth.currentUser?.delete();
    
  } on FirebaseAuthException catch (e) {
    Get.snackbar("Error", "FirebaseAuthException: ${e.message}");
    throw e; // ✅ Add this
  } on FirebaseException catch (e) {
    Get.snackbar("Error", "FirebaseException: ${e.message}");
    throw e;
  } on FormatException catch (e) {
    Get.snackbar("Error", "FormatException: ${e.message}");
    throw e;
  } on PlatformException catch (e) {
    Get.snackbar("Error", "PlatformException: ${e.message}");
    throw e;
  } catch (e) {
    Get.snackbar("Error", "Unknown error: ${e.toString()}");
    throw e;
  }
}
 }