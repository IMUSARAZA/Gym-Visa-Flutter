import 'package:flutter/material.dart';

class AppColors {
  static const Color appNeon = Color(0xffB3FF11);
  static const Color appBackground = Color(0xff020202);
  static const Color appTextColor = Color(0xffffffff);
  static const Color rowColor = Color.fromARGB(255, 63, 62, 62);
  static const Color premiumColor = Color(0xFF715F00);
  static const Color standardColor = Color(0xFF434343);
}

class AppTheme {
  static BoxDecoration getGradientBackground() {
    return const BoxDecoration(
      gradient: RadialGradient(
        center: Alignment.topCenter,
        radius: 2,
        colors: [
          AppColors.appBackground,
          Color.fromARGB(255, 34, 34, 34),
          Color.fromARGB(255, 64, 64, 64),
        ],
        stops: [0.6, 0.85, 1.0],
      ),
    );
  }

  static BoxDecoration getDietPlanGradientBackground() {
    return const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [
          Color(0xff020202),
          Color.fromARGB(255, 34, 34, 34),
          Color.fromARGB(255, 64, 64, 64),
        ],
        stops: [0.0, 0.7, 1.0],
      ),
    );
  }
}
