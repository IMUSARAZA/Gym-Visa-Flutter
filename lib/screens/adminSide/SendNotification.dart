import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gymvisa/const/AppColors.dart';
import 'package:gymvisa/screens/adminSide/SpecificUserNotify.dart';
import 'package:gymvisa/services/Database_Service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';



// ignore: must_be_immutable
class SendNotification extends StatefulWidget {
  List<UserWithToken> fcmToken = [];
  List userIds = [];

  SendNotification({
    Key? key, 
    required this.fcmToken,
    required this.userIds,
    
    }) : super(key: key);
  

  @override
  State<SendNotification> createState() => _SendNotificationState();
}

class _SendNotificationState extends State<SendNotification> {
  TextEditingController titleController = TextEditingController();
  TextEditingController bodyController = TextEditingController();
  User? user = FirebaseAuth.instance.currentUser!;

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
              Database_Service.addNotification(titleController.text, bodyController.text, Timestamp.now(),widget.userIds,"");
              sendNotification(titleController.text, bodyController.text, widget.fcmToken);
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
        print('Notification sent successfully to ${user.name}');
      } else {
        print('Failed to send notification to ${user.name}');
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
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
}
