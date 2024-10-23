import 'dart:convert';
import 'dart:ui' as ui;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gymvisa/models/OfflineVideoModel.dart';
import 'package:gymvisa/models/QRModel.dart';
import 'package:gymvisa/models/UserModel.dart';
import 'package:gymvisa/models/SubscriptionsModel.dart';
import 'package:gymvisa/models/GymModel.dart';
import 'dart:typed_data';
import 'dart:async';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:intl/intl.dart';

import '../models/Notifications.dart';

class Database_Service {
  static Future<Map<String, dynamic>> getUserDetails(String uid) async {
    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('User').doc(uid).get();
    return userDoc.data() as Map<String, dynamic>;
  }

  static Future<void> saveUser(
      String email,
      String gender,
      String name,
      String phoneNo,
      String userID,
      String fcmToken,
      String subscription) async {
    DateTime subscriptionStartDate = DateTime.now();
    DateTime subscriptionEndDate =
        subscriptionStartDate.add(Duration(days: 30));

    await FirebaseFirestore.instance.collection('User').doc(userID).set({
      'Email': email,
      'Gender': gender,
      'Name': name,
      'PhoneNo': phoneNo,
      'UserID': userID,
      'FCMToken': fcmToken,
      'Subscription': subscription,
      'SubscriptionStartDate': Timestamp.fromDate(subscriptionStartDate),
      'SubscriptionEndDate': Timestamp.fromDate(subscriptionEndDate),
    });
  }

  static Future<void> updateUserFcmToken(String email, String fcmToken) async {
    try {
      CollectionReference users = FirebaseFirestore.instance.collection('User');

      QuerySnapshot querySnapshot =
          await users.where('Email', isEqualTo: email).get();

      if (querySnapshot.docs.isNotEmpty) {
        DocumentReference userDocRef = querySnapshot.docs.first.reference;

        await userDocRef.update({'FCMToken': fcmToken});
        print('FCM token updated successfully');
      } else {
        print('User not found');
      }
    } catch (e) {
      print('Error updating FCM token: $e');
    }
  }

