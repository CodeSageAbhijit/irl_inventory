

import 'package:flutter/material.dart';
import 'package:irl_inventory/utils/constants/colors.dart';
import 'package:irl_inventory/utils/device/device_utility.dart';
import 'package:irl_inventory/utils/helpers/helper_functions.dart';

class TTabBar extends StatelessWidget implements PreferredSizeWidget{
  const TTabBar({super.key, required this.tabs});

  final List<Widget> tabs;

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    return Material(
      color: dark ? TColors.black : TColors.white,
      child: Align(
        alignment: Alignment.centerLeft,
        child: TabBar(tabs: tabs,
        isScrollable: true,
        indicatorColor: TColors.primary,
        labelColor: dark ? TColors.white : TColors.primary,
        unselectedLabelColor: TColors.darkGrey,
        tabAlignment: TabAlignment.start,),
      ),
      
    );
  }
  
  @override
  // TODO: implement preferredSize
  Size get preferredSize => Size.fromHeight(TDeviceUtils.getAppBarHeight());
}