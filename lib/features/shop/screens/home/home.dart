import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:irl_inventory/features/app_update/app_updater.dart';
import 'package:irl_inventory/features/personalization/controllers/user_controller.dart';
import 'package:irl_inventory/features/shop/controllers/inventory_items_controller.dart';
import 'package:shimmer/shimmer.dart';
import 'package:irl_inventory/common/widgets/appbar/appbar.dart';
import 'package:irl_inventory/common/widgets/custom_shapes/containers/primary_header_container.dart';
import 'package:irl_inventory/common/widgets/layouts/grid_layout.dart';
import 'package:irl_inventory/common/widgets/loaders/vertical_shimmer.dart';
import 'package:irl_inventory/common/widgets/products/cart/cart_menu_icon.dart';
import 'package:irl_inventory/common/widgets/texts/section_heading.dart';
import 'package:irl_inventory/common/widgets/products/product_cards.dart/product_card.dart';
import 'package:irl_inventory/features/shop/screens/items/all_items/all_products.dart';
import 'package:irl_inventory/utils/constants/colors.dart';
import 'package:irl_inventory/utils/constants/sizes.dart';
import 'package:irl_inventory/utils/constants/text_strings.dart';
import 'package:get/get.dart';
// import 'package:irl_inventory/utils/updater/app_updater.dart'; // Import the updater

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final InventoryItemsController inventorycontroller = Get.put(InventoryItemsController());
  final UserController controller = Get.put(UserController());
  final FirebaseAppUpdater appUpdater = Get.find<FirebaseAppUpdater>();

  @override
  void initState() {
    super.initState();
    // Check for updates after the widget is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForUpdates();
    });
  }

  Future<void> _checkForUpdates() async {
    try {
      final updateAvailable = await appUpdater.isUpdateAvailable();
      if (updateAvailable && mounted) {
        final latestVersionData = await appUpdater.fetchLatestVersion();
        final downloadUrl = latestVersionData['url'];
        appUpdater.showUpdateDialog(
          context,
          downloadUrl: downloadUrl,
          forceUpdate: true, // Set to true if you want to force updates
        );
      }
    } catch (e) {
      debugPrint('Failed to check for updates: $e');
    }
  }

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
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          TTexts.homeAppbarTitle,
                          style: Theme.of(context)
                              .textTheme
                              .labelMedium!
                              .apply(color: TColors.grey),
                        ),
                        Obx(() {
                          if (controller.profileLoading.value == true) {
                            return Shimmer.fromColors(
                              baseColor: Colors.grey[300]!,
                              highlightColor: Colors.grey[100]!,
                              child: Container(
                                width: 80,
                                height: 15,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(4),
                              ),
                            ));
                          } else {
                            return Text(
                              controller.user.value.fullName,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall!
                                  .apply(color: TColors.white),
                            );
                          }
                        }),
                      ],
                    ),
                    actions: [
                      TCartCounterIcon(
                        iconColor: TColors.white,
                        onPressed: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: TSizes.spaceBtwSections),
                  // searchBar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: TSizes.defaultSpace),
                    child: TextField(
                      onChanged: (value) => inventorycontroller.searchItems(value),
                      decoration: InputDecoration(
                        hintText: 'Search in Store',
                        prefixIcon: const Icon(Iconsax.search_normal),
                        filled: true,
                        fillColor: TColors.lightGrey,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: TSizes.spaceBtwSections),
                  const SizedBox(height: TSizes.spaceBtwSections * 1.5),
                ],
              ),
            ),
            // Body
            Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                children: [
                  TSectionHeading(
                    title: 'Inventory',
                    onPressed: () => Get.to(() => const AllProducts()),
                  ),
                  const SizedBox(height: TSizes.spaceBtwItems),
                  Obx(() {
                    if (inventorycontroller.isLoading.value) return const TVerticalProductShimmer();
                    if (inventorycontroller.filteredItems.isEmpty) {
                      return Center(
                        child: Text(
                          'No such item in inventory',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      );
                    }
                    return TGridLayout(
                      itemCount: inventorycontroller.filteredItems.length,
                      itemBuilder: (_, index) => TProductCardVertical(
                        item: inventorycontroller.filteredItems[index],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}