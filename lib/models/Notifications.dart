import 'package:cloud_firestore/cloud_firestore.dart';

class Notifications {
  final String id;
  final List userIds;
  final String title, body, subscription;
  List opened;
  final DateTime time;

  Notifications({
    required this.id,
    required this.userIds,
    required this.title,
    required this.opened,
    required this.body,
    required this.time,
    required this.subscription,
  });

  factory Notifications.fromJson(Map<String, dynamic> json, String docId) {
    return Notifications(
      userIds: json['userIds'],
      id: docId,
      opened:json['opened']?? [],
      title: json['Title'] ?? '',
      subscription: json['subscription'] ?? '',
      body: json['Body'] ?? '',
      time: (json['Time'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson(String docId) {
    return {
      'Title': title,
      'userIds':userIds,
      'subscription': subscription,
      'Body': body,
      'id': docId,
      'opened':opened,
      'Time': Timestamp.fromDate(time),
    };
  }


}
