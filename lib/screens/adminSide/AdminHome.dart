import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get_rx/get_rx.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gymvisa/const/AppColors.dart';
import 'package:gymvisa/const/size.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:gymvisa/services/AuthServices.dart';
import 'package:gymvisa/widgets/CustomAppBar.dart';

class AdminHomeController extends GetxController {
  RxInt gymCount = 0.obs;
  RxInt totalUsers = 0.obs;
  RxInt qrScans = 0.obs;

  late final StreamSubscription gymsSubscription;
  late final StreamSubscription usersSubscription;
  late final StreamSubscription qrScansSubscription;

  @override
  void onInit() {
    super.onInit();
    _listenToGyms();
    _listenToUsers();
    _listenToQrScans();
  }

  void _listenToGyms() {
    gymsSubscription = FirebaseFirestore.instance
        .collection('Gyms')
        .snapshots()
        .listen((snapshot) {
      gymCount.value = snapshot.docs.length;
    }, onError: (e) {
      print("Error listening to gyms: $e");
    });
  }

  void _listenToUsers() {
    usersSubscription = FirebaseFirestore.instance
        .collection('User')
        .snapshots()
        .listen((snapshot) {
      print("User snapshot received. Count: ${snapshot.docs.length}");
      totalUsers.value = snapshot.docs.length;
    }, onError: (e) {
      print("Error listening to users: $e");
    });
  }

  void _listenToQrScans() {
    qrScansSubscription = FirebaseFirestore.instance
        .collection('QRs')
        .snapshots()
        .listen((snapshot) {
      qrScans.value = snapshot.docs.length;
    }, onError: (e) {
      print("Error listening to QR scans: $e");
    });
  }

  @override
  void onClose() {
    gymsSubscription.cancel();
    usersSubscription.cancel();
    qrScansSubscription.cancel();
    super.onClose();
  }
}

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  final AdminHomeController _controller = Get.put(AdminHomeController());
  double qrScansFontSize = 14;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
        
      //   elevation: 2,
      //   actions: [
      //     IconButton(
      //       icon: Icon(Icons.logout),
      //       onPressed: () {
      //         AuthServices.signOut(context);
      //       },
      //     ),
      //   ],
      //   title: Text(
      //     "GYMVISA",
      //     style: GoogleFonts.poppins(
      //         fontSize: 20,
      //         fontWeight: FontWeight.w700,
      //         color: AppColors.appNeon),
      //   ),
      // ),
      appBar: CustomAppBar(title: 'GYM VISA', showBackButton: false, actions: IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              AuthServices.signOut(context);
            },
          ),
        ),
      body: Container(
        margin: EdgeInsets.only(top: 30),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Get.toNamed("/ManageSubs");
                        },
                        child: Container(
                          padding: EdgeInsets.all(15),
                          margin: EdgeInsets.all(10),
                          width: ScreenSize.getScreenWidth(context) * 0.4,
                          decoration: BoxDecoration(
                            color: AppColors.appBackground,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.25),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Text(
                            "Manage Subscriptions",
                            style: GoogleFonts.poppins(),
                            softWrap: true,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Get.toNamed("/SendNotificationGymSpecific");
                        },
                        child: Container(
                          padding: EdgeInsets.all(15),
                          margin: EdgeInsets.all(10),
                          width: ScreenSize.getScreenWidth(context) * 0.4,
                          decoration: BoxDecoration(
                            color: AppColors.appBackground,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.25),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Text(
                            "Send Notifications",
                            style: GoogleFonts.poppins(),
                            softWrap: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Get.toNamed("/QRs");
                        },
                        child: Container(
                          padding: EdgeInsets.all(15),
                          margin: EdgeInsets.all(5),
                          width: ScreenSize.getScreenWidth(context) * 0.4,
                          height: 140,
                          decoration: BoxDecoration(
                            color: AppColors.appBackground,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.25),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Obx(() => Text(
                                    "${_controller.qrScans.value}",
                                    style: GoogleFonts.poppins(
                                      fontSize: 60,
                                      color: AppColors.appNeon,
                                      fontWeight: FontWeight.w900,
                                    ),
                                    softWrap: true,
                                  )),
                              Expanded(
                                child: Text(
                                  "QR SCANS",
                                  style: GoogleFonts.poppins(
                                    fontSize: qrScansFontSize,
                                    color: AppColors.appNeon,
                                  ),
                                  softWrap: true,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.all(10),
                margin: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: AppColors.appBackground,
                  border: Border.all(color: Colors.white),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: GestureDetector(
                  onTap: () {
                    Get.toNamed("/barChart");
                  },
                  child: Stack(
                    children: [
                      Container(
                        width: ScreenSize.getScreenWidth(context) * 0.8,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Subscriptions",
                              style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w800, fontSize: 20),
                            ),
                            Text(
                              "per month",
                              style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600, fontSize: 15),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        child: Image.asset("lib/assets/graph.png"),
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(height: 30),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      Get.toNamed("/TotalUsers");
                    },
                    child: Container(
                      padding: EdgeInsets.all(15),
                      margin: EdgeInsets.all(10),
                      width: ScreenSize.getScreenWidth(context) * 0.4,
                      height: 200,
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 47, 47, 47),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.white),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(FontAwesomeIcons.dumbbell),
                          Obx(() => Text(
                                "${_controller.totalUsers.value}",
                                style: GoogleFonts.poppins(
                                    fontSize: 40, fontWeight: FontWeight.w900),
                                softWrap: true,
                              )),
                          Text(
                            "Total Users",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                            ),
                            softWrap: true,
                          ),
                        ],
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Get.toNamed("/ManageGyms");
                    },
                    child: Container(
                      padding: EdgeInsets.all(15),
                      margin: EdgeInsets.all(10),
                      width: ScreenSize.getScreenWidth(context) * 0.4,
                      height: 200,
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 47, 47, 47),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.white),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(FontAwesomeIcons.personRunning),
                          Obx(() => Text(
                                "${_controller.gymCount.value}",
                                style: GoogleFonts.poppins(
                                    fontSize: 40, fontWeight: FontWeight.w900),
                                softWrap: true,
                              )),
                          Text(
                            "Total Gyms Registered",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                            ),
                            softWrap: true,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
