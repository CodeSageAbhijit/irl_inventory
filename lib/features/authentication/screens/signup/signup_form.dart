import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:iconsax/iconsax.dart';
import 'package:irl_inventory/features/authentication/screens/signup/signup_controller.dart';
import 'package:irl_inventory/features/authentication/screens/signup/verify_email.dart';
import 'package:irl_inventory/utils/constants/colors.dart';
import 'package:irl_inventory/utils/constants/sizes.dart';
import 'package:irl_inventory/utils/constants/text_strings.dart';
import 'package:irl_inventory/utils/validators/validation.dart';

class signUpForm extends StatelessWidget {
  const signUpForm({
    super.key,
    required this.dark,
  });

  final bool dark;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SignupController());
    return Form(
      key: controller.signupFormKey,
        child: Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: controller.firstName,
                validator: (value) => TValidator.validateEmptyText(value),
                expands: false,
                decoration: const InputDecoration(
                    labelText: TTexts.firstName,
                    prefixIcon: Icon(Iconsax.user)),
              ),
            ),
            const SizedBox(
              width: TSizes.spaceBtwInputFields,
            ),
            Expanded(
              child: TextFormField(
                controller: controller.lastName,
                validator: (value) => TValidator.validateEmptyText(value),
                expands: false,
                decoration: const InputDecoration(
                    labelText: TTexts.lastName,
                    prefixIcon: Icon(Iconsax.user)),
              ),
            )
          ],
        ),
        const SizedBox(
          height: TSizes.spaceBtwInputFields,
        ),
        TextFormField(
          controller: controller.username,
          validator: (value) => TValidator.validateEmptyText(value),
          expands: false,
          decoration: const InputDecoration(
              labelText: TTexts.username,
              prefixIcon: Icon(Iconsax.user_edit)),
        ),
        const SizedBox(
          height: TSizes.spaceBtwInputFields,
        ),
        TextFormField(
          controller: controller.email,
          validator: (value) => TValidator.validateEmail(value),
          expands: false,
          decoration: const InputDecoration(
              labelText: TTexts.email,
              prefixIcon: Icon(Iconsax.direct)),
        ),
        const SizedBox(
          height: TSizes.spaceBtwInputFields,
        ),
        TextFormField(
          controller: controller.phoneNumber,
          validator: (value) => TValidator.validatePhoneNumber(value),
          expands: false,
          decoration: const InputDecoration(
              labelText: TTexts.phoneNo,
              prefixIcon: Icon(Iconsax.call)),
        ),
        const SizedBox(
          height: TSizes.spaceBtwInputFields,
        ),
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
          height: TSizes.spaceBtwInputFields,
        ),
        Row(
          children: [
            SizedBox(
                width: 24,
                height: 24,
                child: Obx(
                  () => Checkbox(
                    value: controller.privacyPolicy.value,
                    onChanged: (value) => controller.privacyPolicy.value = ! controller.privacyPolicy.value,
                  ),
                )),
            const SizedBox(
              width: TSizes.spaceBtwItems,
            ),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                      text: '${TTexts.iAgreeTo} ',
                      style: Theme.of(context).textTheme.bodySmall),
                  TextSpan(
                      text: '${TTexts.privacyPolicy} ',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium!
                          .apply(
                            color: dark
                                ? TColors.white
                                : TColors.primary,
                            decoration: TextDecoration.underline,
                            decorationColor: dark
                                ? TColors.white
                                : TColors.primary,
                          )),
                  TextSpan(
                      text: '${TTexts.and} ',
                      style: Theme.of(context).textTheme.bodySmall),
                  TextSpan(
                      text: '${TTexts.termsOfUse}.',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium!
                          .apply(
                            color: dark
                                ? TColors.white
                                : TColors.primary,
                            decoration: TextDecoration.underline,
                            decorationColor: dark
                                ? TColors.white
                                : TColors.primary,
                          )),
                ],
              ),
            )
          ],
        ),
        const SizedBox(
          height: TSizes.spaceBtwSections,
        ),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
              onPressed: () => controller.signup(),
              child: const Text(
                TTexts.createAccount,
              )),
        )
        
      ],
    ));
  }
}