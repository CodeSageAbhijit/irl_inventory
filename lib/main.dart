import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:irl_inventory/app.dart';
import 'package:irl_inventory/data/repositories/authentication/authentication_repository.dart';
import 'package:irl_inventory/features/app_update/app_updater.dart';
import 'package:irl_inventory/features/authentication/screens/signup/network_manager.dart';
import 'package:irl_inventory/features/shop/controllers/cart_item_controller.dart';
import 'package:irl_inventory/firebase_options.dart';
import 'package:irl_inventory/utils/theme/theme.dart';



Future<void> main() async {

final WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

await GetStorage.init();


FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

 await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

 Get.put(AuthenticationRepository());
 Get.put(CartController());
 Get.put(NetworkManager());
 // Initialize the app updater
  final appUpdater = FirebaseAppUpdater(
    firestore: FirebaseFirestore.instance,
    versionDocPath: 'app_versions/current', // Adjust this path as needed
  );
  
  // Store the updater in GetX for easy access
  Get.put(appUpdater);





  runApp(const App());
}
