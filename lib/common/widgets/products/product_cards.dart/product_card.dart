import 'package:flutter/material.dart';
import 'package:get/get_rx/src/rx_workers/utils/debouncer.dart';
import 'package:iconsax/iconsax.dart';
import 'package:irl_inventory/common/widgets/custom_shapes/containers/rounded_container.dart';
import 'package:irl_inventory/common/widgets/icons/circular_icon.dart';
import 'package:irl_inventory/common/widgets/icons/favorite_icon.dart';
import 'package:irl_inventory/common/widgets/images/t_rounded_images.dart';
import 'package:irl_inventory/common/widgets/shadows/shadow_style.dart';
import 'package:irl_inventory/common/widgets/texts/product_price.dart';
import 'package:irl_inventory/common/widgets/texts/product_title_text.dart';
import 'package:irl_inventory/features/personalization/controllers/user_controller.dart';
import 'package:irl_inventory/features/shop/controllers/cart_item_controller.dart';
import 'package:irl_inventory/features/shop/models/cart_item_model.dart';
import 'package:irl_inventory/features/shop/models/inventory_item_model.dart';
// import 'package:irl_inventory/features/shop/screens/product_details/product_detail.dart';
import 'package:irl_inventory/utils/constants/colors.dart';
import 'package:irl_inventory/utils/constants/image_strings.dart';
import 'package:irl_inventory/utils/constants/sizes.dart';
import 'package:irl_inventory/utils/helpers/helper_functions.dart';
import 'package:get/get.dart';

class TProductCardVertical extends StatefulWidget {
  const TProductCardVertical({super.key, required this.item});

  final InventoryItem item;

  @override
  State<TProductCardVertical> createState() => _TProductCardVerticalState();
}

class _TProductCardVerticalState extends State<TProductCardVertical> {
  int selectedQuantity = 1;
  bool isAddingToCart = false;
  
bool _isSnackbarVisible = false;

  void _showQuantityError(String message) {
    if (_isSnackbarVisible) return;
    print('its second time ${_isSnackbarVisible}');
    
    _isSnackbarVisible = true;
    print('its second time inside ${_isSnackbarVisible}');
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    
    final snackBar = SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 1),
      behavior: SnackBarBehavior.floating,
      margin: EdgeInsets.only(
        bottom: MediaQuery.of(context).size.height - 200,
        left: 20,
        right: 20,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    );
    
    ScaffoldMessenger.of(context)
      .showSnackBar(snackBar)
      .closed
      .then((_) => _isSnackbarVisible = false);
  }


  void _increaseQuantity() {
    if (selectedQuantity < widget.item.quantity) {
      setState(() => selectedQuantity++);
    } else {
      _showQuantityError('Only ${widget.item.quantity} available');
    }
  }

  void _decreaseQuantity() {
    if (selectedQuantity > 1) {
      setState(() => selectedQuantity--);
    } else {
      _showQuantityError('Minimum quantity is 1');
    }
  }

  Future<void> _addToCart() async {
  if (selectedQuantity <= 0) {
    _showQuantityError('Please select a valid quantity.');
    return;
  }

  if (selectedQuantity > widget.item.quantity) {
    _showQuantityError('Only ${widget.item.quantity} available.');
    return;
  }

  // Show loading state
  if (mounted) setState(() => isAddingToCart = true);

  try {
    final userId = UserController.instance.user.value.id;
    if (userId.isEmpty) throw Exception("User is not logged in.");

    final cartItem = CartItem(
      itemId: widget.item.id.toString(),
      selectedQuantity: selectedQuantity,
    );

    await CartController.instance.addCartItem(userId, cartItem);

    if (mounted) {
      setState(() => isAddingToCart = false);
      _showSuccessMessage(
        '${widget.item.name} (x$selectedQuantity) added to cart'
      );
    }
  } on Exception catch (e) {
    if (mounted) {
      setState(() => isAddingToCart = false);
      
      if (e.toString().contains('already in cart')) {
        _showQuantityError('Item already in cart - quantity updated');
      } else {
        _showQuantityError('Failed to add to cart: ${e.toString()}');
      }
    }
  }
}

