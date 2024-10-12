import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BMIDataController extends GetxController {
  TextEditingController heightController = TextEditingController();
  TextEditingController weightController = TextEditingController();
  TextEditingController ageController = TextEditingController();

  RxBool heightValid = true.obs; // Make it observable
  RxBool weightValid = true.obs; // Make it observable
  RxBool ageValid = true.obs; // Make it observable

  RxString heightHintText = 'Height'.obs; // Make it observable
  RxString weightHintText = 'Weight'.obs;
  RxString ageHintText = 'Age'.obs;

  @override
  void onClose() {
    heightController.dispose();
    weightController.dispose();
    ageController.dispose();
    super.onClose();
  }
}
