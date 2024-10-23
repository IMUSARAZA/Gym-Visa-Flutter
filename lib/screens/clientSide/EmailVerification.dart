import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gymvisa/const/AppColors.dart';
import 'package:gymvisa/widgets/CustomButton.dart';
import 'package:gymvisa/services/AuthServices.dart';

class EmailVerification extends StatefulWidget {
  const EmailVerification({Key? key}) : super(key: key);

  @override
  State<EmailVerification> createState() => _EmailVerificationState();
}

class _EmailVerificationState extends State<EmailVerification> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        width: screenWidth,
        height: screenHeight,
        decoration: AppTheme.getGradientBackground(),
        child: SingleChildScrollView(
          child: Container(
            height: screenHeight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: screenHeight * 0.05),
                ClipRRect(
                  borderRadius: BorderRadius.circular(20.0),
                  child: Image.asset(
                    'lib/assets/forgetpass.png',
                    height: screenHeight * 0.5,
                    fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                      screenWidth * 0.08, screenHeight * 0.02, 0, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(right: screenHeight * 0.05),
                          child: Text(
                            'Verify your email \naddress',
                            overflow: TextOverflow.clip,
                            style: GoogleFonts.poppins(
                              fontSize: screenWidth * 0.06,
                              color: AppColors.appTextColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      Image.asset(
                        'lib/assets/Icons-Enveope.png',
                        height: 55,
                        width: 65,
                        fit: BoxFit.contain,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                      screenWidth * 0.08, screenHeight * 0.03, 0, 0),
                  child: Text(
                    'We have sent an verification email to your given email address.',
                    overflow: TextOverflow.clip,
                    style: GoogleFonts.poppins(
                      fontSize: screenWidth * 0.04,
                      color: AppColors.appTextColor,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.03),
                Center(
                  child: CustomButton(
                    text: 'Continue',
                    pad: 0,
                    color: AppColors.appNeon,
                    textcolor: Colors.black,
                    onPressed: () async {
                      
                        Get.toNamed('/login');
                        await AuthServices.signOut(context);
                        Get.snackbar('Error', 'Please Verify your Email!', backgroundColor: Colors.black, colorText: AppColors.appNeon, snackPosition: SnackPosition.TOP, animationDuration: Duration(milliseconds: 500), forwardAnimationCurve: Curves.bounceInOut);


                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                      screenWidth * 0.08, screenHeight * 0.03, 0, 0),
                  child: Row(
                    children: [
                      Text(
                        "Didn't receive the email yet? ",
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontStyle: FontStyle.normal,
                          fontSize: screenWidth * 0.04,
                          color: AppColors.appTextColor,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          AuthServices.sendVerificationEmail();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          elevation: 0,
                          padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                        ),
                        child: Text(
                          "Resend",
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                            color: AppColors.appTextColor,
                            fontSize: screenWidth * 0.04,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}