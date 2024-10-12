import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gymvisa/const/AppColors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Onboarding(),
    );
  }
}

class Onboarding extends StatefulWidget {
  const Onboarding({super.key});

  @override
  State<Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    double fontSizeGymVisa = 50;
    double fontSizeGetStarted = 25;
    double iconSize = 35;
    double fontSizeOr = 18;
    double fontSizeLogin = 20;

    if (screenWidth < 480) {
      fontSizeGetStarted = 22;
      iconSize = 30;
      fontSizeLogin = 18;
      fontSizeOr = 17;
    }
    if (screenWidth < 450) {
      fontSizeGetStarted = 20;
      fontSizeGymVisa = 48;
      fontSizeLogin = 17;
      fontSizeOr = 16;
    }
    if (screenWidth < 380) {
      fontSizeGetStarted = 18;
      fontSizeGymVisa = 42;
      fontSizeLogin = 15;
      fontSizeOr = 14;
    }
    if (screenWidth < 350) {
      fontSizeGetStarted = 16;
      iconSize = 25;
      fontSizeOr = 12;
      fontSizeLogin = 13;
      fontSizeGymVisa = 35;
    }

    if (screenWidth < 300) {
      fontSizeGetStarted = 13;
      iconSize = 18;
      fontSizeOr = 10;
      fontSizeLogin = 11;
      fontSizeGymVisa = 30;
    }

    return Scaffold(
      backgroundColor: AppColors.appBackground,
      body: Container(
        child: SingleChildScrollView(
          child: Container(
            height: screenHeight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: screenHeight * 0.05),
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20.0),
                      child: Image.asset(
                        'lib/assets/onBoard.png',
                        height: screenHeight * 0.7,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      left: screenWidth * 0.05,
                      right: screenWidth * 0.05,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                        child: Text(
                          'GYM VISA',
                          style: GoogleFonts.poppins(
                            fontSize: fontSizeGymVisa,
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ),
                  ],
                ),

                // GYM VISA TEXT AND IMAGE DONE TILL HERE //

                SizedBox(height: screenHeight * 0.05),
                Row(
                  children: [
                    Center(
                      child: Stack(
                        children: [
                          Container(
                            padding: EdgeInsets.fromLTRB(30, 0, 0, 0),
                            child: Center(
                              child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.appNeon,
                                    minimumSize: Size(screenWidth * 0.55,
                                        screenHeight * 0.06),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15.0),
                                    ),
                                    elevation: 5,
                                  ),
                                  onPressed: () {
                                    Get.toNamed('/getStarted');

                                  },
                                  child: Padding(
                                    padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
                                    child: Text(
                                      'Get Started',
                                      style: GoogleFonts.poppins(
                                        color: Colors.black,
                                        fontSize: fontSizeGetStarted,
                                      ),
                                    ),
                                  )),
                            ),
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            top: 0,
                            child: Transform.rotate(
                              angle: -math.pi /
                                  2, // Rotate the icon by -90 degrees (to the left)
                              child: IconButton(
                                icon: const Icon(Icons.arrow_drop_down_circle,
                                    color: Colors.black),
                                iconSize: iconSize,
                                onPressed: () {},
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.06),
                    Container(
                      child: Text(
                        'or',
                        style: GoogleFonts.poppins(
                          color: Color(0xFFA8A8A8),
                          fontSize: fontSizeOr,
                        ),
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.03),
                    TextButton(
                      onPressed: () {
                       Get.toNamed('/login');
                      },
                      child: Container(
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.white,
                            ),
                          ),
                        ),
                        child: Text(
                          'Login',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: fontSizeLogin,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                    Expanded(child: Container()),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
}
}
