import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gymvisa/const/AppColors.dart';
import 'package:gymvisa/screens/adminSide/GymInfoScreen2.dart';
import 'package:gymvisa/widgets/CustomTextField.dart';

class Test extends StatelessWidget {
  const Test({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: GymInfoScreen1(),
    );
  }
}

class GymInfoScreen1 extends StatefulWidget {
  const GymInfoScreen1({super.key});

  @override
  State<GymInfoScreen1> createState() => _GymInfoScreen1State();
}

class _GymInfoScreen1State extends State<GymInfoScreen1> {
  TextEditingController nameController = TextEditingController();
  TextEditingController subscriptionController = TextEditingController();
  TextEditingController phoneNoController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  bool nameValid = true;
  bool subscriptionValid = true;
  bool phoneValid = true;
  bool emailValid = true;
  bool descriptionValid = true;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    double enterInfoTextFontSize = 38;

    if (screenWidth < 400) {
      enterInfoTextFontSize = 35;
    }
    if (screenWidth < 350) {
      enterInfoTextFontSize = 32;
    }
    if (screenWidth < 300) {
      enterInfoTextFontSize = 29;
    }
    return Scaffold(
        backgroundColor: AppColors.appBackground,
        appBar: AppBar(
          backgroundColor: AppColors.appBackground,
          surfaceTintColor: Colors.grey,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Get.back();
            },
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                setState(() {
                  nameValid = nameController.text.isNotEmpty;
                  subscriptionValid = subscriptionController.text.isNotEmpty;
                  descriptionValid = descriptionController.text.isNotEmpty;
                  phoneValid = phoneNoController.text.isNotEmpty &&
                      phoneNoController.text.length == 11 &&
                      RegExp(r'^[0-9]+$').hasMatch(phoneNoController.text);
                  emailValid = emailController.text.isNotEmpty &&
                      RegExp(r'^[^@]+@[^@]+\.[^@]+')
                          .hasMatch(emailController.text);
                });
                if (nameValid && emailValid && descriptionValid && phoneValid) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GymInfoScreen2(
                        name: nameController.text,
                        subscription: subscriptionController.text,
                        phoneNo: phoneNoController.text,
                        email: emailController.text,
                        description: descriptionController.text,
                      ),
                    ),
                  );
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Text(
                  'Next',
                  style: GoogleFonts.poppins(
                    color: AppColors.appTextColor,
                    fontSize: 19,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
        body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: SingleChildScrollView(
            child: Center(
              child: Column(
                children: [
                  SizedBox(height: screenHeight * 0.10),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        'Enter your\nInformation',
                        style: GoogleFonts.poppins(
                          color: AppColors.appNeon,
                          fontSize: enterInfoTextFontSize,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  SizedBox(
                    width: screenWidth * 0.9,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(15, 0, 15, 10),
                      child: CustomTextField(
                        controller: nameController,
                        hintText: "Name of the Gym",
                        labelText: "Name",
                        isValid: nameValid,
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  SizedBox(
                    width: screenWidth * 0.9,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(15, 0, 15, 10),
                      child: DropdownButtonFormField<String>(
                        dropdownColor: AppColors.rowColor,
                        decoration: InputDecoration(
                          hintStyle: GoogleFonts.poppins(
                            color: Color.fromARGB(255, 168, 160, 160),
                          ),
                          hintText: "Select Subscription",
                          labelText: "Subscription",
                          labelStyle: TextStyle(color: Colors.white),
                          floatingLabelStyle: TextStyle(color: Colors.white),
                          fillColor: Colors.black,
                          filled: true,
                          disabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            borderSide:
                                BorderSide(color: Colors.white, width: 1.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            borderSide:
                                BorderSide(color: Colors.white, width: 1.0),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            borderSide: BorderSide(
                              color:
                                  subscriptionValid ? Colors.white : Colors.red,
                              width: 1.0,
                            ),
                          ),
                        ),
                        value: subscriptionController.text.isEmpty
                            ? null
                            : subscriptionController.text,
                        onChanged: (newValue) {
                          setState(() {
                            subscriptionController.text = newValue ?? '';
                            subscriptionValid =
                                true; // Reset validity when user selects a value
                          });
                        },
                        items: <String>['Standard', 'Premium']
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
                  SizedBox(height: screenHeight * 0.03),
                  SizedBox(
                    width: screenWidth * 0.9,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(15, 0, 15, 10),
                      child: CustomTextField(
                        controller: phoneNoController,
                        hintText: "Phone No. of the Gym (e.g. 03333333333)",
                        labelText: "Phone No.",
                        isValid: phoneValid,
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  SizedBox(
                    width: screenWidth * 0.9,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(15, 0, 15, 10),
                      child: CustomTextField(
                        controller: emailController,
                        hintText: "Email of the Gym",
                        labelText: "Email",
                        isValid: emailValid,
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  SizedBox(
                    width: screenWidth * 0.9,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(15, 0, 15, 10),
                      child: CustomTextField(
                        controller: descriptionController,
                        hintText: "Description of the Gym",
                        labelText: "Description",
                        isValid: descriptionValid,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
