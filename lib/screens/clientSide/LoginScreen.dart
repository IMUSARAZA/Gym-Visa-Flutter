import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gymvisa/const/AppColors.dart';
import 'package:gymvisa/services/AuthServices.dart';
import 'package:gymvisa/widgets/CustomPasswordField.dart';
import 'package:gymvisa/widgets/CustomTextField.dart';
import 'package:gymvisa/widgets/CustomButton.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  bool isLoading = false;
  bool _isEmailValid = true;
  bool _isPasswordValid = true;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  bool validatePassword(String password) {
    final passwordRegex = RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9]).{8,}$');
    return passwordRegex.hasMatch(password);
  }

  bool validateEmail(String email) {
    final emailRegex = RegExp(r'^[\w-]+(\.[\w-]+)*@[a-zA-Z0-9-]+(\.[a-zA-Z0-9-]+)*(\.[a-zA-Z]{2,})$');
    return emailRegex.hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        key: _scaffoldMessengerKey,
        appBar: AppBar(
          backgroundColor: AppColors.appBackground,
        ),
        body: SingleChildScrollView(
          child: Container(
            decoration: AppTheme.getGradientBackground(),
            width: screenWidth,
            height: screenHeight,
            child: Stack(
              children: [
                Image.asset(
                  "lib/assets/login.png",
                  width: screenWidth,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  bottom: MediaQuery.of(context).viewInsets.bottom > 0
                      ? screenHeight * 0.1 + MediaQuery.of(context).viewInsets.bottom
                      : screenHeight * 0.1,
                  left: 0,
                  right: 0,
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.1,
                        vertical: screenHeight * 0.06,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Login",
                            style: GoogleFonts.poppins(
                              fontSize: screenWidth * 0.1,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          Text(
                            "Login into your account to continue",
                            style: GoogleFonts.poppins(
                              fontSize: screenWidth * 0.03,
                              color: Colors.white,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.02),
                          CustomTextField(
                            controller: _email,
                            hintText: "Enter your e-mail",
                            labelText: "Email",
                            isValid: _isEmailValid,
                            onChanged: (value) {
                              setState(() {
                                _isEmailValid = value.isEmpty ? true : validateEmail(value);
                              });
                            },
                          ),
                          SizedBox(height: screenHeight * 0.02),
                          CustomPasswordField(
                            controller: _password,
                            hintText: "Enter your Password",
                            labelText: "Password",
                            isValid: _isPasswordValid,
                            onChanged: (value) {
                              setState(() {
                                _isPasswordValid = value.isEmpty ? true : validatePassword(value);
                              });
                            },
                            obscure: true,
                          ),
                          SizedBox(height: screenHeight * 0.02),
                          CustomButton(
                            color: AppColors.appNeon,
                            textcolor: AppColors.appBackground,
                            text: "Login",
                            pad: 0,
                            onPressed: () async {
                              if (validatePassword(_password.text) && validateEmail(_email.text)) {
                                setState(() {
                                  isLoading = true;
                                });
                                await AuthServices.signInwithEmail(_email.text, _password.text, _scaffoldMessengerKey,context);
                                print(FirebaseAuth.instance.currentUser);
                                if (mounted) {
                                  setState(() {
                                    isLoading = false;
                                  });
                                }
                              } else {
                                setState(() {
                                  _isPasswordValid = false;
                                });
                              }
                            },
                            isLoading: isLoading,
                          ),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: TextButton(
                              onPressed: () {
                                Get.toNamed('/forgotPassword');
                              },
                              child: Text(
                                "Forget Password?",
                                style: GoogleFonts.poppins(
                                  fontSize: screenWidth * 0.03,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                            ),
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
      ),
    );
  }
}
