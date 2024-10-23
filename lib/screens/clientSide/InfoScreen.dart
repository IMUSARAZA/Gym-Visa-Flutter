import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gymvisa/const/AppColors.dart';
import 'package:gymvisa/services/AuthServices.dart';
import 'package:gymvisa/widgets/CustomButton.dart';
import 'package:gymvisa/widgets/CustomTextField.dart';
import 'package:gymvisa/widgets/CustomPasswordField.dart';
import 'package:google_fonts/google_fonts.dart';

class InfoScreen extends StatefulWidget {
  final String? userEmail;

  const InfoScreen({Key? key, this.userEmail}) : super(key: key);

  @override
  State<InfoScreen> createState() => _InfoScreenState();
}

class _InfoScreenState extends State<InfoScreen> {
  String? userEmail;
  @override
  void initState() {
    super.initState();
    userEmail =
        Get.arguments ?? ""; // Fallback to an empty string or handle null case
    print("Received email: $userEmail");
  }

  bool validatePassword(String password) {
    final passwordRegex = RegExp(r'^(?=.*[A-Z])(?=.*[a-z])(?=.*[0-9]).{8,}$');
    return passwordRegex.hasMatch(password);
  }

  bool _obscureTextPassword = true;
  bool _obscureTextConfirmPassword = true;

  TextEditingController nameController = TextEditingController();
  String selectedGender = 'Male';
  TextEditingController phoneNoController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  bool nameValid = true;
  bool phoneNoValid = true;
  bool passwordValid = true;
  bool confirmPasswordValid = true;
  bool isLoading = false;
  String nameHintText = 'Enter your name';
  String phoneHintText = "Phone Number";
  String passwordHintText =
      "Password should be greater than 8 characters, having at least 1 small alphabet, 1 capital alphabet and 1 digit.";
  String confirmPasswordHintText = "Confirm password";

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SingleChildScrollView(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          height: screenHeight,
          width: screenWidth,
          decoration: AppTheme.getGradientBackground(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: screenHeight * 0.3,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: screenWidth * 0.20,
                      child: Image.asset(
                        'lib/assets/logoDemo2.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                    LayoutBuilder(
                      builder:
                          (BuildContext context, BoxConstraints constraints) {
                        double fontSize = screenWidth * 0.1;
                        if (constraints.maxWidth >= 1024) {
                          fontSize = 80.0;
                        } else {
                          fontSize = screenWidth * 0.1 * 0.8;
                        }

                        return Text(
                          'GYM VISA',
                          style: GoogleFonts.poppins(
                            fontSize: fontSize,
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                          ),
                          textAlign: TextAlign.center,
                        );
                      },
                    ),
                  ],
                ),
              ),
              Container(
                constraints: BoxConstraints(
                  minHeight: screenHeight *
                      0.7, // Set a minimum height for the container
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: screenWidth * 0.9,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(15, 0, 15, 10),
                          child: CustomTextField(
                            controller: nameController,
                            hintText: nameHintText,
                            labelText: "Name",
                            isValid: nameValid,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: screenWidth * 0.9,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(15, 0, 15, 10),
                          child: Theme(
                            data: Theme.of(context).copyWith(
                              canvasColor: Colors.black,
                            ),
                            child: DropdownButtonFormField(
                              decoration: InputDecoration(
                                hintStyle: GoogleFonts.poppins(
                                  color:
                                      const Color.fromARGB(255, 168, 160, 160),
                                ),
                                hintText: "Select your gender",
                                labelStyle: GoogleFonts.poppins(
                                  color: Colors.white,
                                ),
                                floatingLabelStyle: GoogleFonts.poppins(
                                  color: Colors.white,
                                ),
                                labelText: "Gender",
                                disabledBorder: const OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15)),
                                  borderSide: BorderSide(
                                      color: Colors.white, width: 1.0),
                                ),
                                focusedBorder: const OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15)),
                                  borderSide: BorderSide(
                                      color: Colors.white, width: 1.0),
                                ),
                                enabledBorder: const OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15)),
                                  borderSide: BorderSide(
                                      color: Colors.white, width: 1.0),
                                ),
                              ),
                              value: selectedGender,
                              onChanged: (newValue) {
                                setState(() {
                                  selectedGender = newValue.toString();
                                });
                              },
                              items: <String>[
                                'Male',
                                'Female',
                                'Other'
                              ].map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(
                                    value,
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: screenWidth * 0.9,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(15, 0, 15, 10),
                          child: CustomTextField(
                            controller: phoneNoController,
                            hintText: phoneHintText,
                            labelText: "Phone No.",
                            isValid: phoneNoValid,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: screenWidth * 0.9,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(15, 0, 15, 10),
                          child: CustomPasswordField(
                            controller: passwordController,
                            hintText: passwordHintText,
                            labelText: "Password",
                            isValid: passwordValid,
                            onChanged: (value) {
                              setState(() {
                                passwordValid = value.isEmpty
                                    ? true
                                    : validatePassword(value);
                              });
                            },
                            obscure: _obscureTextPassword,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: screenWidth * 0.9,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(15, 0, 15, 10),
                          child: CustomPasswordField(
                            controller: confirmPasswordController,
                            hintText: confirmPasswordHintText,
                            labelText: "Confirm",
                            isValid: confirmPasswordValid,
                            onChanged: (value) {
                              setState(() {
                                confirmPasswordValid = value.isEmpty
                                    ? true
                                    : validatePassword(value);
                              });
                            },
                            obscure: _obscureTextConfirmPassword,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
                        child: CustomButton(
                          onPressed: () async {
                            setState(() {
                              nameValid = nameController.text.isNotEmpty;
                              phoneNoValid = phoneNoController.text.isNotEmpty;
                              passwordValid =
                                  validatePassword(passwordController.text);
                              confirmPasswordValid =
                                  confirmPasswordController.text ==
                                      passwordController.text;
                            });

                            if (nameValid &&
                                phoneNoValid &&
                                passwordValid &&
                                confirmPasswordValid) {
                              setState(() {
                                isLoading = true;
                              });

                              try {
                                await Future.delayed(
                                    Duration(seconds: 3)); // Simulate delay

                                FirebaseMessaging _firebaseMessaging =
                                    FirebaseMessaging.instance;
                                final token =
                                    await _firebaseMessaging.getToken();

                                if (token == null) {
                                  print("Error: Device token is null");
                                  setState(() {
                                    isLoading = false;
                                  });
                                  return;
                                }

                                if (userEmail == null || userEmail!.isEmpty) {
                                  print("Error: User email is null or empty");
                                  setState(() {
                                    isLoading = false;
                                  });
                                  return;
                                }

                                print("Device token: $token");

                                // Safe null check with userEmail
                                await AuthServices.signupUser(
                                  userEmail!,
                                  passwordController.text,
                                  nameController.text,
                                  selectedGender,
                                  phoneNoController.text,
                                  token,
                                  'None',
                                  context,
                                );

                                setState(() {
                                  isLoading = false; 
                                });

                                Get.toNamed('/verifyEmail');
                              } catch (e) {
                                print("Error during signup: $e");
                                setState(() {
                                  isLoading = false;
                                });
                              }
                            }
                          },
                          color: AppColors.appNeon,
                          textcolor: AppColors.appBackground,
                          text: "Enter",
                          isLoading: isLoading,
                          pad: 0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}