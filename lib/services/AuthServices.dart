import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:gymvisa/const/AppColors.dart';
import 'package:gymvisa/main.dart';
import 'package:gymvisa/models/OfflineVideoModel.dart';
import 'package:gymvisa/screens/clientSide/ResetEmailVerification.dart';
import 'package:gymvisa/services/Database_Service.dart';
import 'package:path_provider/path_provider.dart';

bool isVideosCached = false;

class AuthServices {
  static final GoogleSignIn _googleSignIn = GoogleSignIn();

  static Future<void> signupUser(
    String email,
    String password,
    String name,
    String gender,
    String phoneNo,
    String fcmToken,
    String Subscription,
    BuildContext context,
  ) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      await FirebaseAuth.instance.currentUser!.updateDisplayName(name);
      await FirebaseAuth.instance.currentUser!.verifyBeforeUpdateEmail(email);
      await Database_Service.saveUser(
        email,
        gender,
        name,
        phoneNo,
        userCredential.user!.uid,
        fcmToken,
        Subscription,
      );

      await sendVerificationEmail();

      Get.snackbar('Success', 'Verification Email has been sent!', backgroundColor: Colors.black, colorText: AppColors.appNeon, snackPosition: SnackPosition.TOP, animationDuration: Duration(milliseconds: 500), forwardAnimationCurve: Curves.bounceInOut);    
      Get.toNamed('/EmailVerification');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        Get.snackbar('Error', 'Password provided is too weak!', backgroundColor: Colors.black, colorText: AppColors.appNeon, snackPosition: SnackPosition.TOP, animationDuration: Duration(milliseconds: 500), forwardAnimationCurve: Curves.bounceInOut);
      } else if (e.code == 'email-already-in-use') {
        Get.snackbar('Error', 'Email provided already exists!', backgroundColor: Colors.black, colorText: AppColors.appNeon, snackPosition: SnackPosition.TOP, animationDuration: Duration(milliseconds: 500), forwardAnimationCurve: Curves.bounceInOut);
      }
      else{
        Get.snackbar('Error', 'An error occurred. Please try again. Error code: ${e.code}', backgroundColor: Colors.black, colorText: Colors.red, snackPosition: SnackPosition.TOP, animationDuration: Duration(milliseconds: 500), forwardAnimationCurve: Curves.bounceInOut);
      }
    }
  }

  static Future<void> signOut(BuildContext context) async {
    Get.toNamed('/onboarding');
    FirebaseAuth _auth = FirebaseAuth.instance;
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  static Future<void> resetPassword(
    String email,
    BuildContext context,
  ) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      Get.snackbar('Success', 'We have sent you a password reset link on your email!', backgroundColor: Colors.black, colorText: AppColors.appNeon, snackPosition: SnackPosition.TOP, animationDuration: Duration(milliseconds: 500), forwardAnimationCurve: Curves.bounceInOut);

      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ResetEmailVerification(userEmail: email)),
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == "user-not-found") {
        Get.snackbar('Error', 'No user found for this email!', backgroundColor: Colors.black, colorText: AppColors.appNeon, snackPosition: SnackPosition.TOP, animationDuration: Duration(milliseconds: 500), forwardAnimationCurve: Curves.bounceInOut);

      } else {
        print('An error occurred: $e');
      }
    }
  }

  static Future<UserCredential> signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return Future.error('Sign in aborted by user');
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
            Get.snackbar('Welcome, ${googleUser.displayName}', 'You are now logged in!', backgroundColor: Colors.black, colorText: AppColors.appNeon, snackPosition: SnackPosition.TOP, animationDuration: Duration(milliseconds: 500), forwardAnimationCurve: Curves.bounceInOut);


      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      //  For token Updation in Database //

      final _firebaseMessaging = FirebaseMessaging.instance;
      final token = await _firebaseMessaging.getToken();
      print("FCM token: $token");

      await Database_Service.updateUserFcmToken(
          userCredential.user!.email!, token!);

      // ignore: unused_local_variable
      NotificationSettings settings =
          await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      setupFirebaseMessaging();
      requestStoragePermission();

      Map<String, List<OfflineVideo>> offlineVideosList =
          await Database_Service.getAllCategoryVideos();

      await cacheVideos(offlineVideosList);

      Get.toNamed('/home');
      return userCredential;
    } catch (e) {
      print('Error during Google sign-in: $e');
      Get.snackbar('Error', 'Google sign-in failed: $e', backgroundColor: Colors.black, colorText: AppColors.appNeon, snackPosition: SnackPosition.TOP, animationDuration: Duration(milliseconds: 500), forwardAnimationCurve: Curves.bounceInOut);
      return Future.error('Google sign-in failed: $e');
    }
  }

 static Future<void> signInwithEmail(
  String email,
  String password,
  GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey,
  BuildContext context
) async {
  try {
    final UserCredential userCredential = await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password);
    final User user = userCredential.user!;

     if (user.emailVerified) {
        if (user.email == "fa21-bcs-082@cuilahore.edu.pk") {
          Get.toNamed('/adminHome');
        } else {
          Get.toNamed('/home');
        }

      Get.snackbar('Welcome, ${user.displayName}', 'You are now logged in!', backgroundColor: Colors.black, colorText: AppColors.appNeon, snackPosition: SnackPosition.TOP, animationDuration: Duration(milliseconds: 500), forwardAnimationCurve: Curves.bounceInOut);

      final _firebaseMessaging = FirebaseMessaging.instance;
      final token = await _firebaseMessaging.getToken();
      print("FCM token: $token");

      await Database_Service.updateUserFcmToken(email, token!);

      // ignore: unused_local_variable
      NotificationSettings settings =
          await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      setupFirebaseMessaging();
      requestStoragePermission();

      Map<String, List<OfflineVideo>> offlineVideosList =
          await Database_Service.getAllCategoryVideos();

      await cacheVideos(offlineVideosList);
    } else if (!user.emailVerified) {

      Get.snackbar('Error', 'Please Verify your Email!', backgroundColor: Colors.black, colorText: Colors.red, snackPosition: SnackPosition.TOP, animationDuration: Duration(milliseconds: 500), forwardAnimationCurve: Curves.bounceInOut);
    
      Get.toNamed('/EmailVerification');
    } else {


    Get.snackbar('Error', 'Wrong Email or Password', backgroundColor: Colors.black, colorText: Colors.red, snackPosition: SnackPosition.TOP, animationDuration: Duration(milliseconds: 500), forwardAnimationCurve: Curves.bounceInOut);
    
    }
  } on FirebaseAuthException catch (e) {
    if (e.code == 'user-not-found') {

    Get.snackbar('Error', 'No User found for that Email', backgroundColor: Colors.black, colorText: Colors.red, snackPosition: SnackPosition.TOP, animationDuration: Duration(milliseconds: 500), forwardAnimationCurve: Curves.bounceInOut);    
    } else if (e.code == 'wrong-password') {
    Get.snackbar('Error', 'Wrong Email or Password', backgroundColor: Colors.black, colorText: Colors.red, snackPosition: SnackPosition.TOP, animationDuration: Duration(milliseconds: 500), forwardAnimationCurve: Curves.bounceInOut);    
    } else {
    Get.snackbar('Error', 'An error occurred. Please try again. Error code: ${e.code}', backgroundColor: Colors.black, colorText: Colors.red, snackPosition: SnackPosition.TOP, animationDuration: Duration(milliseconds: 500), forwardAnimationCurve: Curves.bounceInOut);    
      
    }
  }
}


  static Future<void> sendVerificationEmail() async {
    try {
      final user = FirebaseAuth.instance.currentUser!;
      await user.sendEmailVerification();
    } catch (e) {
      print(e);
    }
  }
}

