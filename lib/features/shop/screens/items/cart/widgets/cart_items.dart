import 'package:flutter/material.dart';
import 'package:irl_inventory/common/widgets/products/cart/add_remove_button.dart';
import 'package:irl_inventory/common/widgets/products/cart/cart_item.dart';
import 'package:irl_inventory/common/widgets/texts/product_price.dart';
import 'package:irl_inventory/features/shop/models/cart_item_model.dart';
import 'package:irl_inventory/features/shop/models/inventory_item_model.dart';
import 'package:irl_inventory/utils/constants/sizes.dart';

class TCartItems extends StatelessWidget {
  final List<CartItem> cartItems;
  final List<InventoryItem> resolvedInventoryItems;
  final bool showAddRemoveButton;

  const TCartItems({
    Key? key,
    required this.cartItems,
    required this.resolvedInventoryItems,
    this.showAddRemoveButton = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        cartItems.length,
        (index) {
          final cartItem = cartItems[index];
          final inventoryItem = resolvedInventoryItems.firstWhere(
            (item) => item.id.toString() == cartItem.itemId,
            orElse: () => InventoryItem.empty(), // Handle missing item gracefully
          );

          return Column(
            children: [
              TCartItem(
                cartItem: cartItem,
                inventoryItem: inventoryItem,
              ),
              if (index < cartItems.length - 1)
                const SizedBox(height: TSizes.spaceBtwSections),
            ],
          );
        },
      ),
    );
  }
}
