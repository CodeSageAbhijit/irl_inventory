// import 'package:flutter/material.dart';
// import 'package:iconsax/iconsax.dart';
// import 'package:irl_inventory/common/widgets/custom_shapes/containers/rounded_container.dart';
// import 'package:irl_inventory/common/widgets/icons/circular_icon.dart';
// import 'package:irl_inventory/common/widgets/images/t_rounded_images.dart';
// import 'package:irl_inventory/common/widgets/shadows/shadow_style.dart';
// import 'package:irl_inventory/common/widgets/texts/brand_text_title_with_verification.dart';
// import 'package:irl_inventory/common/widgets/texts/product_price.dart';
// import 'package:irl_inventory/common/widgets/texts/product_title_text.dart';
// import 'package:irl_inventory/utils/constants/colors.dart';
// import 'package:irl_inventory/utils/constants/image_strings.dart';
// import 'package:irl_inventory/utils/constants/sizes.dart';
// import 'package:irl_inventory/utils/helpers/helper_functions.dart';

// class TProductCardHorizontal extends StatelessWidget {
//   const TProductCardHorizontal({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final dark = THelperFunctions.isDarkMode(context);

//     return Container(
//       width: 310,
//       padding: const EdgeInsets.all(1),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(TSizes.productImageRadius),
//         color: dark ? TColors.darkerGrey : TColors.lightContainer,
//       ),
//       child: Row(
//         children: [
//           /// Thumbnail
//           TRoundedContainer(
//             height: 120,
//             padding: EdgeInsets.all(TSizes.md),
//             backgroundColor: dark ? TColors.dark : TColors.light,
//             child: Stack(
//               children: [
//                 SizedBox(
//                   height: 120,
//                   width: 120,
//                   child: TRoundedImage(
//                     imageUrl: TImages.productImage1,
//                     applyImageRadius: true,
//                   ),
//                 ),
//                 Positioned(
//                   top: 12,
//                   child: TRoundedContainer(
//                     radius: TSizes.sm,
//                     backgroundColor: TColors.secondary.withOpacity(0.8),
//                     padding: const EdgeInsets.symmetric(
//                         horizontal: TSizes.sm, vertical: TSizes.xs),
//                     child: Text(
//                       '25%',
//                       style: Theme.of(context)
//                           .textTheme
//                           .labelLarge!
//                           .apply(color: TColors.black),
//                     ),
//                   ),
//                 ),
//                 Positioned(
//                   top: 0,
//                   right: 0,
//                   child: TCircularIcon(
//                     icon: Iconsax.heart5,
//                     color: Colors.red,
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           // / Details
//           Expanded(
//             child: Padding(
//               padding: const EdgeInsets.only(
//                 top: TSizes.sm,
//                 left: TSizes.sm,
//                 right: TSizes.sm,
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const TProductTitleText(
//                     title: 'Green Nike Half Sleeves Shirt',
//                     smallSize: true,
//                   ),
//                   const SizedBox(height: TSizes.spaceBtwItems / 2),
//                   const TBrandTitleWithVerifiedIcon(title: 'Nike'),
//                   const Spacer(),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       const TProductPriceText(price: '260.0'),
//                       Container(
//                         decoration: const BoxDecoration(
//                           color: TColors.dark,
//                           borderRadius: BorderRadius.only(
//                             topLeft: Radius.circular(TSizes.cardRadiusMd),
//                             bottomRight:
//                                 Radius.circular(TSizes.productImageRadius),
//                           ),
//                         ),
//                         child: const SizedBox(
//                           width: TSizes.iconLg * 1.2,
//                           height: TSizes.iconLg * 1.2,
//                           child: Center(
//                             child: Icon(
//                               Iconsax.add,
//                               color: TColors.white,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
