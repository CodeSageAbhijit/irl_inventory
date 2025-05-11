import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:irl_inventory/common/widgets/appbar/appbar.dart';
import 'package:irl_inventory/common/widgets/custom_shapes/containers/primary_header_container.dart';
import 'package:irl_inventory/common/widgets/images/t_circular_images.dart';
import 'package:irl_inventory/common/widgets/list_tiles/settings_menu_tile.dart';
import 'package:irl_inventory/common/widgets/list_tiles/user_profile_tile.dart';
import 'package:irl_inventory/common/widgets/texts/section_heading.dart';
import 'package:irl_inventory/data/repositories/authentication/authentication_repository.dart';
import 'package:irl_inventory/features/app_update/app_updater.dart';
import 'package:irl_inventory/features/meme/meme_webview.dart';
import 'package:irl_inventory/features/personalization/screens/return/return_requests.dart';
import 'package:irl_inventory/features/personalization/screens/settings/profile/profile.dart';
import 'package:irl_inventory/features/shop/screens/items/cart/cart.dart';
import 'package:irl_inventory/features/shop/screens/wishlist/wishlist.dart';
import 'package:irl_inventory/utils/constants/colors.dart';
import 'package:irl_inventory/utils/constants/image_strings.dart';
import 'package:irl_inventory/utils/constants/sizes.dart';
import 'package:get/get.dart';

class Settings extends StatelessWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            TPrimaryHeaderContainer(
                child: Column(
              children: [
                TAppBar(
                  title: Text(
                    'Account',
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium!
                        .apply(color: TColors.white),
                  ),
                ),
                const SizedBox(
                  height: TSizes.spaceBtwSections,
                ),
                // user profile
                TUserProfileTile(onPressed:() => Get.to(() => const ProfileScreen()) ,),
                const SizedBox(
                  height: TSizes.spaceBtwSections,
                ),
              ],
            )),

            // body
            Padding(
              padding: const EdgeInsets.all(TSizes.defaultSpace),
              child: Column(
                children: [
                  const TSectionHeading(
                    title: 'Account Settings',
                    showActionButton: false,
                  ),
                  const SizedBox(
                    height: TSizes.defaultSpace,
                  ),
                  TSettingMenuTile(
                    icon: Iconsax.back_square,
                    title: 'Return Requests',
                    subtitle: 'To return the borrowed items.',
                    onTap: () => Get.to(() => ReturnItems()),
                  ),
                  TSettingMenuTile(
                    icon: Iconsax.shopping_cart,
                    title: 'My Cart',
                    subtitle: 'Add, remove products and move to checkout',
                    onTap: () => Get.to(() => const CartScreen()),
                  ),
                  TSettingMenuTile(
                    icon: Iconsax.heart4,
                    title: 'Wishlist',
                    subtitle: 'Add, remove products and move to checkout',
                    onTap: () => Get.to(() => const Wishlist()),
                  ),
                   TSettingMenuTile(
                    icon: Iconsax.notification,
                    title: 'Notifications',
                    subtitle: 'Set any kind of notification message',
                    onTap: () { Get.dialog(
    AlertDialog(
      title: Text('Feature Coming Soon'),
      content: Text('The notifications feature is currently in development.'),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: Text('OK'),
        ),
      ],
    ),
  ); },
                  ),
                  TSettingMenuTile(
  icon: Iconsax.directbox_notif,
  title: 'Check for Updates',
  subtitle: 'Verify if app update is available',
  onTap: () async {
    final appUpdater = Get.find<FirebaseAppUpdater>();
    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );
      
      final updateAvailable = await appUpdater.isUpdateAvailable();
      Get.back(); // Close loading dialog
      
      if (updateAvailable) {
        final latestVersionData = await appUpdater.fetchLatestVersion();
        appUpdater.showUpdateDialog(
          context,
          forceUpdate: false,
        );
      } else {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Up to Date'),
            content: const Text('You have the latest version installed.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      Get.back(); // Close loading dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Update Check Failed'),
          content: Text('Error checking for updates: ${e.toString()}'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  },
),
                  
                  // logout button
                  const SizedBox(height: TSizes.spaceBtwSections),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () async { 
                        await AuthenticationRepository.instance.logout();
                      }, 
                      child: Text('Logout')
                    ),
                  ),
                  
                  // Watermark with surprise element
                  const SizedBox(height: TSizes.spaceBtwSections * 2),
                  GestureDetector(
  onTap: () {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("A Special Message"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Crafted with ❤️ by Abhijit Kad"),
            const SizedBox(height: 16),
            Image.asset(
              TImages.lightAppLogo, // Replace with your image
              height: 100,
            ),
            const SizedBox(height: 16),
            RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.black),
                children: [
                  const TextSpan(
                    text: "Thank you for using this app!\n\nHere's a secret: ",
                  ),
                  TextSpan(
                    text: "Click Here!!!",
                    style: const TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.pop(context); // Close the dialog
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MemeImage(
                              top: "404",
                              bottom: "idhar zeher khane ka paisa nahi hai!", // Customize as needed
                            ),
                          ),
                        );
                      },
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  },
  child: const Column(
    children: [
      Opacity(
        opacity: 0.5,
        child: Text(
          "Don't Click Me!!!",
          style: TextStyle(
            fontSize: 12,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
      SizedBox(height: 4),
      Icon(
        Iconsax.close_circle,
        size: 16,
        color: Colors.grey,
      ),
    ],
  ),
),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}