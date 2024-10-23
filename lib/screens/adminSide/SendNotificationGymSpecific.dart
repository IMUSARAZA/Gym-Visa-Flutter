import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:gymvisa/models/GymModel.dart';
import 'package:gymvisa/models/UserModel.dart';
import 'package:gymvisa/screens/adminSide/SpecificUserNotify.dart';
import 'package:gymvisa/services/Database_Service.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gymvisa/const/AppColors.dart';

class SendNotificationGymSpecific extends StatefulWidget {
  const SendNotificationGymSpecific({super.key});

  @override
  State<SendNotificationGymSpecific> createState() =>
      _SendNotificationGymSpecificState();
}

class _SendNotificationGymSpecificState
    extends State<SendNotificationGymSpecific> {
  List<UserWithToken> fcmToken = [];
  List userIds = [];
  TextEditingController titleController = TextEditingController();
  TextEditingController bodyController = TextEditingController();
  String selectedSubscription = 'None';
  List<Gym> gyms = [];
  String? selectedGym;

  @override
  void initState() {
    super.initState();
    fetchGyms(selectedSubscription);
  }

  Future<void> fetchGyms(String subscription) async {
    List<Gym> fetchedGyms;

    if(subscription =="Standard"){
    fetchedGyms = await Database_Service.getGymsBySubscription(subscription);
    }
    else{
      fetchedGyms = await Database_Service.getAllGyms();
    }

     setState(() {
      gyms = fetchedGyms;
      selectedGym = fetchedGyms.isNotEmpty
          ? '${fetchedGyms[0].name}, ${fetchedGyms[0].address}'
          : null;
    });
  }

  Future<void> fetchUsersBySubscription(String subscription) async {
    List<User> users = await Database_Service.getUsersBySubscription(subscription);
      setState(() {
      fcmToken = users.map((user) => UserWithToken(name: user.name, fcmToken: user.fcmToken)).toList();
      userIds = users.map((user) => user.userID).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
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
            onPressed: () {
              sendNotification(titleController.text, bodyController.text, fcmToken);
              Database_Service.addNotification(titleController.text, bodyController.text, Timestamp.now(), [],selectedSubscription);

            },
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Text(
                'Send',
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
      backgroundColor: AppColors.appBackground,
      body: SingleChildScrollView(
        child: Container(
          width: screenWidth,
          height: screenHeight,
          decoration: AppTheme.getGradientBackground(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(screenWidth * 0.05,
                    screenHeight * 0.05, 0, screenWidth * 0.05),
                child: Center(
                  child: Text(
                    'Send Notification',
                    style: GoogleFonts.poppins(
                      color: AppColors.appNeon,
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.appTextColor),
                      ),
                    child: DropdownButton<String>(
                      value: selectedSubscription,
                      items: <String>['None','Standard', 'Premium']
                          .map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedSubscription = newValue!;
                          fetchGyms(selectedSubscription);
                          fetchUsersBySubscription(selectedSubscription);
                          titleController.text = '';
                          titleController.text = 'Announcement!';
                        });
                      },
                    ),
                    ),
                    SizedBox(height: 30),
                    Container(
                      padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.appTextColor),
                      ),
                    child: DropdownButton<String>(
                      value: selectedGym,
                      items: gyms.map((Gym gym) {
                        return DropdownMenuItem<String>(
                          value: '${gym.name}, ${gym.address}',
                            child: Text('${gym.name}, ${gym.address}'),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedGym = newValue;
                          bodyController.text = '';
                          bodyController.text = newValue == null ? '' : '$newValue ';
                          titleController.text = '';
                          titleController.text = 'Announcement!';
                        });
                      },
                    ),
                    ),
                  ],
                ),
              ),
              Center(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(screenWidth * 0.05,
                      screenHeight * 0.05, screenWidth * 0.05, 0),
                  child: Container(
                    height: screenHeight * 0.1,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        hintText: 'Notification Heading',
                        hintStyle: GoogleFonts.poppins(
                          color: Colors.grey,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                      ),
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              ),
              Center(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(screenWidth * 0.05,
                      screenHeight * 0.05, screenWidth * 0.05, 0),
                  child: Container(
                    height: screenHeight * 0.3,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: TextField(
                      controller: bodyController,
                      decoration: InputDecoration(
                        hintText: 'Type your custom notification here......',
                        hintStyle: GoogleFonts.poppins(
                          color: Colors.grey,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                      ),
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void sendNotification(String title, String body, List<UserWithToken> users) async {
    final postUrl = 'https://fcm.googleapis.com/fcm/send';

    for (var user in users) {
      final data = {
        "to": user.fcmToken,
        "notification": {
          "title": title,
          "body": 'Hi, ${user.name}! $body',
          "sound": "default",
          "priority": "high",
          "channel_id": "your_channel_id",  // Consistent channel ID
        },
        "data": {
          "click_action": "FLUTTER_NOTIFICATION_CLICK",
          "title": title,
          "body": 'Hi, ${user.name}! $body',
        },
        "priority": "high",
        "content_available": true,
      };

      final headers = {
        'content-type': 'application/json',
        'Authorization': 'key=AAAA9hrQsio:APA91bE1VvABnG8AUJbqqhhVelR-qCKTqpryyKS_T556OUCs_5cMkgT_gC9Wis0vKl3CDrYe3VmNzHHEjhIgbGa9umPi9nhWrHvmeXvJbNd6gS6Ne4rm8TQ_-a5na8hWdw0mZc_AEJzf',
      };

      final response = await http.post(
        Uri.parse(postUrl),
        body: json.encode(data),
        headers: headers,
      );

      if (response.statusCode == 200) {
      print('Notification sent successfully');
      } else {
        print('Failed to send notification');
        print('Response body: ${response.body}');
      }
    }
    _showNotificationSentDialog(context);

  }

  void _showNotificationSentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.black,
          title: Text(
            "Notification Sent",
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            "Notification sent successfully to user.",
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: AppColors.appNeon,
              ),
              child: Text(
                "OK",
                style: TextStyle(color: Colors.black),
              ),
              onPressed: () {
                Get.back();
              },
            ),
          ],
        );
      },
    );
  }
}