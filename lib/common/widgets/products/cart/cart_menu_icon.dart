import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:irl_inventory/features/shop/controllers/cart_item_controller.dart';
import 'package:irl_inventory/features/shop/screens/items/cart/cart.dart';
import 'package:irl_inventory/utils/constants/colors.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

class TCartCounterIcon extends StatelessWidget {
  const TCartCounterIcon({
    super.key,
    required this.onPressed,
    required this.iconColor,
  });

  final VoidCallback onPressed;
  final Color iconColor;



  @override
  Widget build(BuildContext context) {
    final cartController = Get.find<CartController>();

    return Stack(
      children: [
        IconButton(
          onPressed: () => Get.to(() => const CartScreen()),
          icon: Icon(
            Iconsax.shopping_bag,
            color: iconColor,
          ),
        ),
        Positioned(
          right: 0,
          child: Obx(() {
            // First check if we have data
            if (cartController.cartItems.isNotEmpty) {
              return Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: TColors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(150),
                ),
                child: Center(
                  child: Text(
                    cartController.cartItems.length.toString(),
                    style: Theme.of(context)
                        .textTheme
                        .labelLarge!
                        .apply(color: TColors.white, fontSizeFactor: 0.9),
                  ),
                ),
              );
            }
            
            // If no data, check if loading
            if (cartController.isLoading.value) {
              return Shimmer.fromColors(
                baseColor: TColors.grey,
                highlightColor: TColors.lightGrey,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: TColors.grey,
                    borderRadius: BorderRadius.circular(150),
                  ),
                ),
              );
            }
            
            // If not loading and no items, show empty
            return Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: TColors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(150),
              ),
              child: Center(
                child: Text(
                  '0',
                  style: Theme.of(context)
                      .textTheme
                      .labelLarge!
                      .apply(color: TColors.white, fontSizeFactor: 0.9),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}