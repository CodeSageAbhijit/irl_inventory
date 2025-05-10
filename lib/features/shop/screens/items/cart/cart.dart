import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:irl_inventory/common/widgets/appbar/appbar.dart';
import 'package:irl_inventory/common/widgets/loaders/shimmer.dart';
import 'package:irl_inventory/common/widgets/loaders/vertical_shimmer.dart';
// import 'package:irl_inventory/common/widgets/shimmer/cart_item_shimmer.dart';
import 'package:irl_inventory/features/personalization/controllers/user_controller.dart';
// import 'package:irl_inventory/features/shop/controllers/cart_controller.dart';
import 'package:irl_inventory/features/shop/controllers/cart_item_controller.dart';
import 'package:irl_inventory/features/shop/screens/checkout/checkout.dart';
import 'package:irl_inventory/features/shop/screens/items/cart/widgets/cart_items.dart';
import 'package:irl_inventory/utils/constants/sizes.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cartController = Get.put(CartController());
    final userController = Get.put(UserController());

    // Fetch cart items when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (userController.user.value.id != null) {
        cartController.fetchCartItems(userController.user.value.id!);
      }
    });

    return Scaffold(
      appBar: TAppBar(
        showBackArrow: true,
        title: Text("Cart", style: Theme.of(context).textTheme.headlineSmall),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              if (userController.user.value.id != null) {
                cartController.fetchCartItems(userController.user.value.id!);
              }
            },
          ),
        ],
      ),
      body: Obx(() {
        if (cartController.isLoading.value) {
          return ListView.separated(
            padding: const EdgeInsets.all(TSizes.defaultSpace),
            itemCount: 3, // Show 3 shimmer placeholders
            separatorBuilder: (_, __) => const SizedBox(height: TSizes.spaceBtwSections),
            itemBuilder: (_, __) => const CartItemShimmer(),
          );
        }

        if (cartController.cartItems.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.shopping_cart_outlined, size: 64),
                const SizedBox(height: TSizes.spaceBtwItems),
                Text("Your cart is empty", style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 25),
                ElevatedButton(
  onPressed: () => Get.back(),
  style: ElevatedButton.styleFrom(
    minimumSize: const Size(150, 50), // Width: 150, Height: 50
    padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12), // Additional padding
    backgroundColor: Theme.of(context).primaryColor, // Optional: change background color
  ),
  child: const Text("Continue Shopping"),
),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(TSizes.defaultSpace),
            child: TCartItems(
              cartItems: cartController.cartItems,
              resolvedInventoryItems: cartController.resolvedInventoryItems,
            ),
          ),
        );
      }),
      bottomNavigationBar: Obx(() {
        if (cartController.cartItems.isEmpty || cartController.isLoading.value) {
          return const SizedBox.shrink();
        }

        final totalPrice = cartController.cartItems.fold<double>(
          0.0,
          (sum, item) {
            final inventoryItem = cartController.resolvedInventoryItems
                .firstWhereOrNull((invItem) => invItem.id == item.itemId);

            if (inventoryItem != null && inventoryItem.quantity != null) {
              return sum + (item.selectedQuantity * inventoryItem.quantity!);
            }
            return sum;
          },
        );

        return Container(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Total:", style: Theme.of(context).textTheme.labelLarge,textScaleFactor: 1.2,),
                    Text(
                      '${cartController.cartItems.length.toString()} Items',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ElevatedButton(
                  onPressed: cartController.isProcessing.value
                      ? null
                      : () => Get.to(() =>  CheckoutScreen()),
                  child: cartController.isProcessing.value
                      ? const CircularProgressIndicator()
                      : const Text('Checkout'),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}