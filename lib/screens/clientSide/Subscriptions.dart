import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gymvisa/const/AppColors.dart';
import 'package:gymvisa/screens/clientSide/Memberships.dart';
import 'package:gymvisa/widgets/CustomAppBar.dart';
import 'package:gymvisa/widgets/SubscriptionsButton.dart';
import 'package:gymvisa/services/Database_Service.dart'; 
import 'package:gymvisa/models/SubscriptionsModel.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';

// ignore: must_be_immutable
class Subscriptions extends StatelessWidget {
  Subscriptions({Key? key}) : super(key: key);

  Future<List<Subscription>> _fetchSubscriptions() async {
    try {
      List<Subscription> subscriptions = await Database_Service.getAllSubscriptions();
      return subscriptions;
    } catch (error) {
      print('Error fetching subscriptions: $error');
      return []; 
    }
  }

  User? user = FirebaseAuth.instance.currentUser;
  String userSubscription = "";

  void fetchUserDetails() async{
    Map<String, dynamic> userDetails = await Database_Service.getUserDetails(user!.uid);
    userSubscription  = userDetails['Subscription'];
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    


    double subscriptionsFontSize = screenWidth < 450
        ? 35
        : screenWidth < 350
            ? 25
            : 50;

    return Scaffold(
      backgroundColor: AppColors.appBackground,
      appBar: const CustomAppBar(
        color: Colors.black,
        title: 'Packages',
        showBackButton: false,
      ),
      body: Container(
        width: screenWidth,
        height: screenHeight + 100,
        child: FutureBuilder<List<Subscription>>(
          future: _fetchSubscriptions(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator(
                color: AppColors.appNeon,
              ));
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('No subscription data available'));
            } else {
              List<Subscription> subscriptions = snapshot.data!;
        
              return Container(
                width: screenWidth,
                height: screenHeight,
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(height: screenHeight * 0.02),
                        Padding(
                          padding: EdgeInsets.fromLTRB(20, 0, 10, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Subscriptions',
                                style: GoogleFonts.poppins(
                                  fontSize: subscriptionsFontSize,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  height: 1.5,
                                ),
                              ),
                              Text(
                                "Buy one to access unlimited gyms",
                                style: GoogleFonts.poppins(
                                  fontSize: subscriptionsFontSize*0.4,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w300,
                                  height: 0.95,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.090),
                      SubscriptionsButton(
                        onPressed: () {
                          PersistentNavBarNavigator.pushNewScreen(
                            context,
                            screen: Memberships(
                              description: "Unlock elite fitness with Premium membership",
                              subscriptions: subscriptions[1],
                              userSubscription: userSubscription,
                            ),
                            withNavBar: true,
                            pageTransitionAnimation: PageTransitionAnimation.cupertino,
                          );
                        },
                        subscription: subscriptions[1],
                        description: 'Elevate your workout routine with our premium membership, featuring exclusive access to our luxury gyms and state-of-the-art equipment.',
                      ),
                      SizedBox(height: screenHeight * 0.060),
                      SubscriptionsButton(
                        onPressed: () {
                          PersistentNavBarNavigator.pushNewScreen(
                            context,
                            screen: Memberships(
                             description: "Unlock elite fitness with Silver membership",
                              subscriptions: subscriptions[0],
                              userSubscription: userSubscription,
                            ),
                            withNavBar: true,
                            pageTransitionAnimation: PageTransitionAnimation.cupertino,
                          );
                        },
                        subscription: subscriptions[0],
                        description: 'Achieve your fitness goals without breaking the bank with our Standard Membership, providing access to essential gym amenities at a reasonable price.',
                      ),
                      SizedBox(height: screenHeight * 0.05),
                      ]
                    ),
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
