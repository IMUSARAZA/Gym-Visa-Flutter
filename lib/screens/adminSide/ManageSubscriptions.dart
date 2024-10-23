import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gymvisa/const/AppColors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gymvisa/models/SubscriptionsModel.dart';
import 'package:gymvisa/services/Database_Service.dart';



class ManageSubscriptions extends StatefulWidget {
  const ManageSubscriptions({Key? key});

  @override
  State<ManageSubscriptions> createState() => _ManageSubscriptionsState();
}

class _ManageSubscriptionsState extends State<ManageSubscriptions> {
  String? selectedValue;
  late TextEditingController priceController;
  String price = '';
  String? name;

  @override
  void initState() {
    super.initState();
    priceController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    double manageSubscriptionsFontSize = 38;
    double addNewPriceFontSize = 18;

    if (screenWidth < 400) {
      manageSubscriptionsFontSize = 35;
      addNewPriceFontSize = 16;
    }
    if (screenWidth < 350) {
      manageSubscriptionsFontSize = 32;
      addNewPriceFontSize = 14;
    }
    if (screenWidth < 300) {
      manageSubscriptionsFontSize = 29;
      addNewPriceFontSize = 12;
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
              String enteredPrice = priceController.text;
              print(enteredPrice);
              print(selectedValue);

              if (selectedValue != null && enteredPrice.isNotEmpty) {
                try {
                  FirebaseFirestore firebaseFirestore =
                      FirebaseFirestore.instance;

                  QuerySnapshot querySnapshot = await firebaseFirestore
                      .collection('Subscriptions')
                      .where('name', isEqualTo: selectedValue)
                      .limit(
                          1) 
                      .get();

                  if (querySnapshot.docs.isNotEmpty) {
                    DocumentSnapshot documentSnapshot =
                        querySnapshot.docs.first;
                    DocumentReference subscriptionRef = firebaseFirestore
                        .collection('Subscriptions')
                        .doc(documentSnapshot.id);

                    await subscriptionRef.update({
                      'price': enteredPrice,
                    });

                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Success'),
                          content: Text('Price updated successfully.'),
                          actions: <Widget>[
                            TextButton(
                              child: Text('OK'),
                              onPressed: () {
                                Get.back();
                              },
                            ),
                          ],
                        );
                      },
                    );

                    print('Price updated successfully.');
                  } else {
                    print('No document found with name: $selectedValue');
                  }
                } catch (e) {
                  print('Error updating price: $e');
                  // Show error popup
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Error'),
                        content: Text(
                            'Failed to update price. Please try again later.'),
                        actions: <Widget>[
                          TextButton(
                            child: Text('OK'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                }
              } else {
                print('Please select a subscription and enter a price.');
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Text(
                'Update',
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
      body: Center(
        child: Column(
          children: [
            SizedBox(height: screenHeight * 0.10),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Manage\nSubscriptions',
                  style: GoogleFonts.poppins(
                    color: AppColors.appNeon,
                    fontSize: manageSubscriptionsFontSize,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.03),
            DropdownButtonFormField(
              dropdownColor: AppColors.rowColor,
              decoration: InputDecoration(
                hintStyle: GoogleFonts.poppins(
                  color: AppColors.rowColor,
                ),
                hintText: "Select Subscription",
                labelStyle: GoogleFonts.poppins(
                  color: Colors.white,
                ),
                floatingLabelStyle: GoogleFonts.poppins(
                  color: Colors.white,
                ),
                labelText: "Subscription:",
                fillColor: AppColors.rowColor,
                filled: true,
                disabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white, width: 1.0),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white, width: 1.0),
                ),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.rowColor, width: 1.0),
                ),
              ),
              value: selectedValue,
              onChanged: (newValue) async {
                setState(() {
                  selectedValue = newValue.toString();
                });
                // Fetch the subscriptions and find the selected subscription
                List<Subscription> subscriptions =
                    await Database_Service.getAllSubscriptions();
                Subscription? selectedSubscription;
                for (var subscription in subscriptions) {
                  if (subscription.name == selectedValue) {
                    selectedSubscription = subscription;
                    break;
                  }
                }

                if (selectedSubscription != null) {
                  setState(() {
                    priceController.text =
                        selectedSubscription!.price.toString();
                  });
                } else {
                  setState(() {
                    priceController.clear();
                  });
                }
              },
              items: <String>['Premium','Standard']
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
            SizedBox(height: screenHeight * 0.05),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
                  child: Text(
                    'Add new price of the\nsubscription:',
                    style: GoogleFonts.poppins(
                      color: AppColors.appTextColor,
                      fontSize: addNewPriceFontSize,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(0, 0, 20, 0),
                  width: screenWidth * 0.4,
                  child: TextField(
                    controller: priceController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(color: Colors.white, width: 1.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.0),
                        borderSide: BorderSide(color: Colors.white, width: 1.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.0),
                        borderSide: BorderSide(color: Colors.white, width: 1.0),
                      ),
                      filled: true,
                      fillColor: AppColors.rowColor,
                      prefixText: 'PKR: ',
                      prefixStyle: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                      hintText: 'New Price',
                      hintStyle: GoogleFonts.poppins(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
