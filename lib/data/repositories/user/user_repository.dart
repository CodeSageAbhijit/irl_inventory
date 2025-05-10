import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:irl_inventory/data/repositories/authentication/authentication_repository.dart';
import 'package:irl_inventory/features/authentication/controllers/onboarding/models/user_model.dart';
// import '../../../features/personalization/models/user_model.dart';
// import '../../../utils/exceptions/firebase_exceptions.dart';
// import '../../../utils/exceptions/format_exceptions.dart';
// import '../../../utils/exceptions/platform_exceptions.dart';

/// Repository class for user-related operations.
class UserRepository extends GetxController {
  static UserRepository get instance => Get.find();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Function to save user data to Firestore.
  Future<void> saveUserRecord(UserModel user) async {
    try {
      debugPrint("📦 Saving user to Firestore: ${user.toJson()}"); // Or print manually
      await _db.collection("Users").doc(user.id).set(user.toJson());
    } on FirebaseException catch (e) {
      Get.snackbar("Error", "Unknown error: ${e.toString()}");
    throw e;
    } on FormatException catch (_) {
      Get.snackbar("Error", "Unknown error: ${_.toString()}");
    throw _;
    } on PlatformException catch (e) {
      Get.snackbar("Error", "Unknown error: ${e.toString()}");
    throw e;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  // Function to fetch user data from Firestore
Future<UserModel> fetchUserData() async {
  try {
    final documentSnapshot = await _db
        .collection("Users")
        .doc(AuthenticationRepository.instance.authUser?.uid)
        .get();

    if (documentSnapshot.exists) {
      return UserModel.fromSnapshot(documentSnapshot);
    } else {
      return UserModel.empty();
    }
  }on FirebaseException catch (e) {
      Get.snackbar("Error", "Unknown error: ${e.toString()}");
    throw e;
    } on FormatException catch (_) {
      Get.snackbar("Error", "Unknown error: ${_.toString()}");
    throw _;
    } on PlatformException catch (e) {
      Get.snackbar("Error", "Unknown error: ${e.toString()}");
    throw e;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
}

// Function to update user data in Firestore
Future<void> updateUserDetails(UserModel updatedUser) async {
  try {
    await _db
        .collection("Users")
        .doc(updatedUser.id)
        .update(updatedUser.toJson());
  } on FirebaseException catch (e) {
      Get.snackbar("Error", "Unknown error: ${e.toString()}");
    throw e;
    } on FormatException catch (_) {
      Get.snackbar("Error", "Unknown error: ${_.toString()}");
    throw _;
    } on PlatformException catch (e) {
      Get.snackbar("Error", "Unknown error: ${e.toString()}");
    throw e;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
}

// Updates a single field in the Users collection
Future<void> updateSingleField(Map<String, dynamic> json) async {
  try {
    final userId = AuthenticationRepository.instance.authUser?.uid;
    if (userId == null) throw 'User not authenticated';
    
    await _db.collection("Users").doc(userId).update(json);
  } on FirebaseException catch (e) {
      Get.snackbar("Error", "Unknown error: ${e.toString()}");
    throw e;
    } on FormatException catch (_) {
      Get.snackbar("Error", "Unknown error: ${_.toString()}");
    throw _;
    } on PlatformException catch (e) {
      Get.snackbar("Error", "Unknown error: ${e.toString()}");
    throw e;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
}

/// Removes a user record from Firestore
Future<void> removeUserRecord(String userId) async {
  try {
    await _db.collection("Users").doc(userId).delete();
  }on FirebaseException catch (e) {
      Get.snackbar("Error", "Unknown error: ${e.toString()}");
    throw e;
    } on FormatException catch (_) {
      Get.snackbar("Error", "Unknown error: ${_.toString()}");
    throw _;
    } on PlatformException catch (e) {
      Get.snackbar("Error", "Unknown error: ${e.toString()}");
    throw e;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
}



}
