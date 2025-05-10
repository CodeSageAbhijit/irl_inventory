import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:irl_inventory/common/widgets/icons/circular_icon.dart';
import 'package:irl_inventory/features/shop/controllers/favorite_controller.dart';

class Favorite extends StatelessWidget {
  const Favorite({
    super.key, required this.productId,
  });

  final String productId;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(FavouritesController());
    return Obx(
      () => TCircularIcon(
        icon: controller.isFavourite(productId) ?  Iconsax.heart5 : Iconsax.heart,
        color: controller.isFavourite(productId) ?  Colors.red : null,
        onPressed: () => controller.toggleFavoriteProduct(productId),
      ),
    );
  }
}