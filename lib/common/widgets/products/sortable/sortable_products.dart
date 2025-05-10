import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:iconsax/iconsax.dart';
import 'package:irl_inventory/common/widgets/layouts/grid_layout.dart';
import 'package:irl_inventory/common/widgets/loaders/vertical_shimmer.dart';
import 'package:irl_inventory/common/widgets/products/product_cards.dart/product_card.dart';
import 'package:irl_inventory/features/shop/controllers/inventory_items_controller.dart';
import 'package:irl_inventory/utils/constants/sizes.dart';

class TSortableProducts extends StatelessWidget {
  const TSortableProducts({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final inventorycontroller = Get.put(InventoryItemsController());
    return Column(
      children: [
        // Dropdown
        // DropdownButtonFormField<String>(
        //   decoration: const InputDecoration(
        //     prefixIcon: Icon(Iconsax.sort),
        //   ),
        //   onChanged: (value) {
        //     // Handle value change
        //   },
        //   items: ['Name', 'Higher Price', 'Lower Price', 'Sale', 'Newest', 'Popularity']
        //       .map((option) => DropdownMenuItem(
        //             value: option,
        //             child: Text(option),
        //           ))
        //       .toList(),
        // ),
        const SizedBox(height: TSizes.spaceBtwSections),
        // Products Grid
       Obx(() { 
              if(inventorycontroller.isLoading.value) return TVerticalProductShimmer();
              if(inventorycontroller.items.isEmpty) return Center(child: Text('No items in inventory',style: Theme.of(context).textTheme.bodyMedium,),);
              return TGridLayout(itemCount: inventorycontroller.items.length, itemBuilder: (_,index) =>  TProductCardVertical(item:  inventorycontroller.items[index]));} ),
      ],
    );
  }
}