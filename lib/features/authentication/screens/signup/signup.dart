import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:irl_inventory/app.dart';
import 'package:irl_inventory/common/widgets/login_signup/form_divider.dart';
// import 'package:irl_inventory/common/widgets/login_signup/social_buttons.dart';
import 'package:irl_inventory/features/authentication/screens/signup/signup_form.dart';
import 'package:irl_inventory/features/authentication/screens/signup/verify_email.dart';
import 'package:irl_inventory/utils/constants/colors.dart';
import 'package:irl_inventory/utils/constants/sizes.dart';
import 'package:irl_inventory/utils/constants/text_strings.dart';
import 'package:irl_inventory/utils/helpers/helper_functions.dart';
import 'package:get/get.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // title
              Text(
                TTexts.signupTitle,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(
                height: TSizes.spaceBtwSections,
              ),

              // Form
              signUpForm(dark: dark),

              const SizedBox(
                height: TSizes.spaceBtwSections,
              ),

              // 
            ],
          ),
        ),
      ),
    );
  }
}


