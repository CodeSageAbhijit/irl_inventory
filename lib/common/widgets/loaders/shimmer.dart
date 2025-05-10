import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:irl_inventory/utils/constants/colors.dart';
import 'package:irl_inventory/utils/constants/sizes.dart';
import 'package:irl_inventory/utils/helpers/helper_functions.dart';

class CartItemShimmer extends StatelessWidget {
  const CartItemShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    final shimmerBaseColor = dark ? TColors.darkerGrey : TColors.grey;
    final shimmerHighlightColor = dark ? TColors.darkGrey : TColors.light;

    return Shimmer.fromColors(
      baseColor: shimmerBaseColor,
      highlightColor: shimmerHighlightColor,
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image placeholder
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: dark ? TColors.darkGrey : TColors.light,
                  borderRadius: BorderRadius.circular(TSizes.borderRadiusMd),
                ),
              ),
              const SizedBox(width: TSizes.spaceBtwItems),

              // Text placeholders
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title placeholder
                    Container(
                      width: double.infinity,
                      height: 16,
                      decoration: BoxDecoration(
                        color: dark ? TColors.darkGrey : TColors.light,
                        borderRadius:
                            BorderRadius.circular(TSizes.borderRadiusMd),
                      ),
                    ),
                    const SizedBox(height: TSizes.spaceBtwItems / 2),
                    
                    // Subtitle placeholder
                    Container(
                      width: 100,
                      height: 14,
                      decoration: BoxDecoration(
                        color: dark ? TColors.darkGrey : TColors.light,
                        borderRadius:
                            BorderRadius.circular(TSizes.borderRadiusMd),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: TSizes.spaceBtwItems),

          // Quantity controls placeholder
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Price placeholder
              Container(
                width: 60,
                height: 16,
                decoration: BoxDecoration(
                  color: dark ? TColors.darkGrey : TColors.light,
                  borderRadius: BorderRadius.circular(TSizes.borderRadiusMd),
                ),
              ),

              // Quantity selector placeholder
              Container(
                width: 120,
                height: 32,
                decoration: BoxDecoration(
                  color: dark ? TColors.darkGrey : TColors.light,
                  borderRadius: BorderRadius.circular(TSizes.borderRadiusMd),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}