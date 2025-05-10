import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:irl_inventory/app.dart';
import 'package:irl_inventory/common/styles/spacing_styles.dart';
import 'package:irl_inventory/features/authentication/controllers/onboarding/onboarding_controller.dart';
import 'package:irl_inventory/common/widgets/login_signup/form_divider.dart';
import 'package:irl_inventory/features/authentication/screens/login/widgets/login_form.dart';
import 'package:irl_inventory/features/authentication/screens/login/widgets/login_header.dart';
// import 'package:irl_inventory/common/widgets/login_signup/social_buttons.dart';
import 'package:irl_inventory/features/authentication/screens/onboarding/onboarding.dart';
import 'package:irl_inventory/utils/constants/colors.dart';
import 'package:irl_inventory/utils/constants/image_strings.dart';
import 'package:irl_inventory/utils/constants/sizes.dart';
import 'package:irl_inventory/utils/constants/text_strings.dart';
import 'package:irl_inventory/utils/device/device_utility.dart';
import 'package:irl_inventory/utils/helpers/helper_functions.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: TSpacingStyle.paddingWithAppBarHeight,
          child: Column(
            children: [
              const TLoginHeader(),

              // Form
              TLoginForm(),

              
            ],
          ),
        ),
      ),
    );
  }
}
