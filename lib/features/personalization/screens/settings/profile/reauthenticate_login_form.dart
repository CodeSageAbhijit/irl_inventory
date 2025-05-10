import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:irl_inventory/utils/constants/sizes.dart';
import 'package:irl_inventory/utils/constants/text_strings.dart';
import 'package:irl_inventory/utils/validators/validation.dart';
import 'package:irl_inventory/features/personalization/controllers/user_controller.dart';

class ReAuthenticateUserLoginForm extends StatelessWidget {
  const ReAuthenticateUserLoginForm({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = UserController.instance;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text("Re-Authenticate User"),
        automaticallyImplyLeading: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Form(
            key: controller.reAuthFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Email Field
                TextFormField(
                  controller: controller.verifyEmail,
                  validator: TValidator.validateEmail,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Iconsax.direct_right),
                    labelText: TTexts.email,
                  ),
                ),
                const SizedBox(height: TSizes.spaceBtwInputFields),

                // Password Field
                Obx(
                  () => TextFormField(
                    obscureText: controller.hidePassword.value,
                    controller: controller.verifyPassword,
                    validator: (value) => TValidator.validateEmptyText(value),
                    decoration: InputDecoration(
                      labelText: TTexts.password,
                      prefixIcon: const Icon(Iconsax.password_check),
                      suffixIcon: IconButton(
                        onPressed: () => controller.hidePassword.value = !controller.hidePassword.value,
                        icon: Icon(controller.hidePassword.value ? Iconsax.eye_slash : Iconsax.eye),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: TSizes.spaceBtwSections),

                // Verify Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => controller.reAuthenticateEmailAndPasswordUser(),
                    child: const Text('Verify'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}