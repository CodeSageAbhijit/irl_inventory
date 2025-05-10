import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:irl_inventory/common/widgets/appbar/appbar.dart';
import 'package:irl_inventory/common/widgets/custom_shapes/containers/circular_containers.dart';
import 'package:irl_inventory/common/widgets/images/t_circular_images.dart';
import 'package:irl_inventory/common/widgets/texts/section_heading.dart';
import 'package:irl_inventory/features/personalization/controllers/user_controller.dart';
import 'package:irl_inventory/features/personalization/screens/settings/profile/change_name.dart';
// import 'package:irl_inventory/features/personalization/screens/settings/profile/change_username.dart';
import 'package:irl_inventory/features/personalization/screens/settings/profile/widgets/profile_menu.dart';
import 'package:irl_inventory/utils/constants/colors.dart';
import 'package:irl_inventory/utils/constants/image_strings.dart';
import 'package:irl_inventory/utils/constants/sizes.dart';
import 'package:irl_inventory/utils/helpers/helper_functions.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isCopied = false;
  @override
  Widget build(BuildContext context) {
    final controller = UserController.instance;
    return Scaffold(
      appBar: TAppBar(
        showBackArrow: true,
        title: Text('Profile'),
      ),
      body: SingleChildScrollView(
        child: Padding(
            padding: const EdgeInsets.all(
          TSizes.defaultSpace,
        ),
        child: Column(
          children: [
            SizedBox(
          width: double.infinity,
          child: Column(
            children: [
              TCircularWidget(image: TImages.user,width: 80, height: 80,),
              TextButton(onPressed: () {}, child: const Text('Change Profile Picture')),


            ],
          ),
        ),
        const SizedBox(height: TSizes.spaceBtwItems / 2,),
        const Divider(),
        const SizedBox(height: TSizes.spaceBtwItems ,),
        TSectionHeading(title: 'Profile Information', showActionButton: false,),
        const SizedBox(height: TSizes.spaceBtwItems ,),

        TProfileMenu(title: 'Name', value: controller.user.value.fullName,onPressed: () => Get.to( ChangeNameScreen()),),
        TProfileMenu(title: 'Username', value: controller.user.value.username,onPressed: () { customToast(message: "You cannot change your username. It goes agains't the App Usage Policy.");},),

        const SizedBox(height: TSizes.spaceBtwItems,),
        const Divider(),
        const SizedBox(height: TSizes.spaceBtwItems ,),

        TSectionHeading(title: 'Personal Information', showActionButton: false,),
        const SizedBox(height: TSizes.spaceBtwItems ,),

        
  //       TProfileMenu(title: 'User ID', value: controller.user.value.id,onPressed: () {
  //   Clipboard.setData(ClipboardData(text: controller.user.value.id));
  //   Fluttertoast.showToast(
  //     msg: "Copied to Clipboard",
  //     toastLength: Toast.LENGTH_SHORT,
  //     gravity: ToastGravity.BOTTOM,
  //     backgroundColor: Colors.black,
  //     textColor: Colors.white,
  //     fontSize: 16.0,
  //   );
  // },icon: Iconsax.copy,),
  TProfileMenu(
      title: 'User ID',
      value: controller.user.value.id,
      onPressed: () {
        customToast(message: 'User ID copied to clipboard.');
        Clipboard.setData(ClipboardData(text: controller.user.value.id));
        setState(() {
          isCopied = true;
        });
        Future.delayed(Duration(seconds: 2), () {
          setState(() {
            isCopied = false;
          });
        });
      },
      icon: isCopied ? Icons.done : Iconsax.copy,
    ),
        TProfileMenu(title: 'E-mail', value: controller.user.value.email,onPressed: () {},),
        TProfileMenu(title: 'Phone Number', value: '+91 ${controller.user.value.phoneNumber}',onPressed: () {},),
        // TProfileMenu(title: 'Gender', value: 'Male',onPressed: () {},),
        TProfileMenu(title: 'Date_of_Birth', value: '18 May, 1998',onPressed: () {},),
        const Divider(),
        const SizedBox(height: TSizes.spaceBtwSections ,),

        Center(
          child: TextButton(onPressed: () => controller.deleteAccountWarningPopup(), child: const Text('Delete Account', style: TextStyle(color: Colors.red),)),
        )

          ],
        )
        
        ),
        
      ),
    );
  }
  static customToast({required message}) {
  ScaffoldMessenger.of(Get.context!).showSnackBar(
    SnackBar(
      elevation: 0,
      duration: const Duration(seconds: 3),
      backgroundColor: Colors.transparent,
      content: Container(
        padding: const EdgeInsets.all(12.0),
        margin: const EdgeInsets.symmetric(horizontal: 30),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: THelperFunctions.isDarkMode(Get.context!) ? TColors.darkerGrey.withOpacity(0.9) : TColors.grey.withOpacity(0.9),
        ), // BoxDecoration
        child: Center(child: Text(message, style: Theme.of(Get.context!).textTheme.labelLarge)),
      ), // Container
    ), // SnackBar
  );
}
}





