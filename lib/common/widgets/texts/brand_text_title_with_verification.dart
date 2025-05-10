

import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:irl_inventory/common/widgets/texts/brand_title_text.dart';
import 'package:irl_inventory/utils/constants/colors.dart';
import 'package:irl_inventory/utils/constants/enums.dart';
import 'package:irl_inventory/utils/constants/sizes.dart';

class TBrandTitleWithVerifiedIcon extends StatelessWidget {
  const TBrandTitleWithVerifiedIcon({super.key, required this.title,  this.maxLines = 1, this.textColor, this.iconColor = TColors.primary, this.textALign = TextAlign.center,  this.brandtextSize = TextSizes.small});


  final String title;
  final int maxLines;
  final Color? textColor, iconColor;
  final TextAlign? textALign;
  final TextSizes brandtextSize;


  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(child: TBrandTitleText(title: title, color: textColor,maxLines: maxLines,textALign: textALign,brandtextSize: brandtextSize,)),
         const SizedBox(
          width: TSizes.xs,
        ),
        const Icon(
          Iconsax.verify5,
          color: TColors.primary,
          size: TSizes.iconXs,
        )
      ],
    );
  }
}