import 'package:flutter/material.dart';
import 'package:irl_inventory/utils/constants/colors.dart';
import 'package:irl_inventory/utils/constants/image_strings.dart';
import 'package:irl_inventory/utils/constants/sizes.dart';
import 'package:irl_inventory/utils/helpers/helper_functions.dart';

class TCircularWidget extends StatelessWidget {
  const TCircularWidget({
    super.key, this.fit = BoxFit.cover, required this.image,  this.isNetworkImage = false, this.overlayColor, this.backgroundColor,  this.width = 56,  this.height = 56,  this.padding = TSizes.sm,
  });

  final BoxFit? fit;
  final String image;
  final bool isNetworkImage;
  final Color? overlayColor;
  final Color? backgroundColor;
  final double width, height,padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding:  EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: backgroundColor ?? (THelperFunctions.isDarkMode(context) ? TColors.black : TColors.white),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Center(child: Image(fit: fit, image:isNetworkImage ? NetworkImage(image) : AssetImage(image) as ImageProvider, color:overlayColor)),
    );
  }
}