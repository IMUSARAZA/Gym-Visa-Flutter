import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String email;
  final String fcmToken;
  final String gender;
  final String name;
  final String phoneNo;
  final String subscription;
  final DateTime subscriptionEndDate;
  final DateTime subscriptionStartDate;
  final String userID;

  User({
    required this.email,
    required this.fcmToken,
    required this.gender,
    required this.name,
    required this.phoneNo,
    required this.subscription,
    required this.userID,
    required this.subscriptionEndDate,
    required this.subscriptionStartDate,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      email: json['Email'] ?? '',
      fcmToken: json['FCMToken'] ?? '',
      gender: json['Gender'] ?? '',
      name: json['Name'] ?? '',
      phoneNo: json['PhoneNo'] ?? '',
      userID: json['UserID'] ?? '',
      subscription: json['Subscription'] ?? '',
      subscriptionEndDate: (json['SubscriptionEndDate'] as Timestamp).toDate(),
      subscriptionStartDate: (json['SubscriptionStartDate'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Email': email,
      'FCMToken': fcmToken,
      'Gender': gender,
      'Name': name,
      'PhoneNo': phoneNo,
      'UserID': userID,
      'Subscription': subscription,
      'SubscriptionEndDate': Timestamp.fromDate(subscriptionEndDate),
      'SubscriptionStartDate': Timestamp.fromDate(subscriptionStartDate),
    };
  }
}
