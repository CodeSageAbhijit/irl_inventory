import 'package:flutter/material.dart';
import 'package:irl_inventory/features/authentication/screens/onboarding/onboarding.dart';
import 'package:irl_inventory/utils/constants/colors.dart';
import 'package:irl_inventory/utils/theme/theme.dart';
import 'package:get/get.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: TAppTheme.lightTheme,
      darkTheme: TAppTheme.darkTheme,
      // home: const OnBoardingScreen(),
      home: const Scaffold(backgroundColor: TColors.primary,body: Center(child: CircularProgressIndicator(color: Colors.white,),),),
    );
  }
}