// Offline video work
Future<void> cacheVideos(Map<String, List<OfflineVideo>> videos) async {
  await _downloadVideosLocally(videos);

  final DefaultCacheManager cacheManager = DefaultCacheManager();

  Map<String, dynamic> dataToCache = {};
  videos.forEach((key, value) {
    dataToCache[key] = value
        .map((video) => {
              'videoCategory': video.videoCatagory,
              'videoDescription': video.videoDescription,
              'videoDuration': video.videoDuration,
              'videoTitle': video.videoTitle,
              'videoURL': video.videoURL,
              'videoPath': video.videoPath
            })
        .toList();
  });

  final encodedData = json.encode(dataToCache);
  await cacheManager.putFile(
      'videos_cache', Uint8List.fromList(encodedData.codeUnits),
      fileExtension: 'json');

  isVideosCached = true;
  print('Videos cached successfully');
}

Future<void> _downloadVideosLocally(
    Map<String, List<OfflineVideo>> videos) async {
  for (List<OfflineVideo> videoList in videos.values) {
    for (OfflineVideo video in videoList) {
      String videoUrl = video.videoURL;
      String fileName =
          Uri.decodeComponent(videoUrl.split('/').last.split('?').first);
      print('Downloading video: $fileName from URL: $videoUrl');
      String filePath = await _downloadFile(videoUrl, fileName);
      video.videoPath = filePath;
    }
  }
}

Future<String> _downloadFile(String url, String fileName) async {
  String savePath;

  if (Platform.isIOS) {
    final directory = await getApplicationDocumentsDirectory();
    savePath = '${directory.path}/$fileName';
  } else if (Platform.isAndroid) {
    final directory = await getExternalStorageDirectory();
    final fullPath = '${directory!.path}/GymVisaVideos';
    await Directory(fullPath).create(recursive: true);
    savePath = '$fullPath/$fileName';
  } else {
    throw Exception('Platform not supported');
  }

  String filePath = savePath;
  print('Saving file to path: $filePath');

  if (await File(filePath).exists()) {
    print('File already exists at $filePath');
    return filePath;
  }

    try {
      final response = await Dio().download(url, filePath);
      if (response.statusCode == 200) {
        print('File downloaded and saved to $filePath');
        return filePath;
      } else {
        throw Exception('Failed to download video');
      }
    } catch (e) {
      print('Error downloading file: $e');
      return '';
    }

}
