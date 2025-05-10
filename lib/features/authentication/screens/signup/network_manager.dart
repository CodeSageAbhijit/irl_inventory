import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';

// import '../utils/loaders.dart'; // Adjust based on your actual file structure

class NetworkManager extends GetxController {
  final Connectivity _connectivity = Connectivity();
 late final StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;


  // Reactive variable to track connection status
  final Rx<ConnectivityResult> _connectionStatus = ConnectivityResult.none.obs;

  @override
  void onInit() {
    super.onInit();
    _connectivitySubscription =
    _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> result) {
  _updateConnectionStatus(result);
});

  }

  /// Update the connection status based on changes in connectivity
  /// and show a relevant popup for no internet connection.
  Future<void> _updateConnectionStatus(List<ConnectivityResult> result) async {
  if (result.contains(ConnectivityResult.none)) {
    _connectionStatus.value = ConnectivityResult.none;
    
  } else {
    _connectionStatus.value = result.first; // or any preferred logic
    // Show snackbar using GetX
    // Get.snackbar(
    //   "No Internet",
    //   "Please check your connection.",
    //   snackPosition: SnackPosition.BOTTOM,
    //   backgroundColor: Colors.red,
    //   colorText: Colors.white,
    //   duration: Duration(seconds: 3),
    // );
  }
}


  /// Check the internet connection status.
  /// Returns `true` if connected, `false` otherwise.
  Future<bool> isConnected() async {
    try {
      final result = await _connectivity.checkConnectivity();
      if (result == ConnectivityResult.none) {
        return false;
      } else {
        return true;
      }
    } on PlatformException catch (_) {
      return false;
    }
  }

  @override
  void onClose() {
    super.onClose();
    _connectivitySubscription.cancel();
  }
}