  static Future<List<Gym>> searchGym(String name) async {
    List<Gym> gyms = [];
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
              .collection('Gyms')
              .orderBy('name')
              .startAt([name]).endAt([name + '\uf8ff']).get();
      querySnapshot.docs.forEach((doc) {
        gyms.add(Gym.fromJson(doc.data()));
      });
    } catch (e) {
      print('Error fetching gyms: $e');
      throw e;
    }
    return gyms;
  }

  static Future<List<Gym>> getGymsBySubscription(String subscription) async {
    List<Gym> gyms = [];
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
              .collection('Gyms')
              .where('subscription', isEqualTo: subscription)
              .get();
      querySnapshot.docs.forEach((doc) {
        gyms.add(Gym.fromJson(doc.data()));
      });
    } catch (e) {
      print('Error fetching gyms by subscription: $e');
    }
    return gyms;
  }

  Future<Gym?> getGymById(String gymID) async {
    try {
      // Reference to the specific gym document using its gymID
      final gymRef = FirebaseFirestore.instance.collection('Gyms').doc(gymID);
      final gymDoc = await gymRef.get();

      // Check if the document exists
      if (gymDoc.exists) {
        // Convert the document to Gym object
        return Gym.fromJson(gymDoc.data()!);
      } else {
        print('Gym with ID $gymID not found.');
        return null;
      }
    } catch (e) {
      print('Error fetching gym by ID: $e');
      throw e;
    }
  }

  static Future<Gym?> getGymByGoogleMapsLink(String googleMapsLink) async {
  Gym? gym;
  try {
    QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await FirebaseFirestore.instance
            .collection('Gyms')
            .where('googleMapsLink', isEqualTo: googleMapsLink)
            .limit(1)
            .get(GetOptions(source: Source.server)); // Force server fetch

    if (querySnapshot.docs.isNotEmpty) {
      var data = querySnapshot.docs.first.data();
      gym = Gym.fromJson(data); // Assuming you have a fromJson method in GymModel
    }
  } catch (e) {
    print('Error fetching gym by googleMapsLink: $e');
  }
  return gym;
}


  static Future<List<Notifications>> getNotifications(
      String userId, String subscription) async {
    List<Notifications> combinedNotifs = [];

    // Query for notifications by userId
    Query queryUserIds = FirebaseFirestore.instance
        .collection('Notifications')
        .where('userIds', arrayContains: userId);

    QuerySnapshot snapshotUserIds = await queryUserIds.get();

    List<Notifications> userIdNotifs = snapshotUserIds.docs.map((doc) {
      var data = doc.data() as Map<String, dynamic>;
      return Notifications.fromJson(data, doc.id);
    }).toList();

    combinedNotifs.addAll(userIdNotifs);

    // Query for notifications by subscription
    Query querySubscription;
    if (subscription == "Premium") {
      querySubscription = FirebaseFirestore.instance
          .collection('Notifications')
          .where('subscription', whereIn: ["Premium", "Standard"]);
    } else {
      querySubscription = FirebaseFirestore.instance
          .collection('Notifications')
          .where('subscription', isEqualTo: "Standard");
    }

    QuerySnapshot snapshotSubscription = await querySubscription.get();

    List<Notifications> subscriptionNotifs =
        snapshotSubscription.docs.map((doc) {
      var data = doc.data() as Map<String, dynamic>;
      return Notifications.fromJson(data, doc.id);
    }).toList();

    combinedNotifs.addAll(subscriptionNotifs);

    final notificationsSet = <String>{};
    combinedNotifs = combinedNotifs.where((notif) {
      if (notificationsSet.contains(notif.id)) {
        return false;
      } else {
        notificationsSet.add(notif.id);
        return true;
      }
    }).toList();

    print(combinedNotifs);
    combinedNotifs.sort((a, b) => b.time.compareTo(a.time));
    return combinedNotifs;
  }

  static Future<void> addNotification(String title, String body, Timestamp time,
      List userIds, String subscription) async {
    try {
      DocumentReference docRef =
          await FirebaseFirestore.instance.collection('Notifications').add({
        'Title': title,
        'Body': body,
        'Time': time,
        'userIds': userIds,
        'subscription': subscription,
        'opened': [],
      });

      await docRef.update({'id': docRef.id});
    } catch (e) {
      print('Error adding notification: $e');
    }
  }

  static Future<bool> updateNotificationOpenedStatus(
      String notificationId, String userId) async {
    try {
      DocumentReference notificationRef = FirebaseFirestore.instance
          .collection('Notifications')
          .doc(notificationId);
      await notificationRef.update({
        'opened': FieldValue.arrayUnion([userId]),
      });

      return true;
    } catch (e) {
      print('Error updating notification opened status: $e');
    }
    return false;
  }

  static Future<List<Gym>> getAllGyms(
      {String query = '', String country = '', String city = ''}) async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('Gyms').get();

    List<Gym> gyms = snapshot.docs.map((doc) {
      return Gym.fromJson(doc.data() as Map<String, dynamic>)..id = doc.id;
    }).toList();

    if (query.isNotEmpty) {
      String queryLowercase = query.toLowerCase();
      gyms = gyms.where((gym) {
        return gym.name.toLowerCase().contains(queryLowercase) ||
            gym.address.toLowerCase().contains(queryLowercase);
      }).toList();
    }

    if (country.isNotEmpty) {
      String countryLowercase = country.toLowerCase();
      gyms = gyms
          .where((gym) => gym.country.toLowerCase() == countryLowercase)
          .toList();
    }

    if (city.isNotEmpty) {
      String cityLowercase = city.toLowerCase();
      gyms =
          gyms.where((gym) => gym.city.toLowerCase() == cityLowercase).toList();
    }

    return gyms;
  }

  static Future<List<Gym>> getSubscriptionGyms(String subscription) async {
    List<Gym> gyms = [];
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
              .collection('Gyms')
              .where("subscription", isEqualTo: subscription)
              .get();
      querySnapshot.docs.forEach((doc) {
        gyms.add(Gym.fromJson(doc.data()));
      });
    } catch (e) {
      print('Error fetching gyms: $e');
    }
    return gyms;
  }

  // QRs
  static saveQRs(String userID, String gymName, String time, QRID) async {
    await FirebaseFirestore.instance
        .collection('QRs')
        .doc(QRID)
        .set({'userID': userID, 'gymName': gymName, 'time': time});
  }

  static Future<List<QR>> getAllQRs() async {
    List<QR> qrs = [];
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance.collection('QRs').get();
      querySnapshot.docs.forEach((doc) {
        qrs.add(QR.fromJson(doc.data()));
      });
    } catch (e) {
      print('Error fetching qrs: $e');
    }
    return qrs;
  }

  static Future<void> addQR(QR qr) async {
    try {
      final qrRef = FirebaseFirestore.instance.collection('QRs').doc();
      final updatedQR = qr.copyWith(QRID: qrRef.id);

      await qrRef.set(updatedQR.toJson());
    } catch (e) {
      print('Error adding QR: $e');
      throw e;
    }
  }

  // Subscriptions
  static saveSubscriptions(
      String name, String price, String SubscriptionID) async {
    await FirebaseFirestore.instance
        .collection('Subscriptions')
        .doc(SubscriptionID)
        .set({'name': name, 'price': price});
  }

  static Future<List<User>> getAllUsers() async {
    List<User> users = [];
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance.collection('User').get();
      querySnapshot.docs.forEach((doc) {
        users.add(User.fromJson(doc.data()));
      });
    } catch (e) {
      print('Error fetching users: $e');
    }
    return users;
  }

  static Future<List<User>> searchUser(String name) async {
    List<User> usersSearch = [];
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
              .collection('User')
              .orderBy('Name')
              .startAt([name]).endAt([name + '\uf8ff']).get();
      querySnapshot.docs.forEach((doc) {
        usersSearch.add(User.fromJson(doc.data()));
      });
    } catch (e) {
      print('Error fetching users: $e');
      throw e;
    }
    return usersSearch;
  }

  static Future<List<User>> getUsersBySubscription(String subscription) async {
    List<User> users = [];
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
              .collection('User')
              .orderBy('Subscription')
              .startAt([subscription]).endAt([subscription + '\uf8ff']).get();
      querySnapshot.docs.forEach((doc) {
        users.add(User.fromJson(doc.data()));
      });
    } catch (e) {
      print('Error fetching users: $e');
      throw e;
    }
    return users;
  }

  static Future<void> addGym(Gym gym) async {
  try {
    final gymRef = FirebaseFirestore.instance.collection('Gyms').doc();

    final updatedGym = gym.copyWith(gymID: gymRef.id, qrCodeUrl: '', gymName: '');

    // Add the gym to Firestore with an empty QR code URL
    await gymRef.set(updatedGym.toJson());

    // Generate the QR code using the gymID
    final qrImageData = await _generateQRCode(updatedGym.copyWith(gymID: gymRef.id, gymName: ''));

    // Update the gym with the generated QR code
    await gymRef.update({
      'qrCodeUrl': qrImageData,
    });
  } catch (e) {
    print('Error adding gym: $e');
    throw e;
  }
}


  static Future<Map<String, int>> fetchSubscriptionCounts(
      int month, int year) async {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    Map<String, int> subscriptionCounts = {'premium': 0, 'standard': 0};

    DateTime startOfMonth = DateTime(year, month, 1);
    DateTime endOfMonth = DateTime(year, month + 1, 1);

    try {
      QuerySnapshot premiumSnapshot = await _firestore
          .collection('User')
          .where('Subscription', isEqualTo: 'Premium')
          .where('SubscriptionStartDate',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
          .where('SubscriptionStartDate',
              isLessThanOrEqualTo: Timestamp.fromDate(endOfMonth))
          .get();

      // Count the number of premium subscriptions
      subscriptionCounts['premium'] = premiumSnapshot.docs.length;

      // Query for standard subscriptions
      QuerySnapshot standardSnapshot = await _firestore
          .collection('User')
          .where('Subscription', isEqualTo: 'Standard')
          .where('SubscriptionStartDate',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
          .where('SubscriptionStartDate',
              isLessThanOrEqualTo: Timestamp.fromDate(endOfMonth))
          .get();

      // Count the number of standard subscriptions
      subscriptionCounts['standard'] = standardSnapshot.docs.length;
    } catch (e) {
      print("Error fetching subscription counts: $e");
    }

    return subscriptionCounts;
  }

  static Future<String> _generateQRCode(Gym gym) async {
  final uniqueId = gym.gymID;

  // You can use any other unique identifier or hash here instead of UUID

  // Create a short QR code data with the unique identifier
  final gymInfo = 'GymID:$uniqueId';

  // Generate QR code image as bytes
  final qrPainter = QrPainter(
    data: gymInfo,
    version: QrVersions.auto,
    errorCorrectionLevel: QrErrorCorrectLevel.M,
  );

  final double size = 400.0; // Increased size for better visibility
  final ui.Image qrImage = await qrPainter.toImage(size);

  // Create a new canvas with extra space for padding
  final padding = 60.0; // Increased padding size for better spacing
  final pictureRecorder = ui.PictureRecorder();
  final canvas = ui.Canvas(pictureRecorder);
  final paint = ui.Paint()..color = ui.Color(0xFFFFFFFF); // White color

  // Draw a white background rectangle with padding around the QR code
  canvas.drawRect(
    ui.Rect.fromLTWH(0, 0, size + padding * 2, size + padding * 2),
    paint,
  );

  // Draw the QR code image onto the canvas with padding
  canvas.drawImage(
    qrImage,
    ui.Offset(padding, padding),
    paint,
  );

  // Convert canvas to image
  final ui.Image paddedQrImage = await pictureRecorder.endRecording().toImage(
        (size + padding * 2).toInt(),
        (size + padding * 2).toInt(),
      );

  // Convert QR image to PNG bytes
  final ByteData? byteData =
      await paddedQrImage.toByteData(format: ui.ImageByteFormat.png);
  if (byteData == null) {
    throw Exception('Failed to convert QR image to ByteData.');
  }

  // Convert PNG bytes to base64 encoded string (for storing in Firestore)
  final qrImageData =
      'data:image/png;base64,${base64Encode(byteData.buffer.asUint8List())}';
  
  print('Generated QR code for gym with ID: $uniqueId');
  return qrImageData;
}

  // Subscriptions
  static Future<List<Subscription>> getAllSubscriptions() async {
    List<Subscription> subscriptions = [];
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance.collection('Subscriptions').get();
      querySnapshot.docs.forEach((doc) {
        subscriptions.add(Subscription.fromJson(doc.data()));
      });
    } catch (e) {
      print('Error fetching users: $e');
    }
    return subscriptions;
  }

  static Future<void> deleteGymById(String id) async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
              .collection('Gyms')
              .where('gymID', isEqualTo: id)
              .get();

      if (querySnapshot.docs.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('Gyms')
            .doc(querySnapshot.docs.first.id)
            .delete();
        print('Gym deleted successfully');
      } else {
        print('Gym with id $id not found');
      }
    } catch (e) {
      print('Error deleting gym: $e');
      throw e;
    }
  }

  static Future<void> updateGymById(String id, Gym updatedGym) async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
              .collection('Gyms')
              .where('gymID', isEqualTo: id)
              .get();

      if (querySnapshot.docs.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('Gyms')
            .doc(querySnapshot.docs.first.id)
            .update({
          'name': updatedGym.name,
          'subscription': updatedGym.subscription,
          'phoneNo': updatedGym.phoneNo,
          'email': updatedGym.email,
          'address': updatedGym.address,
          'city': updatedGym.city,
        });
        print('Gym updated successfully');
      } else {
        print('Gym with id $id not found');
      }
    } catch (e) {
      print('Error updating gym: $e');
      throw e;
    }
  }

  static Future<void> updatePhoneNumberById(
      String userId, String phoneNumber) async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
              .collection('User')
              .where('UserID', isEqualTo: userId)
              .get();
      if (querySnapshot.docs.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('User')
            .doc(querySnapshot.docs.first.id)
            .update({
          'PhoneNo': phoneNumber,
        });
        print('Gym updated successfully');
      } else {
        print('Gym with email $userId not found');
      }
    } catch (e) {
      print('Error updating gym: $e');
      throw e;
    }
  }

  static Future<void> updateEmailById(String userId, String email) async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
              .collection('User')
              .where('UserID', isEqualTo: userId)
              .get();
      if (querySnapshot.docs.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('User')
            .doc(querySnapshot.docs.first.id)
            .update({
          'email': email,
        });
        print('Gym updated successfully');
      } else {
        print('Gym with email $userId not found');
      }
    } catch (e) {
      print('Error updating gym: $e');
      throw e;
    }
  }

  static Future<Map<String, List<OfflineVideo>>> getAllCategoryVideos() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('OfflineVideos').get();

      Map<String, List<OfflineVideo>> categoryVideos = {};

      for (String category in categories) {
        categoryVideos[category] = [];
      }
      for (String category in categories) {
        categoryVideos[category] = [];
      }

      querySnapshot.docs.forEach((doc) {
        OfflineVideo video =
            OfflineVideo.fromJson(doc.data() as Map<String, dynamic>);

        categoryVideos[video.videoCatagory]?.add(video);
      });

      return categoryVideos;
    } catch (e) {
      print('Error fetching videos: $e');
      return {};
    }
  }

  static Future<Map<String, int>> getQrCountsForMonth(
      String selectedMonth) async {
    var snapshot = await FirebaseFirestore.instance.collection('QRs').get();
    Map<String, int> counts = {};

    for (var doc in snapshot.docs) {
      String gymAddress = doc['gymAddress'] ?? 'Unknown Address';
      String timeStr = doc['Time'] ?? '';
      if (timeStr.isEmpty) continue;
      DateTime time = DateTime.parse(timeStr);
      String month = DateFormat('MMMM').format(time);

      if (month == selectedMonth) {
        counts[gymAddress] = (counts[gymAddress] ?? 0) + 1;
      }
    }
    return counts;
  }

  Future<bool> checkUserScan(String userId) async {
    final now = DateTime.now();
    final today = DateFormat('yyyy-MM-dd').format(now);

    final querySnapshot = await FirebaseFirestore.instance
        .collection('QRs')
        .where('UserID', isEqualTo: userId)
        .get();

    for (var doc in querySnapshot.docs) {
      final data = doc.data();
      final timeField = data['Time'];

      // Debugging: print the type and value of 'Time'
      print('Time Field Type: ${timeField.runtimeType}');
      print('Time Field Value: $timeField');

      DateTime scanTime;
      try {
        scanTime = DateTime.parse(timeField); // Parse timeField directly
      } catch (e) {
        print('Error parsing timeField as DateTime: $e');
        continue; // Skip this document if parsing fails
      }

      final scanDate = DateFormat('yyyy-MM-dd').format(scanTime);

      if (scanDate == today) {
        // User has already scanned today
        return false;
      }
    }

    // User has not scanned today
    return true;
  }

  Future<Map<String, dynamic>?> getScanDataForToday(String userId) async {
    final now = DateTime.now();
    final today = DateFormat('yyyy-MM-dd').format(now);

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('QRs')
          .where('UserID', isEqualTo: userId)
          .get();

      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        final timeField = data['Time'];

        DateTime? scanTime;

        // Convert the time field to DateTime
        if (timeField is Timestamp) {
          scanTime = timeField.toDate();
        } else if (timeField is String) {
          try {
            scanTime = DateTime.parse(timeField);
          } catch (e) {
            print('Error parsing DateTime from String: $e');
            continue; // Skip this document if parsing fails
          }
        }

        if (scanTime == null) {
          continue; // Skip this document if time is not available or not valid
        }

        final scanDate = DateFormat('yyyy-MM-dd').format(scanTime);

        // Check if the scan date is today
        if (scanDate == today) {
          // Extract required fields
          final gymName = data['gymName'] ?? 'Unknown gym';
          final gymAddress = data['gymAddress'] ?? 'Unknown address';
          final gymSubscription =
              data['gymSubscription'] ?? 'Unknown subscription';

          // Return the extracted data
          return {
            'gymName': gymName,
            'gymAddress': gymAddress,
            'gymSubscription': gymSubscription,
          };
        }
      }
    } catch (e) {
      print('Error fetching scan data: $e');
    }

    return null;
  }

  Future<String?> getUserSubscription(String userId) async {
    try {
      // Fetch the document for the given user ID from the 'User' collection
      final docSnapshot =
          await FirebaseFirestore.instance.collection('User').doc(userId).get();

      if (docSnapshot.exists) {
        // Extract subscription field
        final data = docSnapshot.data();
        final subscription = data?['Subscription'] as String?;

        // Return the subscription or a default value if not available
        return subscription ?? 'No subscription found';
      } else {
        // Handle the case where the document does not exist
        return 'User document does not exist';
      }
    } catch (e) {
      print('Error fetching user subscription: $e');
      return 'Error fetching subscription';
    }
  }
}

List<String> categories = [
  'Shoulder',
  'Chest',
  'Bicep',
  'Abs',
  'Tricep',
  'Lats',
  'Lower Back',
];
