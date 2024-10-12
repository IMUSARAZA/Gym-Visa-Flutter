// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gymvisa/const/AppColors.dart';
import 'package:gymvisa/models/GymModel.dart';
import 'package:gymvisa/models/SubscriptionsModel.dart'; // Import Subscription model
import 'package:gymvisa/services/Database_Service.dart'; // Import your Database Service
import 'package:gymvisa/widgets/MembershipsWidget.dart';

class Memberships extends StatefulWidget {
  Subscription subscriptions;
  String description;
  String userSubscription;
  Memberships({
    required this.description,
    required this.subscriptions,
    required this.userSubscription,

    Key? key}) : super(key: key);

  @override
  State<Memberships> createState() => _MembershipsState();
}

class _MembershipsState extends State<Memberships> {
  List<Gym> _gyms = []; 
  Future<List<Subscription>> subs = Database_Service.getAllSubscriptions(); // Future to hold subscription data

  @override
  void initState() {
    _fetchGyms(); // Fetch gyms data when the widget initializes
    super.initState();
  }

  Future<void> _fetchGyms() async {
    List<Gym> gyms;
    try {

      if(widget.subscriptions.name == 'Premium'){
      gyms = await Database_Service.getAllGyms();
      }
      else{
        gyms = await Database_Service.getSubscriptionGyms(widget.subscriptions.name);
      }
      setState(() {
        _gyms = gyms;
      });
    } catch (error) {
      print('Error fetching gyms: $error');
      // Handle error as needed
    }
  }



  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    Color buttonColor = widget.subscriptions.name == "Standard"
        ? Colors.white
        : AppColors.premiumColor;


    if(widget.subscriptions.name=="Silver"){
      buttonColor = AppColors.standardColor;
    }

    double GoldMembershipFontSize = 38;
    double GoldMembershipPriceFontSize = 20;

    if (screenWidth < 570) {
      GoldMembershipFontSize = 34;
      GoldMembershipPriceFontSize = 16;
    }
    if (screenWidth < 500) {
      GoldMembershipFontSize = 27;
      GoldMembershipPriceFontSize = 12;
    }
    if (screenWidth < 420) {
      GoldMembershipFontSize = 23;
      GoldMembershipPriceFontSize = 9;
    }
    if (screenWidth < 350) {
      GoldMembershipFontSize = 17;
      GoldMembershipPriceFontSize = 7;
    }
    if (screenWidth < 300) {
      GoldMembershipFontSize = 14;
      GoldMembershipPriceFontSize = 5;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.subscriptions.name} Gyms", style: GoogleFonts.poppins(),),
        centerTitle: true,
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      backgroundColor: const Color.fromARGB(255, 21, 21, 21),
      body:  SingleChildScrollView(
              child: RefreshIndicator(
                onRefresh: _fetchGyms,
                color: AppColors.appNeon,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
                      child: Container(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(15, 15, 0, 0),
                          child: Row(
                            children: [
                              Container(
                                width: screenWidth*0.4,
                                child: Text(
                                  widget.subscriptions.name,
                                  style: GoogleFonts.poppins(
                                    color: buttonColor,
                                    fontSize: GoldMembershipFontSize,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              ElevatedButton(
                                onPressed: () {
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF282828),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                    side: BorderSide(
                                      color: buttonColor,
                                      width: 1,
                                    ),
                            ),
                          ),
                                child: Text(
                                  'PKR ${widget.subscriptions.price}', // Display subscription price
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: GoldMembershipPriceFontSize,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Padding(
                    //   padding: const EdgeInsets.fromLTRB(30, 0, 0, 10),
                    //   child: Text(
                    //     'Unlock elite fitness with Gold Membership',
                    //     style: GoogleFonts.poppins(
                    //       color: Colors.white,
                    //       fontSize: GoldMembershipPriceFontSize,
                    //       decoration: TextDecoration.underline,
                    //       decorationColor: buttonColor,
                    //       decorationThickness: 2.0,
                    //     ),
                    //   ),
                    // ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        height: screenHeight * 0.61, // Adjusted height
                        child: ListView.builder(
                          itemCount: _gyms.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: MembershipsWidget(
                                color: buttonColor,
                                gym: _gyms[index],
                                rating: 4.9,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    
                    Padding(
                padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                child: Center(
                  child:
                 widget.userSubscription == "" ?
                   Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 0),
                    width: screenWidth * 0.7,
                    child: ElevatedButton(
                      onPressed: () {
                        // Navigate to payment gateway
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: buttonColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                      ),
                      child:
                       Text(
                        'Buy Now',
                        style: GoogleFonts.poppins(
                          color: Colors.black,
                        ),
                      )
                    ),
                  ):
                  Text("Currently subscribed!\nSubscription: ${widget.userSubscription}")
                ),
                            )
                  ],
                ),
              ),
            ),
        
        
      resizeToAvoidBottomInset: false,
    );
  }
}
