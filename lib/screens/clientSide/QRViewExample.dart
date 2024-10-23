import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as FirebaseAuth;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gymvisa/const/AppColors.dart';
import 'package:gymvisa/models/GymModel.dart';
import 'package:gymvisa/models/QRModel.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:gymvisa/services/Database_Service.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QR Code Scanner',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const QRViewExample(),
    );
  }
}

class QRViewExample extends StatefulWidget {
  const QRViewExample({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _QRViewExampleState();
}

class _QRViewExampleState extends State<QRViewExample> {
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  FirebaseAuth.User? firebaseUser;
  String? userSubscription;
  Map<String, String>? resultMap;
  Set<String> processedQRCodes = {};
  bool isVerified = false;

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller?.pauseCamera();
    }
    controller?.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Text(
              'Scan QR Code',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 20, // Adjust the font size as needed
              ),
            ),
            SizedBox(height: 4), // Space between the two lines
            Text(
              'Hold for at least 5 seconds',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 12, // Smaller font for the subtitle
                color: Colors.grey, // Dull grey color for the subtitle
              ),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 4,
            child: _buildQrView(context),
          ),
          Expanded(
            flex: 1,
            child: FittedBox(
              fit: BoxFit.contain,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  if (result != null && resultMap != null)
                    Center(
                      child: Text(
                        _getVerificationMessage(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          color: _getMessageColor(),
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),
                  Container(
                    height: 30,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        _buildFlashButton(),
                        _buildFlipCameraButton(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 200.0
        : 350.0;
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
        borderColor: Colors.red,
        borderRadius: 10,
        borderLength: 30,
        borderWidth: 10,
        cutOutSize: scanArea,
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });

    controller.scannedDataStream.listen((scanData) async {
      result = scanData;
      print('Scanned Data: ${result!.code}'); // Debug print

      resultMap = await parseQRCodeData(result!.code!);

      print('Parsed Data: $resultMap'); // Debug print

      if (resultMap != null) {
        await _processQRCode();
      }
    });

    _fetchCurrentUser();
  }

  Future<void> _fetchCurrentUser() async {
    try {
      final user = FirebaseAuth.FirebaseAuth.instance.currentUser;
      if (user != null) {
        setState(() {
          firebaseUser = user;
        });
        await _fetchUserSubscription(user.uid);
      }
    } catch (e) {
      log('Error fetching current user: $e');
    }
  }

  Future<void> _fetchUserSubscription(String uid) async {
    try {
      final userDoc =
          await FirebaseFirestore.instance.collection('User').doc(uid).get();
      if (userDoc.exists) {
        setState(() {
          userSubscription = userDoc.data()?['Subscription'] ?? '';
        });
      }
    } catch (e) {
      log('Error fetching user subscription: $e');
    }
  }

  Future<void> _processQRCode() async {
    try {
      final gymsCollection = FirebaseFirestore.instance.collection('Gyms');
      final querySnapshot = await gymsCollection.get();

      String gymName = '';
      String email = '';
      String gymSubscription = '';
      String gymAddress = '';

      for (var doc in querySnapshot.docs) {
        String? qrCodeUrl = doc['qrCodeUrl'];

        if (qrCodeUrl != null &&
            qrCodeUrl.startsWith('data:image/png;base64,')) {
          // Process the QR code because it meets the expected format
          break; // Exit the loop early since a valid QR code is found
        }
      }

      gymName = resultMap?['Name'] ?? 'Invalid name';
      email = resultMap?['Email'] ?? 'Invalid email';
      gymSubscription = resultMap?['Subscription'] ?? 'Invalid subscription';
      gymAddress = resultMap?['Address'] ?? 'Invalid Address';

      if (userSubscription == 'Premium') {
        isVerified = true;
      } else if (userSubscription == 'Standard' &&
          resultMap!['Subscription'] == 'Standard') {
        isVerified = true;
      } else if (userSubscription == 'Standard' &&
          resultMap!['Subscription'] == 'Premium') {
        isVerified = false;
      } else {
        isVerified = false;
      }

      // Check if QR code has been processed
      if (result != null && !processedQRCodes.contains(result!.code)) {
        if (gymName.isNotEmpty && gymSubscription.isNotEmpty) {
          if (firebaseUser != null && !resultMap!.containsKey('sentEmail')) {
            resultMap!['sentEmail'] = 'true'; // Mark email as sent
            processedQRCodes.add(result!.code!); // Add to processed QR codes

            // Send an email to the gym with user details
            if (isVerified == true) {
              await sendEmailToGym(
                context, // Pass context here
                gymName,
                email,
                firebaseUser!.uid,
                firebaseUser!.displayName,
                firebaseUser!.email,
              );
            }
          }

          QR newQR = QR(
            userID: firebaseUser!.uid,
            gymName: gymName,
            time: DateTime.now().toIso8601String(),
            QRID: '',
            gymSubscription: gymSubscription,
            gymAddress: gymAddress,
          );

          // Add a delay before updating the UI
          await Future.delayed(Duration(seconds: 5));

          setState(() {
            if (userSubscription == 'Premium') {
              isVerified = true;
              Database_Service.addQR(newQR);
            } else if (userSubscription == 'Standard' &&
                resultMap!['Subscription'] == 'Standard') {
              isVerified = true;
              Database_Service.addQR(newQR);
            } else if (userSubscription == 'Standard' &&
                resultMap!['Subscription'] == 'Premium') {
              isVerified = false;
              // Show unverified message
              // ScaffoldMessenger.of(context).showSnackBar(
              //   const SnackBar(
              //     content: Text(
              //         'Unverified\nUser with standard subscription cannot access Premium gyms'),
              //   ),
              // );
            }
          });
        } else {
          // Show SnackBar indicating no match found
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('No match found for the scanned QR code')),
          );
        }
      }
    } catch (e) {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error matching QR code with Firestore')),
      );
    }
  }

  bool _checkVerification() {
    if (userSubscription == 'Premium') {
      return true;
    } else if (userSubscription == 'Standard' &&
        resultMap?['Subscription'] == 'Standard') {
      return true;
    } else {
      return false;
    }
  }

  String _getVerificationMessage() {
    if (userSubscription == 'None') {
      return 'You are not subscribed to any membership.';
    }
    if (userSubscription == 'Premium') {
      return 'Verified\nWelcome to: ${resultMap?['Name']}';
    } else if (userSubscription == 'Standard' &&
        resultMap?['Subscription'] == 'Standard') {
      return 'Verified\nWelcome to: ${resultMap?['Name']}';
    } else if (userSubscription == 'Standard' &&
        resultMap?['Subscription'] == 'Premium') {
      return 'Unverified\nUser with standard subscription cannot access Premium gyms';
    } else {
      // return 'Unverified\nUser with standard subscription cannot access Premium gyms';
      return 'Unverified\nInvalid QR';
    }
  }

  Color _getMessageColor() {
    return isVerified ? Colors.green : Colors.red;
  }

  Widget _buildFlashButton() {
    return Container(
      margin: const EdgeInsets.fromLTRB(8, 5, 8, 0),
      child: ElevatedButton(
        onPressed: () async {
          await controller?.toggleFlash();
          setState(() {});
        },
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.black,
          backgroundColor: AppColors.appNeon,
        ),
        child: FutureBuilder(
          future: controller?.getFlashStatus(),
          builder: (context, snapshot) {
            return Text(
              'Flash: ${snapshot.data}',
              style: const TextStyle(color: Colors.black, fontSize: 10),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFlipCameraButton() {
    return Container(
      margin: const EdgeInsets.fromLTRB(8, 5, 8, 0),
      child: ElevatedButton(
        onPressed: () async {
          await controller?.flipCamera();
          setState(() {});
        },
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.black,
          backgroundColor: AppColors.appNeon,
        ),
        child: FutureBuilder(
          future: controller?.getCameraInfo(),
          builder: (context, snapshot) {
            if (snapshot.data != null) {
              return Text(
                'Flip camera',
                style: const TextStyle(color: Colors.black, fontSize: 10),
              );
            } else {
              return const Text(
                'loading',
                style: TextStyle(color: Colors.black, fontSize: 10),
              );
            }
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}

Future<Map<String, String>> parseQRCodeData(String data) async {
  print('Parsing QR Code Data: $data');
  Map<String, String> resultMap = {};
  String gymID = '';

  if (data.startsWith('GymID:')) {
    // Remove 'GymID:' and assign the rest of the string to gymID
    gymID = data.substring('GymID:'.length).trim();
  } else {
    throw Exception('Invalid QR code data format');
  }

  // Fetch gym data from the database using the Google Maps link
  Gym? fetchedGym = await Database_Service().getGymById(gymID);

  if (fetchedGym != null) {
    // Update resultMap with fetchedGym values
    resultMap['Name'] = fetchedGym.name;
    resultMap['Subscription'] = fetchedGym.subscription;
    resultMap['PhoneNo'] = fetchedGym.phoneNo;
    resultMap['Email'] = fetchedGym.email;
    resultMap['Description'] = fetchedGym.description;
    resultMap['City'] = fetchedGym.city;
    resultMap['Country'] = fetchedGym.country;
    resultMap['Address'] = fetchedGym.address;
    resultMap['GoogleMapsLink'] = fetchedGym.googleMapsLink;
  } else {
    resultMap['Subscription'] = 'Gym not found';
  }

  print('Parsed and Fetched Data: $resultMap');
  return resultMap;
}

Future<void> sendEmailToGym(BuildContext context, String gymName, String email,
    String userId, String? userName, String? userEmail) async {
  String username = dotenv.env['EMAIL_USERNAME'] ?? '';
  String password = dotenv.env['EMAIL_PASSWORD'] ?? '';

  final smtpServer = gmail(username, password);

  final message = Message()
    ..from = Address(username, 'Gym Visa')
    ..recipients.add(email)
    ..subject = 'Gym Access Notification'
    ..text = 'User $userName with email $userEmail has accessed $gymName.';

  try {
    final sendReport = await send(message, smtpServer);
    log('Message sent: ${sendReport.toString()}');
  } on MailerException catch (e) {
    log('Message not sent. $e');
  }
}