import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:irl_inventory/features/authentication/controllers/onboarding/onboarding_controller.dart';
import 'package:irl_inventory/features/authentication/screens/onboarding/widgets/onboarding_dot_navigation.dart';
import 'package:irl_inventory/features/authentication/screens/onboarding/widgets/onboarding_next_button.dart';
import 'package:irl_inventory/features/authentication/screens/onboarding/widgets/onboarding_page.dart';
import 'package:irl_inventory/features/authentication/screens/onboarding/widgets/onboarding_skip.dart';
import 'package:irl_inventory/utils/constants/colors.dart';
import 'package:irl_inventory/utils/constants/image_strings.dart';
import 'package:irl_inventory/utils/constants/sizes.dart';
import 'package:irl_inventory/utils/constants/text_strings.dart';
import 'package:irl_inventory/utils/device/device_utility.dart';
import 'package:irl_inventory/utils/helpers/helper_functions.dart';
import 'package:get/get.dart';

class OnBoardingScreen extends StatelessWidget {
  const OnBoardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OnboardingController());

    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: controller.pageController,
            onPageChanged: controller.updatePageIndicator,
            children: const [
              // horizontal scallable pages
              OnBoardingPage(
                image: TImages.onBoardingImage1,
                title: TTexts.onBoardingTitle1,
                subtitle: TTexts.onBoardingSubTitle1,
              ),
              OnBoardingPage(
                image: TImages.onBoardingImage2,
                title: TTexts.onBoardingTitle2,
                subtitle: TTexts.onBoardingSubTitle2,
              ),
              OnBoardingPage(
                image: TImages.onBoardingImage3,
                title: TTexts.onBoardingTitle3,
                subtitle: TTexts.onBoardingSubTitle3,
              ),
            ],
          ),
          // skip button
          const OnBoardingSkip(),
          // smooth page indicator
          const OnBoardingDotNavigation(),
          // circular button
          const OnBoardingNextButton(),
        ],
      ),
    );
  }
}
