import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gymvisa/const/AppColors.dart';
import 'package:gymvisa/screens/clientSide/BMICalculated.dart';
import 'package:gymvisa/screens/clientSide/BMIDataController.dart';
import 'package:gymvisa/widgets/CustomAppBar.dart';
import 'package:gymvisa/widgets/CustomTextField.dart';
import 'package:gymvisa/widgets/CustomButton.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';

class BMI extends StatefulWidget {
  const BMI({Key? key}) : super(key: key);

  @override
  State<BMI> createState() => _BMIState();
}

class _BMIState extends State<BMI> {
  final BMIDataController bmidataController = Get.put(BMIDataController());

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double customiseFontSize = 45;

    if (screenWidth < 430) {
      customiseFontSize = 40;
    }
    if (screenWidth < 330) {
      customiseFontSize = 30;
    }

    return Scaffold(
      appBar: const CustomAppBar(title: 'Body Mass Index', showBackButton: false),
      backgroundColor: AppColors.appBackground,
      body: SingleChildScrollView(
        child: Container(
          decoration: AppTheme.getGradientBackground(),
          width: screenWidth,
          height: screenHeight,
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.fromLTRB(0, 30, 0, 0),
                width: screenWidth,
                height: screenHeight * 0.2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20.0),
                      child: Image.asset(
                        'lib/assets/dietPlan.png',
                        height: screenHeight * 0.2,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                ),
              ),
              Center(
                child: Text(
                  'Customise\n your diet plan',
                  style: GoogleFonts.poppins(
                    fontSize: customiseFontSize,
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    height: 0.95,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: screenHeight * 0.05),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: Obx(() => CustomTextField(
                      controller: bmidataController.heightController,
                      hintText: bmidataController.heightHintText.value,
                      labelText: 'Height in feet (e.g. 5.10)',
                      isValid: bmidataController.heightValid.value,
                    )),
              ),
              SizedBox(height: screenHeight * 0.03),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: Obx(() => CustomTextField(
                      controller: bmidataController.weightController,
                      hintText: bmidataController.weightHintText.value,
                      labelText: 'Weight in kilograms (e.g. 70)',
                      isValid: bmidataController.weightValid.value,
                    )),
              ),
              SizedBox(height: screenHeight * 0.03),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: Obx(() => CustomTextField(
                      controller: bmidataController.ageController,
                      hintText: bmidataController.ageHintText.value,
                      labelText: 'Age (e.g. 25)',
                      isValid: bmidataController.ageValid.value,
                    )),
              ),
              SizedBox(height: screenHeight * 0.03),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: CustomButton(
                  color: AppColors.appNeon,
                  textcolor: Colors.black,
                  text: 'Calculate BMI',
                  pad: 0,
                  onPressed: () {
                    validateInput();
                    if (bmidataController.heightValid.value &&
                        bmidataController.weightValid.value &&
                        bmidataController.ageValid.value) {
                      // Proceed to the next screen if all inputs are valid
                      PersistentNavBarNavigator.pushNewScreen(
                        context,
                        screen: BMICalculated(),
                        withNavBar: true,
                        pageTransitionAnimation: PageTransitionAnimation.cupertino,
                      );
                    }
                  },
                ),
              ),
              SizedBox(height: MediaQuery.of(context).viewInsets.bottom), // Adjusts for keyboard
            ],
          ),
        ),
      ),
      resizeToAvoidBottomInset: false,
    );
  }

  void validateInput() {
    String heightText = bmidataController.heightController.text;
    String ageText = bmidataController.ageController.text;
    String weightText = bmidataController.weightController.text;

    bool isHeightValid = num.tryParse(heightText) != null && double.parse(heightText) > 0;
    bool isAgeValid = int.tryParse(ageText) != null && int.parse(ageText) > 0 && int.parse(ageText) <= 100;
    bool isWeightValid = num.tryParse(weightText) != null && double.parse(weightText) > 0;

    if (!isHeightValid) {
      bmidataController.heightValid.value = false;
      bmidataController.heightController.text = '';
      bmidataController.heightHintText.value = 'Enter a valid height';
    } else {
      bmidataController.heightValid.value = true;
    }

    if (!isAgeValid) {
      bmidataController.ageValid.value = false;
      bmidataController.ageController.text = '';
      bmidataController.ageHintText.value = 'Enter your age (1-100)';
    } else {
      bmidataController.ageValid.value = true;
    }

    if (!isWeightValid) {
      bmidataController.weightValid.value = false;
      bmidataController.weightController.text = '';
      bmidataController.weightHintText.value = 'Enter a valid weight';
    } else {
      bmidataController.weightValid.value = true;
    }
  }
}
