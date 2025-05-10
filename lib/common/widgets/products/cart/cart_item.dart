import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shimmer/shimmer.dart';
import 'package:irl_inventory/common/widgets/icons/circular_icon.dart';
import 'package:irl_inventory/common/widgets/images/t_rounded_images.dart';
import 'package:irl_inventory/common/widgets/texts/product_title_text.dart';
import 'package:irl_inventory/features/personalization/controllers/user_controller.dart';
// import 'package:irl_inventory/features/shop/controllers/cart_controller.dart';
import 'package:irl_inventory/features/shop/controllers/cart_item_controller.dart';
import 'package:irl_inventory/features/shop/models/cart_item_model.dart';
import 'package:irl_inventory/features/shop/models/inventory_item_model.dart';
import 'package:irl_inventory/utils/constants/colors.dart';
import 'package:irl_inventory/utils/constants/sizes.dart';
import 'package:irl_inventory/utils/helpers/helper_functions.dart';

class TCartItem extends StatelessWidget {
  final CartItem cartItem;
  final InventoryItem inventoryItem;
  final bool isLoading;

  const TCartItem({
    Key? key,
    required this.cartItem,
    required this.inventoryItem,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    final cartController = Get.find<CartController>();
    final userController = Get.find<UserController>();

    return Column(
      children: [
        // Product Info
        Row(
          children: [
            // Product Image with Shimmer
            isLoading
                ? Shimmer(
                    gradient: LinearGradient(
                      colors: [
                        dark ? TColors.darkerGrey : TColors.light,
                        dark ? TColors.darkGrey : TColors.grey,
                        dark ? TColors.darkerGrey : TColors.light,
                      ],
                    ),
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: dark ? TColors.darkGrey : TColors.light,
                        borderRadius: BorderRadius.circular(TSizes.borderRadiusMd),
                      ),
                    ),
                  )
                : inventoryItem.imageUrl.isNotEmpty
                    ? TRoundedImage(
                        imageUrl: inventoryItem.imageUrl,
                        width: 60,
                        height: 60,
                        padding: const EdgeInsets.all(TSizes.sm),
                        BackgroundColor: dark ? TColors.darkGrey : TColors.light,
                      )
                    : Container(
                        width: 60,
                        height: 60,
                        padding: const EdgeInsets.all(TSizes.sm),
                        decoration: BoxDecoration(
                          color: dark ? TColors.darkGrey : TColors.light,
                          borderRadius: BorderRadius.circular(TSizes.borderRadiusMd),
                        ),
                        child: Icon(
                          Iconsax.box_14,
                          size: 30,
                          color: dark ? TColors.white : TColors.dark,
                        ),
                      ),
            const SizedBox(width: TSizes.spaceBtwItems),

            // Product Details
            Expanded(
              child: isLoading
                  ? Shimmer(
                      gradient: LinearGradient(
                        colors: [
                          dark ? TColors.darkerGrey : TColors.light,
                          dark ? TColors.darkGrey : TColors.grey,
                          dark ? TColors.darkerGrey : TColors.light,
                        ],
                      ),
                      child: Container(
                        width: double.infinity,
                        height: 16,
                        decoration: BoxDecoration(
                          color: dark ? TColors.darkGrey : TColors.light,
                          borderRadius: BorderRadius.circular(TSizes.borderRadiusMd),
                        ),
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TProductTitleText(
                          title: inventoryItem.name ?? "Unknown Product",
                          maxLines: 2,
                        ),
                        // Text(
                        //   '\$${inventoryItem.price.toStringAsFixed(2)}',
                        //   style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        //         fontWeight: FontWeight.bold,
                        //       ),
                        // ),
                      ],
                    ),
            ),
          ],
        ),
        const SizedBox(height: TSizes.spaceBtwItems),

        // Quantity Controls
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Obx(() {
              final currentItem = cartController.cartItems.firstWhere(
                (item) => item.itemId == cartItem.itemId,
                orElse: () => cartItem,
              );

              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Decrease Quantity Button
                  TCircularIcon(
  icon: Iconsax.minus,
  width: 32,
  height: 32,
  size: TSizes.md,
  color: currentItem.selectedQuantity > 1
      ? (dark ? TColors.white : TColors.black)
      : TColors.black,
  backgroundColor: dark ? TColors.darkerGrey : TColors.light,
  onPressed: currentItem.selectedQuantity > 1
      ? () => cartController.updateCartItemQuantity(
            userId: userController.user.value.id!,
            cartItem: currentItem.copyWith(
              selectedQuantity: currentItem.selectedQuantity - 1,
            ),
            inventoryItem: inventoryItem,
          )
      : () {
          // Show confirmation dialog for deletion
          Get.defaultDialog(
            contentPadding: const EdgeInsets.all(TSizes.md),
            title: 'Remove Item',
            middleText:
                'Are you sure you want to remove this item from your cart?',
            confirm: ElevatedButton(
              onPressed: () async {
                // Call the function to delete the item from the cart
                Get.back();
                await cartController.removeItemFromCart(
                  userId: userController.user.value.id!,
                  cartItemId: currentItem.itemId,
                );
                // Close the dialog after removal
                
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: TSizes.lg),
                child: Text('Remove'),
              ),
            ),
            cancel: OutlinedButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(Get.overlayContext!).pop(),
            ),
          );
        },
),

                  const SizedBox(width: TSizes.spaceBtwItems),

                  // Quantity Display
                  Text(
                    currentItem.selectedQuantity.toString(),
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(width: TSizes.spaceBtwItems),

                  // Increase Quantity Button
                  TCircularIcon(
                    icon: Iconsax.add,
                    width: 32,
                    height: 32,
                    size: TSizes.md,
                    color: TColors.white,
                    backgroundColor: TColors.primary,
                    onPressed: currentItem.selectedQuantity < inventoryItem.quantity
                        ? () => cartController.updateCartItemQuantity(
                              userId: userController.user.value.id!,
                              cartItem: currentItem.copyWith(
                                selectedQuantity: currentItem.selectedQuantity + 1,
                              ),
                              inventoryItem: inventoryItem,
                            )
                        : () {
                            Get.snackbar(
            'Stock Limit',
            'Only ${inventoryItem.quantity} items available in stock.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
            duration: Duration(seconds: 1), // Duration for Snackbar visibility
            isDismissible: true, // Allows dismissal when a new one is shown
          );
                          },
                  ),
                ],
              );
            }),
          ],
        ),
      ],
    );
  }
}
