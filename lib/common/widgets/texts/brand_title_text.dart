import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:irl_inventory/utils/constants/colors.dart';
import 'package:irl_inventory/utils/constants/enums.dart';
import 'package:irl_inventory/utils/constants/sizes.dart';

class TBrandTitleText extends StatelessWidget {
  const TBrandTitleText({
    super.key, required this.title,  this.maxLines = 1, this.textColor, this.iconColor = TColors.primary, this.textALign = TextAlign.center,  this.brandtextSize = TextSizes.small, this.color,
  });

  final Color? color;

  final String title;
  final int maxLines;
  final Color? textColor, iconColor;
  final TextAlign? textALign;
  final TextSizes brandtextSize;

  @override
  Widget build(BuildContext context) {
    return 
        Text(
          title,
          textAlign: textALign,
          maxLines: maxLines,
          overflow: TextOverflow.ellipsis,
          style: brandtextSize == TextSizes.small ? Theme.of(context).textTheme.labelMedium!.apply(color: color) : brandtextSize == TextSizes.medium ? Theme.of(context).textTheme.bodyLarge!.apply(color: color) : brandtextSize == TextSizes.large ?  Theme.of(context).textTheme.titleLarge!.apply(color: color) : Theme.of(context).textTheme.bodyMedium!.apply(color: color),
          
        );
  }
}