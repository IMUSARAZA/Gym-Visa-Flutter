import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gymvisa/const/AppColors.dart';
import 'package:gymvisa/widgets/CustomTextField.dart';
import 'package:gymvisa/widgets/CustomButton.dart';

class SignUp extends StatefulWidget {
  const SignUp({Key? key}) : super(key: key);

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  TextEditingController _email = TextEditingController();
  
  bool _isEmailValid = true;
  bool isLoading = false;


  bool validateEmail(String email) {
    final emailRegex = RegExp(r'^[\w-]+(\.[\w-]+)*@[a-zA-Z0-9-]+(\.[a-zA-Z0-9-]+)*(\.[a-zA-Z]{2,})$');
    return emailRegex.hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      
      body: SingleChildScrollView(
        child: Container(
          decoration: AppTheme.getGradientBackground(),
          width: screenWidth,
          height: screenHeight,
          child: Stack(
            children: [
              Image.asset(
                "lib/assets/signUp.png",
                width: screenWidth,
                fit: BoxFit.cover,
              ),
              Positioned(
                bottom: MediaQuery.of(context).viewInsets.bottom > 0
                      ? screenHeight * 0.1 +
                          MediaQuery.of(context).viewInsets.bottom
                      : screenHeight * 0.1,
                left: 0,
                right: 0,
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.1,
                      vertical: screenHeight * 0.07,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Signup",
                          style: GoogleFonts.poppins(
                            fontSize: screenWidth * 0.1,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.01),
                        Text(
                          "To get started, enter your email",
                          style: GoogleFonts.poppins(
                            fontSize: screenWidth * 0.03,
                            color: Colors.white,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        CustomTextField(
                          controller: _email,
                          hintText: "Enter your email",
                          labelText: "Email",
                          isValid: _isEmailValid,
                          onChanged: (value) {
                            setState(() {
                              _isEmailValid = value.isEmpty ? true : validateEmail(value);
                            });
                          },
                        ),
                        SizedBox(height: screenHeight * 0.03),
                        CustomButton(
                          color: AppColors.appNeon,
                          textcolor: AppColors.appBackground,
                          text: "Signup",
                          pad: 0,
                          onPressed: () async {
                            if(validateEmail(_email.text)){
                              
                              setState(() {
                                  isLoading = true;
                                });
                              await Future.delayed(Duration(seconds: 2));      
                              Get.toNamed('/infoScreen', arguments: _email.text);
                            }
                            else{
                              setState(() {
                                _isEmailValid = false;
                              });
                            }
                          },
                          isLoading: isLoading,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      resizeToAvoidBottomInset: false,
    );
  }
}
