import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gymvisa/const/AppColors.dart';
import 'package:gymvisa/widgets/CustomTextField.dart';
import 'package:gymvisa/services/Database_Service.dart';

class InfoScreenForGsignIn extends StatefulWidget {
  final String? userEmail;
  final String? userName;

  const InfoScreenForGsignIn({Key? key, this.userEmail, this.userName}) : super(key: key);

  @override
  State<InfoScreenForGsignIn> createState() => _InfoScreenForGsignInState();
}

class _InfoScreenForGsignInState extends State<InfoScreenForGsignIn> {
  String selectedGender = 'Male';
  TextEditingController phoneNoController = TextEditingController();

  bool phoneNoValid = true;
  bool isLoading = false;

  String phoneHintText = "Phone Number";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: AppTheme.getGradientBackground(),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.fromLTRB(0, 60, 0, 0),
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.3,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 1,
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.20,
                        child: Image.asset(
                          'lib/assets/logo.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: LayoutBuilder(
                        builder:
                            (BuildContext context, BoxConstraints constraints) {
                          double fontSize = MediaQuery.of(context).size.width *
                              0.1; // Default font size

                          if (constraints.maxWidth >= 1024) {
                            fontSize =
                                80.0; // If screen width is 1024 pixels or more, set font size to 80
                          } else {
                            // Calculate font size dynamically based on the screen width
                            fontSize = MediaQuery.of(context).size.width *
                                0.1 *
                                0.8; // Adjust the factor as needed
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
                    ),
                  ],
                ),
              ),
              Center(
                child: Column(
                  children: [
                    SizedBox(
                      // gender dropdown
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(30, 10, 40, 10),
                        child: Theme(
                          data: Theme.of(context).copyWith(
                            canvasColor: Colors.black,
                          ),
                          child: DropdownButtonFormField(
                            decoration: InputDecoration(
                              hintStyle: GoogleFonts.poppins(
                                color: const Color.fromARGB(255, 168, 160, 160),
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
                                borderSide:
                                    BorderSide(color: Colors.white, width: 1.0),
                              ),
                              focusedBorder: const OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(15)),
                                borderSide:
                                    BorderSide(color: Colors.white, width: 1.0),
                              ),
                              enabledBorder: const OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(15)),
                                borderSide:
                                    BorderSide(color: Colors.white, width: 1.0),
                              ),
                            ),
                            value: selectedGender,
                            onChanged: (newValue) {
                              setState(() {
                                selectedGender = newValue.toString();
                              });
                            },
                            items: <String>['Male', 'Female', 'Other']
                                .map<DropdownMenuItem<String>>((String value) {
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
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(30, 0, 40, 10),
                        child: CustomTextField(
                          controller: phoneNoController,
                          hintText: phoneHintText,
                          labelText: "Phone No.",
                          isValid: phoneNoValid,
                        ),
                      ),
                    ),
                    SizedBox(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(30, 10, 40, 10),
                        child: ElevatedButton(
                          onPressed: () async {
                            if (phoneNoController.text.isEmpty) {
                              setState(() {
                                phoneNoValid = false;
                                phoneHintText = 'Phone number (Required)';
                              });
                            } else {
                              setState(() {
                                phoneNoValid = true;
                              });
                            }

                            if (phoneNoValid) {
                              print('Gender: $selectedGender');
                              print('Phone Number: ${phoneNoController.text}');

                              setState(() {
                                isLoading = true;
                              });

                              await Future.delayed(Duration(seconds: 2));

                              final user = FirebaseAuth.instance.currentUser!;
                              FirebaseMessaging _firebaseMessaging =
                                  FirebaseMessaging.instance;
                              final token = await _firebaseMessaging.getToken();
                              print("device token: $token");
                              Database_Service.saveUser(
                                widget.userEmail!,
                                selectedGender,
                                widget.userName!,
                                phoneNoController.text,
                                user.uid,
                                token!,
                                'None',
                              );

                              if (mounted) {
                                setState(() {
                                  isLoading = false;
                                });
                              }

                              Get.toNamed('/home');
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.appNeon,
                            minimumSize: Size(
                                MediaQuery.of(context).size.width * 0.8, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          child: isLoading
                              ? CircularProgressIndicator(
                                  color: Colors.black,
                                )
                              : Text(
                                  'Enter',
                                  style: GoogleFonts.poppins(
                                    fontSize: 20,
                                    color: Colors.black,
                                  ),
                                ),
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
    );
  }
}
