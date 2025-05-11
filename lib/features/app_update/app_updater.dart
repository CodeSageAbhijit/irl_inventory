import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:irl_inventory/features/app_update/get_device_arch.dart';
import 'package:irl_inventory/utils/constants/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseAppUpdater {
  final FirebaseFirestore _firestore;
  final String _versionDocPath;

  FirebaseAppUpdater({
    required FirebaseFirestore firestore,
    required String versionDocPath,
  })  : _firestore = firestore,
        _versionDocPath = versionDocPath;

  Future<Map<String, dynamic>> fetchLatestVersion() async {
    try {
      final doc = await _firestore.doc(_versionDocPath).get();
      if (doc.exists) {
        return doc.data()!;
      }
      throw Exception('Version document does not exist in Firestore.');
    } catch (e) {
      throw Exception('Error fetching version info: $e');
    }
  }

  bool isNewerVersion(String version1, String version2) {
    final v1Parts = version1.split('.').map(int.parse).toList();
    final v2Parts = version2.split('.').map(int.parse).toList();

    for (int i = 0; i < v1Parts.length || i < v2Parts.length; i++) {
      final v1 = i < v1Parts.length ? v1Parts[i] : 0;
      final v2 = i < v2Parts.length ? v2Parts[i] : 0;
      if (v1 > v2) return true;
      if (v1 < v2) return false;
    }
    return false;
  }

  Future<bool> isUpdateAvailable() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;
      final latestVersionData = await fetchLatestVersion();
      return isNewerVersion(latestVersionData['version'], currentVersion);
    } catch (e) {
      print('Error checking for updates: $e');
      return false;
    }
  }

  Future<bool> isUsingOptimalApk() async {
    try {
      final versionData = await fetchLatestVersion();
      
      // If no architecture-specific builds are available, current build is optimal
      if (!versionData.containsKey('architectures')) {
        return true;
      }

      final architecture = await getDeviceArchitecture();
      final packageInfo = await PackageInfo.fromPlatform();
      
      // Check if this is a universal build (contains 'universal' in build number)
      final isUniversalBuild = packageInfo.buildNumber.contains('universal');
      
      // If user has universal build but architecture-specific exists, not optimal
      return (isUniversalBuild && versionData['architectures'].containsKey(architecture));
    } catch (e) {
      print('Error checking optimal APK: $e');
      return true; // Assume optimal if we can't determine
    }
  }

  Future<String> getDownloadUrl() async {
    final versionData = await fetchLatestVersion();
    final defaultUrl = versionData['url'] ?? '';
    
    if (!versionData.containsKey('architectures')) {
      return defaultUrl;
    }
    
    try {
      final architecture = await getDeviceArchitecture();
      final architectures = versionData['architectures'] as Map<String, dynamic>;
      
      // Return architecture-specific URL if available, otherwise default URL
      return architectures[architecture] ?? defaultUrl;
    } catch (e) {
      print('Error getting architecture-specific URL: $e');
      return defaultUrl;
    }
  }

  void showUpdateDialog(
    BuildContext context, {
    bool forceUpdate = true,
    String? customMessage,
  }) async {
    final urlToUse = await getDownloadUrl();
    
    showDialog(
      context: context,
      barrierDismissible: !forceUpdate,
      builder: (context) => AlertDialog(
        title: const Text('Update Available'),
        content: Text(customMessage ?? 
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
              final url = Uri.parse(urlToUse);
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

  Future<void> checkForUpdates(
    BuildContext context, {
    bool showOnlyIfUpdateAvailable = true,
    bool forceUpdate = false,
    bool checkForOptimalApk = true,
  }) async {
    try {
      final updateAvailable = await isUpdateAvailable();
      final usingOptimalApk = checkForOptimalApk ? await isUsingOptimalApk() : true;
      
      if (updateAvailable || !usingOptimalApk || !showOnlyIfUpdateAvailable) {
        String? message;
        
        if (!usingOptimalApk) {
          message = 'A more optimized version for your device is available. '
                   'Updating will improve performance and reduce app size.';
        }
        
        showUpdateDialog(
          context,
          forceUpdate: forceUpdate,
          customMessage: message,
        );
      }
    } catch (e) {
      print('Failed to check for updates: $e');
    }
  }
}