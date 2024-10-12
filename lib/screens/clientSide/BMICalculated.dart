import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gymvisa/const/AppColors.dart';
import 'package:get/get.dart';
import 'package:gymvisa/screens/clientSide/BMIDataController.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gymvisa/widgets/CustomButton.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class VisibilityController extends GetxController {
  var isVisible = true.obs;

  void hideButton() {
    isVisible.value = false;
  }
}

class BMICalculated extends StatelessWidget {
  final bmidataController =
      Get.find<BMIDataController>(); // Access the controller
  final VisibilityController visibilityController =
      Get.put(VisibilityController());

  BMICalculated({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    double feets = double.parse(bmidataController.heightController.text);
    double height = feets * 0.3048;
    double weight = double.parse(bmidataController.weightController.text);
    // double age = double.parse(bmidataController.ageController.text);

    double bmiValue = weight / (height * height);
    String formattedBMI = bmiValue.toStringAsFixed(1);
    String userHealthStatus = '';
    double percentageValue = (bmiValue / 50).clamp(0.0, 1.0);

    double customiseFontSize = 40;
    double customiseFontSizeBMIValue = 20;

    if (screenWidth < 430) {
      customiseFontSize = 35;
      customiseFontSizeBMIValue = 17;
    }
    if (screenWidth < 350) {
      customiseFontSize = 25;
      customiseFontSizeBMIValue = 13;
    }

    if (bmiValue < 18.5) {
      userHealthStatus = 'Under Weight';
    } else if (bmiValue >= 18.5 && bmiValue <= 24.9) {
      userHealthStatus = 'Healthy';
    } else if (bmiValue >= 25.0 && bmiValue <= 29.9) {
      userHealthStatus = 'Over Weight';
    } else {
      userHealthStatus = 'Obesity';
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('BMI'),
        centerTitle: true,
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        padding: const EdgeInsets.fromLTRB(10, 80, 10, 0),
        decoration: AppTheme.getGradientBackground(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Center(
              child: Text(
                'Your\n Body mass Index',
                style: GoogleFonts.poppins(
                  fontSize: customiseFontSize,
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  height: 0.95,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: screenHeight * 0.10),
            Stack(
              alignment: Alignment.center,
              children: [
                Center(
                  child: SizedBox(
                    width: 200,
                    height: 200,
                    child: CircularProgressIndicator(
                      value: percentageValue,
                      strokeWidth: 10,
                      backgroundColor: Colors.transparent,
                      valueColor: AlwaysStoppedAnimation<Color>(
                          _getColorBasedOnPercentage(percentageValue)),
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    formattedBMI,
                    style: GoogleFonts.poppins(
                      fontSize: customiseFontSize,
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      height: 1,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: screenHeight * 0.05),
            Center(
              child: Text(
                userHealthStatus,
                style: GoogleFonts.poppins(
                  fontSize: customiseFontSizeBMIValue,
                  color: Colors.white,
                  height: 1,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: screenHeight * 0.05),
            Obx(() {
              return visibilityController.isVisible.value
                  ? Visibility(
                      visible: visibilityController.isVisible.value,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                        child: CustomButton(
                          color: AppColors.appNeon,
                          textcolor: Colors.black,
                          text: 'Request Diet Plan',
                          pad: 0,
                          onPressed: () {
                            // send mail
                            sendDietPlanEmail();
                            visibilityController.hideButton();
                          },
                        ),
                      ),
                    )
                  : Visibility(
                      visible: !visibilityController.isVisible.value,
                      child: Text(
                        'Our nutritionist will prepare your\ncustomised diet plan and\nget back to you shortly.',
                        style: GoogleFonts.poppins(
                          fontSize: customiseFontSizeBMIValue,
                          color: Colors.white,
                          height: 1,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    );
            }),
          ],
        ),
      ),
    );
  }
}

Color _getColorBasedOnPercentage(double percentage) {
  if (percentage < 0.37) {
    return Colors.red;
  } else if (percentage < 0.498) {
    return Colors.green;
  } else if (percentage < 0.598) {
    return AppColors.appNeon;
  } else {
    return Colors.red;
  }
}


void sendDietPlanEmail() async {
  final User user = FirebaseAuth.instance.currentUser!;
  String? userName = user.displayName;
  String? userEmail = user.email;

  // Assuming you have the nutritionist's email stored in environment variables
  final String nutritionistEmail = dotenv.env['NUTRITIONIST_EMAIL']!;

  // Calculate BMI again or fetch from the controller if available
  final bmidataController = Get.find<BMIDataController>();
  double feets = double.parse(bmidataController.heightController.text);
  double height = feets * 0.3048;
  double weight = double.parse(bmidataController.weightController.text);
  double age = double.parse(bmidataController.ageController.text);
  double bmiValue = weight / (height * height);
  String formattedBMI = bmiValue.toStringAsFixed(1);

  final googleSmtp =
      gmail(dotenv.env['GOOGLE_EMAIL']!, dotenv.env['GOOGLE_PASSWORD']!);

  final messageToUser = Message()
    ..from = Address(dotenv.env['GOOGLE_EMAIL']!, 'GYM VISA!')
    ..recipients.add(userEmail)
    ..subject = 'Diet Plan Request 😀'
    ..text =
        'Hi $userName!.\nWe have received the request for your customized diet plan. Our nutritionist will thoroughly work on it and we will get back to you within 2-3 business days.\nThank you for being with us on this amazing fitness journey.';

  final messageToNutritionist = Message()
    ..from = Address(dotenv.env['GOOGLE_EMAIL']!, 'GYM VISA!')
    ..recipients.add(nutritionistEmail)
    ..subject = 'New Diet Plan Request'
    ..text =
        'A new diet plan request has been received.\n\nUser Name: $userName\nUser Email: $userEmail\nHeight: $height m\nWeight: $weight kg\nAge: $age years\nBMI: $formattedBMI';

  try {
    final sendReportUser = await send(messageToUser, googleSmtp);
    print('Message sent to user: ' + sendReportUser.toString());

    final sendReportNutritionist = await send(messageToNutritionist, googleSmtp);
    print('Message sent to nutritionist: ' + sendReportNutritionist.toString());
  } on MailerException catch (e) {
    print('Message not sent.');
    for (var p in e.problems) {
      print('Problem: ${p.code}: ${p.msg}');
    }
  }
}