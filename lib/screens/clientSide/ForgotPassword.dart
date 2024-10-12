import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gymvisa/const/AppColors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gymvisa/services/AuthServices.dart';
import 'package:gymvisa/widgets/CustomTextField.dart';
import 'package:gymvisa/widgets/CustomButton.dart';


class ForgotPassword extends StatefulWidget {
  const ForgotPassword({Key? key}) : super(key: key);

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  TextEditingController emailController = TextEditingController();

  bool emailValid = true;
  bool isLoading = false;
  String emailRegex = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';


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
                    padding: EdgeInsets.fromLTRB(screenWidth*0.08, screenHeight * 0.05, 0, 0),
                    child: Text(
                      'Forgot Password',
                      overflow: TextOverflow.clip,
                      style: GoogleFonts.poppins(
                        fontSize: 30,
                        color: AppColors.appTextColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(screenWidth*0.08, screenHeight * 0.01, 0, 0),
                    child: Text(
                      'Change your password',
                      overflow: TextOverflow.clip,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: AppColors.appTextColor,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  Center(
                    child: SizedBox(
                      width: screenWidth * 0.8,
                      child: Padding(
                        padding:
                            EdgeInsets.fromLTRB(0, screenHeight * 0.05, 0, 0),
                        child: CustomTextField(
                          controller: emailController,
                          hintText: 'Enter your email',
                          labelText: 'Email',
                          isValid: emailValid,
                          onChanged: (value) {
                            if (value.isEmpty) {
                              setState(() {
                                emailValid = false;
                              });
                            } else if (!RegExp(emailRegex).hasMatch(value)) {
                              setState(() {
                                emailValid = false;
                              });
                            } else {
                              setState(() {
                                emailValid = true;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.05),
                  Center(
                    child: CustomButton(
                      text: 'Next',
                      pad: 0,
                      color: AppColors.appNeon,
                      textcolor: Colors.black,
                      onPressed: () async {
                        setState(() {
                                  isLoading = true;
                                });
                              await Future.delayed(Duration(seconds: 2));    
                        Get.toNamed('/verifyResetEmail');
                        await AuthServices.resetPassword(emailController.text.trim(), context);
                        
                      },
                    ),
                  ),
                  Expanded(child: Container()),
                ],
              ),
            ),
          ),
        ),
    );
  }
}
