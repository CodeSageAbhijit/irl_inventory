import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:irl_inventory/features/authentication/controllers/login/login_controller.dart';
import 'package:irl_inventory/features/authentication/screens/password_configuration/forget_password.dart';
import 'package:irl_inventory/features/authentication/screens/signup/signup.dart';
import 'package:irl_inventory/navigation_menu.dart';
import 'package:irl_inventory/utils/constants/sizes.dart';
import 'package:irl_inventory/utils/constants/text_strings.dart';
import 'package:get/get.dart';
import 'package:irl_inventory/utils/validators/validation.dart';

class TLoginForm extends StatelessWidget {
  const TLoginForm({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LoginController());
    return Form(
      key: controller.LoginFormKey,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: TSizes.spaceBtwSections),
        child: Column(
          children: [
            // emial
            TextFormField(
              controller: controller.email,
              validator: (value) => TValidator.validateEmail(value),
              decoration: const InputDecoration(
                prefixIcon: Icon(Iconsax.direct_right),
                labelText: TTexts.email,
              ),
            ),
            const SizedBox(
              height: TSizes.spaceBtwInputFields,
            ),
            // password
            Obx(
          () => TextFormField(
            controller: controller.password,
            validator: (value) => TValidator.validatePassword(value),
            obscureText: controller.hidePassword.value,
            expands: false,
            decoration: InputDecoration(
                labelText: TTexts.password,
                prefixIcon: const Icon(Iconsax.password_check),
                suffixIcon: IconButton(
                  onPressed: () => controller.hidePassword.value = !controller.hidePassword.value,
                 icon:  Icon(controller.hidePassword.value ? Iconsax.eye_slash : Iconsax.eye),
                 ),
                
                
                
          ),
          ),
        ),
            const SizedBox(
              height: TSizes.spaceBtwInputFields / 2,
            ),

            // remember me/ forget pas
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Obx(() => Checkbox(value: controller.rememberMe.value, onChanged: (value) => controller.rememberMe.value = !controller.rememberMe.value)),
                    const Text(TTexts.rememberMe),
                  ],
                ),
                TextButton(
                  onPressed: () => Get.to(() => const ForgetPassword()),
                  child: const Text(
                    TTexts.forgetPassword,
                  ),
                )
              ],
            ),
            const SizedBox(
              height: TSizes.spaceBtwSections,
            ),

            // sign in button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () =>  controller.emailAndPasswordSignIn(),
                child: const Text(TTexts.signIn),
              ),
            ),
            const SizedBox(
              height: TSizes.spaceBtwItems,
            ),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Get.to(() => const SignUpScreen()),
                child: const Text(TTexts.createAccount),
              ),
            ),
            // const SizedBox(
            //   height: TSizes.spaceBtwSections,
            // ),
          ],
        ),
      ),
    );
  }
}
