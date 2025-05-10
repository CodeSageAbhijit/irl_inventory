import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:irl_inventory/utils/constants/colors.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class FirebaseAppUpdater {
  // Firestore instance
  final FirebaseFirestore _firestore;

  // Document path for version info in Firestore
  final String _versionDocPath;

  FirebaseAppUpdater({
    required FirebaseFirestore firestore,
    required String versionDocPath,
  })  : _firestore = firestore,
        _versionDocPath = versionDocPath;

  /// Fetches the latest version information from Firestore
  Future<Map<String, dynamic>> fetchLatestVersion() async {
    try {
      final doc = await _firestore.doc(_versionDocPath).get();
      if (doc.exists) {
        return doc.data()!;
      } else {
        throw Exception('Version document does not exist in Firestore.');
      }
    } catch (e) {
      throw Exception('Error fetching version info: $e');
    }
  }

  /// Custom version comparison function
  /// Returns true if version1 is greater than version2
  bool isNewerVersion(String version1, String version2) {
    // print(version1);
    // print(version2);
    List<int> v1Parts = version1.split('.').map(int.parse).toList();
    List<int> v2Parts = version2.split('.').map(int.parse).toList();

    // Ensure both lists have the same length
    while (v1Parts.length < v2Parts.length) {
      v1Parts.add(0);
    }
    while (v2Parts.length < v1Parts.length) {
      v2Parts.add(0);
    }

    // Compare version parts
    for (int i = 0; i < v1Parts.length; i++) {
      if (v1Parts[i] > v2Parts[i]) {
        return true;
      } else if (v1Parts[i] < v2Parts[i]) {
        return false;
      }
    }

    // If we got here, versions are equal
    return false;
  }

  /// Checks if an update is available by comparing current app version with latest
  Future<bool> isUpdateAvailable() async {
    try {
      // Get current app version
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      // Get latest version from Firestore
      final latestVersionData = await fetchLatestVersion();
      final latestVersion = latestVersionData['version'];

      // Compare versions
      return isNewerVersion(latestVersion, currentVersion);
    } catch (e) {
      print('Error checking for updates: $e');
      // In case of error, assume no update is needed
      return false;
    }
  }

  /// Shows an update dialog with options to update or cancel
void showUpdateDialog(
  BuildContext context, {
  required String downloadUrl,
  bool forceUpdate = true,
}) {
  showDialog(
    context: context,
    barrierDismissible: !forceUpdate,
    builder: (context) => AlertDialog(
      title: const Text('Update Available'),
      content: const Text(
          'A new version of the app is available. Please update to get the latest features and improvements.'),
      actions: [
        if (!forceUpdate)
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey[600],
            ),
            child: const Text('Later'),
          ),
        TextButton(
          onPressed: () async {
            final url = Uri.parse(downloadUrl);
            if (await canLaunchUrl(url)) {
              await launchUrl(
                url,
                mode: LaunchMode.externalApplication,
              );
            }
          },
          style: TextButton.styleFrom(
            foregroundColor: TColors.primary,
            textStyle: const TextStyle(fontWeight: FontWeight.bold),
          ),
          child: const Text('Update Now'),
        ),
      ],
    ),
  );
}

  /// Checks for updates and shows a dialog if an update is available
  Future<void> checkForUpdates(
    BuildContext context, {
    bool showOnlyIfUpdateAvailable = true,
    bool forceUpdate = false,
  }) async {
    try {
      final updateAvailable = await isUpdateAvailable();

      if (updateAvailable || !showOnlyIfUpdateAvailable) {
        final latestVersionData = await fetchLatestVersion();
        final downloadUrl = latestVersionData['url'];

        // Show the update dialog
        showUpdateDialog(
          context,
          downloadUrl: downloadUrl,
          forceUpdate: forceUpdate,
        );
      }
    } catch (e) {
      print('Failed to check for updates: $e');
    }
  }
}


