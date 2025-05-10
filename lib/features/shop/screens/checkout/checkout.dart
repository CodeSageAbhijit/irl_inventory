import 'package:flutter/material.dart';
import 'package:flutter_xlider/flutter_xlider.dart';
import 'package:irl_inventory/common/widgets/appbar/appbar.dart';
import 'package:irl_inventory/common/widgets/custom_shapes/containers/rounded_container.dart';
import 'package:irl_inventory/common/widgets/login_signup/success_screen/success_screen.dart';
import 'package:irl_inventory/features/personalization/controllers/user_controller.dart';
import 'package:irl_inventory/features/shop/controllers/cart_item_controller.dart';
import 'package:irl_inventory/features/shop/screens/home/home.dart';
import 'package:irl_inventory/features/shop/screens/items/cart/widgets/cart_items.dart';
import 'package:irl_inventory/features/shop/screens/requests/requests.dart';
import 'package:irl_inventory/navigation_menu.dart';
import 'package:irl_inventory/utils/constants/colors.dart';
import 'package:irl_inventory/utils/constants/image_strings.dart';
import 'package:irl_inventory/utils/constants/sizes.dart';
import 'package:get/get.dart';
import 'package:irl_inventory/utils/helpers/helper_functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CheckoutScreen extends StatelessWidget {
  CheckoutScreen({super.key});

  final _purposeController = TextEditingController();
  final _sliderValue = 1.0.obs;

  @override
  Widget build(BuildContext context) {
    final cartController = Get.put(CartController());
    final userController = Get.find<UserController>();
    final dark = THelperFunctions.isDarkMode(context);

    return Scaffold(
      appBar: TAppBar(
        showBackArrow: true,
        title: Text(
          'Order Review',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: Column(
          children: [
            // Scrollable cart items section
            Flexible(
              child: SingleChildScrollView(
                child: TCartItems(
                  cartItems: cartController.cartItems,
                  resolvedInventoryItems: cartController.resolvedInventoryItems,
                ),
              ),
            ),
            const SizedBox(height: TSizes.spaceBtwItems),
            
            // Fixed form section
            TRoundedContainer(
              showBorder: true,
              padding: const EdgeInsets.all(TSizes.md),
              backgroundColor: dark ? TColors.black : TColors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Borrowing Details',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: TSizes.spaceBtwItems),
                  TextField(
                    controller: _purposeController,
                    maxLength: 250,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      labelText: 'Purpose for borrowing components',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: TSizes.spaceBtwItems),
                  const Text(
                    'Select Duration (in days)',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: TSizes.spaceBtwItems),
                  Obx(() => FlutterSlider(
                    values: [_sliderValue.value],
                    min: 1,
                    max: 60,
                    step: FlutterSliderStep(step: 1),
                    handler: FlutterSliderHandler(
                      child: Material(
                        type: MaterialType.circle,
                        color: TColors.primary,
                        elevation: 3,
                        child: const Icon(Icons.circle, color: Colors.white, size: 16),
                      ),
                    ),
                    trackBar: FlutterSliderTrackBar(
                      activeTrackBarHeight: 5,
                      activeTrackBar: BoxDecoration(
                        color: TColors.primary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      inactiveTrackBar: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    tooltip: FlutterSliderTooltip(
                      textStyle: const TextStyle(fontSize: 14, color: Colors.white),
                      boxStyle: FlutterSliderTooltipBox(
                        decoration: BoxDecoration(
                          color: TColors.primary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      format: (value) => '$value days',
                    ),
                    onDragging: (handlerIndex, lowerValue, upperValue) {
                      _sliderValue.value = lowerValue;
                    },
                  )),
                  const SizedBox(height: TSizes.spaceBtwItems),
                  Obx(() => Text(
                    'Selected Duration: ${_sliderValue.value.toInt()} days',
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  )),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: ElevatedButton.icon(
          onPressed: () async {
            final userId = userController.user.value.id!;
            final purpose = _purposeController.text.trim();
            final duration = _sliderValue.value.toInt();

            if (purpose.isEmpty || duration < 1) {
              Get.snackbar(
                'Error',
                'Please fill in all fields.',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.red,
                colorText: Colors.white,
              );
              return;
            }

            try {
              await cartController.submitRequest(
                userId: userId,
                purpose: purpose,
                duration: duration,
              );

              Get.to(() => SuccessScreen(
                image: TImages.deliveredInPlaneIllustration,
                title: 'Request Submitted',
                subtitle: 'Your request of components for $duration days has been submitted successfully! Wait for Approval!',
                onPressed: () => Get.offAll(() => const NavigationMenu()),
              ));
            } catch (e) {
              Get.snackbar(
                'Error',
                'Failed to submit request. Please try again later.',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.red,
                colorText: Colors.white,
              );
            }
          },
          
          label: const Text('Request Access'),
        ),
      ),
    );
  }
}
