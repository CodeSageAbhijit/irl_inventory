import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:irl_inventory/data/repositories/user/user_repository.dart';
import 'package:irl_inventory/features/authentication/screens/signup/network_manager.dart';
import 'package:irl_inventory/features/personalization/controllers/user_controller.dart';
import 'package:irl_inventory/features/personalization/screens/settings/profile/profile.dart';
import 'package:irl_inventory/utils/constants/sizes.dart';
import 'package:irl_inventory/utils/constants/text_strings.dart';
import 'package:irl_inventory/utils/popups/fullscreenloader.dart';
import 'package:irl_inventory/utils/validators/validation.dart';

class ChangeNameScreen extends StatelessWidget {
  const ChangeNameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(UpdateNameController());
    
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text('Change Name', style: Theme.of(context).textTheme.headlineSmall),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Instruction Text
              Text(
                'Use real name for easy verification. This name will appear on several pages.',
                style: Theme.of(context).textTheme.labelMedium,
              ),
              const SizedBox(height: TSizes.spaceBtwSections),
              
              // Form
              Form(
                key: controller.updateUserNameFormKey,
                child: Column(
                  children: [
                    // First Name Field
                    TextFormField(
                      controller: controller.firstName,
                      validator: (value) => TValidator.validateEmptyText(value),
                      decoration: const InputDecoration(
                        labelText: TTexts.firstName,
                        prefixIcon: Icon(Iconsax.user)
                      ),
                    ),
                    const SizedBox(height: TSizes.spaceBtwInputFields),
                    
                    // Last Name Field
                    TextFormField(
                      controller: controller.lastName,
                      validator: (value) => TValidator.validateEmptyText(value),
                      decoration: const InputDecoration(
                        labelText: TTexts.lastName,
                        prefixIcon: Icon(Iconsax.user)
                      ),
                    ),
                    const SizedBox(height: TSizes.spaceBtwSections),
                    
                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => controller.updateUserName(),
                        child: const Text('Save Changes'),
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


class UpdateNameController extends GetxController {
  static UpdateNameController get instance => Get.find();

  final firstName = TextEditingController();
  final lastName = TextEditingController();
  final userController = UserController.instance;
  final userRepository = Get.put(UserRepository());
  GlobalKey<FormState> updateUserNameFormKey = GlobalKey<FormState>();

  @override
  void onInit() {
    initializeNames();
    super.onInit();
  }

  /// Initialize user data
  Future<void> initializeNames() async {
    firstName.text = userController.user.value.firstName;
    lastName.text = userController.user.value.lastName;
  }

  /// Update user name
  Future<void> updateUserName() async {
    try {
      // Start Loading
      TFullScreenLoader.openLoadingDialog('We are updating your information...');

      // Check Internet Connectivity
      final isConnected = await Get.find<NetworkManager>().isConnected();
    if (!isConnected) {
      Get.snackbar(
        "No Internet",
        "Please check your internet connection.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

      // Form Validation
      if (!updateUserNameFormKey.currentState!.validate()) {
        TFullScreenLoader.stopLoading();
        return;
      }

      // Update user first & last name in Firebase
      Map<String, dynamic> name = {
        'firstName': firstName.text.trim(),
        'lastName': lastName.text.trim()
      };
      await userRepository.updateSingleField(name);

      // Update the Rx User value
      userController.user.value.firstName = firstName.text.trim();
      userController.user.value.lastName = lastName.text.trim();

      // Remove Loader
      TFullScreenLoader.stopLoading();

      // Show Success Message
      Get.snackbar(
      "Congratulations!",
      "Your name has been updated",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color.fromARGB(255, 59, 255, 111),
      colorText: Colors.white,
    );

      // Navigate back
      Get.off(() => const ProfileScreen());

    } catch (e) {
      // Remove Loader
      TFullScreenLoader.stopLoading();
      // Show Error
      Get.snackbar(
      "Error",
      "Oh snap! ${e.toString()}",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.yellow,
      colorText: Colors.white,
    );
    }
  }

  @override
  void onClose() {
    firstName.dispose();
    lastName.dispose();
    super.onClose();
  }
}