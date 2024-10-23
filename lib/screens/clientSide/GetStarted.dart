import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gymvisa/const/AppColors.dart';
import 'package:gymvisa/services/AuthServices.dart';
import 'package:gymvisa/widgets/CustomButton.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/cupertino.dart';

class GetStarted extends StatelessWidget {
  GetStarted({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.appBackground,
        automaticallyImplyLeading: false,

      ),
      backgroundColor: AppColors.appBackground,
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          double screenWidth = constraints.maxWidth;
          double screenHeight = constraints.maxHeight;

          return Container(
            width: screenWidth,
            height: screenHeight,
            decoration: AppTheme.getGradientBackground(),
            child: Stack(
              children: [
                Image.asset(
                  "lib/assets/getStarted.png",
                  width: screenWidth,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  bottom: screenHeight * 0.1,
                  left: 0,
                  right: 0,
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.1,
                        vertical: screenHeight * 0.02,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Let's get started!",
                            style: GoogleFonts.poppins(
                              fontSize: screenWidth * 0.08,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.02),
                          CustomButton(
                            pad: screenWidth * 0.05,
                            color: AppColors.appNeon,
                            text: "Sign Up with Email",
                            textcolor: Colors.black,
                            onPressed: () {
                              Get.toNamed('/signUp');
                            },
                            icon: CupertinoIcons.mail,
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          if (Theme.of(context).platform == TargetPlatform.iOS)
                            Column(
                              children: [
                                CustomButton(
                                  color: Colors.black,
                                  text: "Sign Up with Apple",
                                  pad: screenWidth * 0.04,
                                  textcolor: Colors.white,
                                  onPressed: () => {},
                                  imgIcon: Image.asset(
                                    'lib/assets/apple_logo.png',
                                    width: screenWidth * 0.04,
                                    height: screenHeight * 0.03,
                                  ),
                                ),
                                SizedBox(height: screenHeight * 0.01),
                                CustomButton(
                                  color: Colors.white,
                                  text: "Sign Up with Google",
                                  pad: screenWidth * 0.01,
                                  textcolor: Colors.black,
                                  onPressed: () {
                                    AuthServices.signInWithGoogle(context);
                                    
                                  },
                                  imgIcon: Image.asset(
                                    'lib/assets/google_logo.png',
                                    width: screenWidth * 0.1,
                                    height: screenHeight * 0.2,
                                  ),
                                ),
                              ],
                            )
                          else
                            CustomButton(
                              color: Colors.white,
                              text: "Sign Up with Google",
                              pad: screenWidth * 0.01,
                              onPressed: () {
                                AuthServices.signInWithGoogle(context);
                              },
                              textcolor: Colors.black,
                              imgIcon: Image.asset(
                                'lib/assets/google_logo.png',
                                width: screenWidth * 0.1,
                                height: screenHeight * 0.2,
                              ),
                            ),
                          SizedBox(height: screenHeight * 0.01),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