void _showSuccessMessage(String message) {
  if (_isSnackbarVisible) return;
  _isSnackbarVisible = true;
  
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  final snackBar = SnackBar(
    content: Text(message),
    duration: const Duration(seconds: 2),
    behavior: SnackBarBehavior.floating,
    margin: EdgeInsets.only(
      bottom: MediaQuery.of(context).size.height - 200,
      left: 20,
      right: 20,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    backgroundColor: TColors.success,
  );
  
  ScaffoldMessenger.of(context)
    .showSnackBar(snackBar)
    .closed
    .then((_) => _isSnackbarVisible = false);
}



  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    final availableQuantity = widget.item.quantity;

    return ScaffoldMessenger(
      child: GestureDetector(
        onTap: () {},
        child: Container(
          width: 180,
          padding: const EdgeInsets.all(TSizes.sm),
          decoration: BoxDecoration(
            boxShadow: [TShadowStyle.verticalProductShadow],
            borderRadius: BorderRadius.circular(TSizes.productImageRadius),
            color: dark ? TColors.darkGrey : TColors.white,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Thumbnail, Wishlist Button
              TRoundedContainer(
                height: 170,
                padding: const EdgeInsets.all(TSizes.sm),
                backgroundColor: dark ? TColors.dark : TColors.light,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    widget.item.imageUrl.isNotEmpty
                        ? TRoundedImage(
                            imageUrl: widget.item.imageUrl,
                            applyImageRadius: true,
                          )
                        : Center(
                            child: Icon(
                              Iconsax.cpu,
                              size: 50,
                              color: dark ? TColors.white : TColors.dark,
                            ),
                          ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Favorite(productId: widget.item.id.toString(),),
                    ),
                    if (availableQuantity <= 0)
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: TSizes.xs),
                          decoration: BoxDecoration(
                            color: TColors.error.withOpacity(0.8),
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(TSizes.productImageRadius),
                              bottomRight: Radius.circular(TSizes.productImageRadius),
                            ),
                          ),
                          child: Text(
                            'OUT OF STOCK',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.labelMedium?.apply(
                                  color: TColors.white,
                                  fontWeightDelta: 2,
                                ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: TSizes.spaceBtwItems / 2),
      
              /// Details
              Padding(
                padding: const EdgeInsets.only(left: TSizes.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TProductTitleText(
                      title: widget.item.name,
                      smallSize: true,
                    ),
                    const SizedBox(height: TSizes.spaceBtwItems / 4),
      
                    /// Notify Me Button (if out of stock)
                  if (availableQuantity <= 0)
        Padding(
      padding: const EdgeInsets.all(10),
      child: SizedBox(
        height: 28,
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            // Use the same snackbar handling approach
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('We\'ll notify you when ${widget.item.name} is back in stock'),
                duration: const Duration(seconds: 2), // Consistent duration
                behavior: SnackBarBehavior.floating,
                margin: EdgeInsets.only(
                  bottom: MediaQuery.of(context).size.height - 200,
                  left: 20,
                  right: 20,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: TColors.primary,
            padding: const EdgeInsets.symmetric(horizontal: TSizes.sm),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(TSizes.sm),
            ),
          ),
          child: Text(
            'NOTIFY ME',
            style: Theme.of(context).textTheme.labelSmall?.apply(
                  color: TColors.white,
                ),
          ),
        ),
      ),
        ),
      
                  ],
                ),
              ),
              const SizedBox(height: TSizes.spaceBtwItems / 2),
      
              /// Quantity Selector and Add Button (only show if in stock)
              if (availableQuantity > 0)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: TSizes.sm),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      /// Compact Quantity Selector
                      Container(
                        height: 30,
                        decoration: BoxDecoration(
                          color: dark ? TColors.darkerGrey : TColors.light,
                          borderRadius: BorderRadius.circular(TSizes.sm),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 28,
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                iconSize: 16,
                                icon: const Icon(Iconsax.minus),
                                onPressed: _decreaseQuantity,
                              ),
                            ),
                            SizedBox(
                              width: 30,
                              child: Center(
                                child: Text(
                                  '$selectedQuantity',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 28,
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                iconSize: 16,
                                icon: const Icon(Iconsax.add),
                                onPressed: _increaseQuantity,
                              ),
                            ),
                          ],
                        ),
                      ),
      
                      /// Add to Cart Button
                      Container(
                        decoration: BoxDecoration(
                          color: isAddingToCart ? TColors.error : TColors.dark,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(TSizes.cardRadiusSm),
                            bottomRight: Radius.circular(TSizes.productImageRadius),
                          ),
                        ),
                        child: SizedBox(
                          width: TSizes.iconLg * 1.2,
                          height: TSizes.iconLg * 1.2,
                          child: Center(
                            child: isAddingToCart
                                ? const CircularProgressIndicator(
                                    color: TColors.white,
                                    strokeWidth: 4,
                                    padding: EdgeInsets.all(7),
                                  )
                                : IconButton(
                                    icon: const Icon(Iconsax.add),
                                    color: TColors.white,
                                    onPressed: _addToCart,
                                  ),
                          ),
                        ),
                      ),
      
                      
                    ],
                  ),
                ),
            ],
      
           
      
          ),
        ),
      ),
    );
  }
}


