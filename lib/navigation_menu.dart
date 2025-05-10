import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';
import 'package:irl_inventory/features/shop/screens/home/home.dart';
import 'package:irl_inventory/features/personalization/screens/settings/settings.dart';
import 'package:irl_inventory/features/shop/screens/requests/requests.dart';
import 'package:irl_inventory/features/shop/screens/wishlist/wishlist.dart';
import 'package:irl_inventory/features/shop/screens/wishlist/wishlist.dart';
import 'package:irl_inventory/utils/constants/colors.dart';
import 'package:irl_inventory/utils/helpers/helper_functions.dart';

class NavigationMenu extends StatelessWidget {
  const NavigationMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NavigationController());
    final darkMode = THelperFunctions.isDarkMode(context);
    return Scaffold(
      bottomNavigationBar: Obx(
        () => NavigationBar(
            height: 80,
            elevation: 0,
            selectedIndex: controller.selectedIndex.value,
            onDestinationSelected: (index) =>
                controller.selectedIndex.value = index,
            backgroundColor: darkMode ? TColors.black : TColors.white,
            indicatorColor: darkMode
                ? TColors.white.withOpacity(0.1)
                : TColors.black.withOpacity(0.1),
            destinations: [
              NavigationDestination(icon: Icon(Iconsax.home), label: 'Home'),
              NavigationDestination(icon: Icon(Iconsax.clipboard), label: 'Requests'),
              NavigationDestination(
                  icon: Icon(Iconsax.heart), label: 'WishList'),
              NavigationDestination(icon: Icon(Iconsax.user), label: 'Profile'),
            ]),
      ),
      body: Obx(() => controller.screens[controller.selectedIndex.value]),
    );
  }
}

class NavigationController extends GetxController {
  final Rx<int> selectedIndex = 0.obs;

  final screens = [
    const HomeScreen(),
    const Requests(),
    const Wishlist(),
    const Settings(),
  ];
}
