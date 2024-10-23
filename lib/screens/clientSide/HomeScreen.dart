// ignore_for_file: unused_local_variable

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gymvisa/const/AppColors.dart';
import 'package:gymvisa/services/AuthServices.dart';
import 'package:gymvisa/widgets/Gym.dart';

import '../../models/GymModel.dart';
import '../../models/Notifications.dart';
import '../../services/Database_Service.dart';
import '../../widgets/EditPopup.dart';

TextEditingController searchController = TextEditingController();

class HomeController extends GetxController {
  User? user;
  RxString welcomeMessage = "Welcome Back,".obs;
  RxString userName = ''.obs;
  RxString email = ''.obs;
  RxString phone = 'Add a number'.obs;
  String fcm = "";
  RxString gender = "Male".obs;
  RxString startDate = "4 April 2024".obs;
  RxString endDate = "20 Feb 2025".obs;
  RxString category = "".obs;

  final List<RxString> categories = [
    "Premium".obs,
    "Standard".obs,
  ];

  void fetchUserDetails() async {
    user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      Map<String, dynamic> userDetails =
          await Database_Service.getUserDetails(user!.uid);
      userName.value = userDetails['Name'] ?? "";
      email.value = userDetails['Email'] ?? "";
      phone.value = userDetails['PhoneNo'] ?? "Add a number";
      category.value = userDetails['Subscription'] ?? "";
      gender.value = userDetails['Gender'] ?? "Male";
      fcm = userDetails['FCMToken'];

      if (userDetails.containsKey('SubscriptionStartDate')) {
        Timestamp startDateTimestamp = userDetails['SubscriptionStartDate'];
        DateTime startDate = startDateTimestamp.toDate();
        this.startDate.value =
            '${startDate.day} ${_getMonthName(startDate.month)} ${startDate.year}';
      } else {
        this.startDate.value = "-";
      }

      if (userDetails.containsKey('SubscriptionEndDate')) {
        Timestamp endDateTimestamp = userDetails['SubscriptionEndDate'];
        DateTime endDate = endDateTimestamp.toDate();
        this.endDate.value =
            '${endDate.day} ${_getMonthName(endDate.month)} ${endDate.year}';
      } else {
        this.endDate.value = "-";
      }
    }
  }

  String _getMonthName(int month) {
    switch (month) {
      case 1:
        return 'January';
      case 2:
        return 'February';
      case 3:
        return 'March';
      case 4:
        return 'April';
      case 5:
        return 'May';
      case 6:
        return 'June';
      case 7:
        return 'July';
      case 8:
        return 'August';
      case 9:
        return 'September';
      case 10:
        return 'October';
      case 11:
        return 'November';
      case 12:
        return 'December';
      default:
        return '';
    }
  }

  void changeWelcomeMessage(String message) {
    welcomeMessage.value = message;
  }

  HomeController() {
    fetchUserDetails();
  }

  void refreshData() {
    fetchUserDetails();
  }
}

class HomeScreen extends StatefulWidget {
  HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeState();
}

class HomeState extends State<HomeScreen> {
  final HomeController controller = Get.put(HomeController());
  String selectedCountry = "None";
  String selectedCity = "None";
  Future<List<Gym>>? _gymsFuture;
  Future<List<Notifications>>? _notifs;
  bool opened = true;
  List<Notifications>? notifications;
  late Notifications savedNotif;

  @override
  void initState() {
    super.initState();
    controller.fetchUserDetails();
    _initialize();
  }

  Future<void> _initialize([String query = '']) async {
    setState(() {
      _notifs = null;
      notifications = null;
    });

    if (controller.user != null) {
      _notifs = Database_Service.getNotifications(
          controller.user!.uid, controller.category.value);
      notifications = await _notifs!;

      notifications!.forEach((notif) async {
        if (!notif.opened.contains(controller.user!.uid.toString())) {
          savedNotif = notif;
          opened = false;
        }
      });

      controller.refreshData();

      _gymsFuture = Database_Service.getAllGyms(
    query: query,
    country: selectedCountry == 'None' ? '' : selectedCountry,
    city: selectedCity == 'None' ? '' : selectedCity,
  );

      setState(() {});
    }
  }

  Future<void> _refresh() async {
    _initialize();
    setState(() {});
  }

  void _logout() async {
    bool confirmed = await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.appBackground,
          title: Text('Gym Visa'),
          content: Text('Are you sure you want to logout?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Get.back(result: false);
              },
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(color: Colors.white),
              ),
            ),
            TextButton(
              onPressed: () {
                Get.back(result: true);
              },
              child: Text(
                'Logout',
                style: GoogleFonts.poppins(color: AppColors.appNeon),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            actionsAlignment: MainAxisAlignment.start,
            backgroundColor: AppColors.appBackground,
            title: Text('Logging out'),
            content: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  color: AppColors.appNeon,
                ),
              ],
            ),
          );
        },
      );

      // Simulate a delay for logging out
      await Future.delayed(Duration(seconds: 3));
      controller.userName.value = '';
      controller.email.value = '';
      controller.phone.value = 'Add a number';
      controller.category.value = '';
      controller.startDate.value = '-';
      controller.endDate.value = '-';
      // Perform the logout
      AuthServices.signOut(context);
    }
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    double welcomeMessageFontSize = 20;
    double userNameFontSize = 18;

    if (screenWidth < 500) {
      welcomeMessageFontSize = 18;
      userNameFontSize = 16;
    }
    if (screenWidth < 450) {
      welcomeMessageFontSize = 16;
      userNameFontSize = 15;
    }
    if (screenWidth < 400) {
      welcomeMessageFontSize = 14;
      userNameFontSize = 13;
    }
    if (screenWidth < 350) {
      welcomeMessageFontSize = 13;
      userNameFontSize = 12;
    }
    if (screenWidth < 300) {
      welcomeMessageFontSize = 12;
      userNameFontSize = 11;
    }

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 13, 13, 13),
      appBar: AppBar(
        toolbarHeight: screenHeight * 0.1,
        leading: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
          child: GestureDetector(
            onTap: () {
              showModalBottomSheet(
                context: context,
                builder: (BuildContext context) {
                  return Container(
                    height: screenHeight * 0.7,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 54, 54, 54),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(screenWidth * 0.1),
                        topRight: Radius.circular(screenWidth * 0.1),
                      ),
                    ),
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.all(screenWidth * 0.05),
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: screenWidth * 0.1,
                              backgroundImage: controller.gender.value == "Male"
                                  ? AssetImage("lib/assets/profile.jpg")
                                  : AssetImage("lib/assets/femalePfp.jfif"),
                            ),
                            SizedBox(height: screenHeight * 0.02),
                            Obx(
                              () => Text(
                                controller.userName.value,
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: userNameFontSize,
                                ),
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.02),
                            TextButton(
                              onPressed: () {
                                AuthServices.resetPassword(
                                    controller.email.toString(), context);
                              },
                              child: Text(
                                "Change Password",
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.02),
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: controller.category.value == "Premium"
                                    ? Color(0xFF715F00)
                                    : Color.fromARGB(255, 91, 91, 91),
                                borderRadius:
                                    BorderRadius.circular(screenWidth * 0.05),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(screenWidth * 0.03),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Obx(
                                          () => Text(
                                            "Subscription: " +
                                                controller.category.value,
                                            style: GoogleFonts.poppins(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w500,
                                              fontSize:
                                                  screenWidth * 0.05 * 0.7,
                                            ),
                                          ),
                                        ),
                                        Obx(
                                          () => Text(
                                            controller.startDate.value +
                                                "-" +
                                                controller.endDate.value,
                                            style: GoogleFonts.poppins(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w400,
                                              fontSize:
                                                  screenWidth * 0.04 * 0.8,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Icon(
                                      CupertinoIcons.star,
                                      color: Colors.white,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.02),
                            Padding(
                              padding:
                                  EdgeInsets.only(left: screenWidth * 0.05),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Obx(
                                          () => Text(
                                            "Email: " + controller.email.value,
                                            style: GoogleFonts.poppins(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w400,
                                              fontSize:
                                                  screenWidth * 0.04 * 0.8,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.edit),
                                        iconSize: 12,
                                        color: Colors.white,
                                        onPressed: () async {
                                          final newEmail =
                                              await showDialog<String>(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return EditPopup(
                                                label: "Phone",
                                                initialText:
                                                    controller.email.value,
                                                onSave: (newText) async {
                                                  // Perform the update here
                                                  // await controller.updatePhone(newText);
                                                  controller.email.value =
                                                      newText;
                                                  await Database_Service
                                                      .updateEmailById(
                                                          controller.user!.uid,
                                                          newText);
                                                },
                                              );
                                            },
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Obx(
                                        () => Text(
                                          "Phone No.: " +
                                              controller.phone.value,
                                          style: GoogleFonts.poppins(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w400,
                                            fontSize: screenWidth * 0.04 * 0.8,
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.edit),
                                        iconSize: 12,
                                        color: Colors.white,
                                        onPressed: () async {
                                          final newText =
                                              await showDialog<String>(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return EditPopup(
                                                label: "Phone",
                                                initialText:
                                                    controller.phone.value,
                                                onSave: (newText) async {
                                                  // Perform the update here
                                                  // await controller.updatePhone(newText);
                                                  controller.phone.value =
                                                      newText;
                                                  await Database_Service
                                                      .updatePhoneNumberById(
                                                          controller.user!.uid,
                                                          newText);
                                                },
                                              );
                                            },
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
            child: Row(
              children: [
                CircleAvatar(
                  radius: screenWidth * 0.07 * 0.6,
                  backgroundImage: controller.gender.value == "Male"
                      ? AssetImage("lib/assets/profile.jpg")
                      : AssetImage("lib/assets/femalePfp.jfif"),
                ),
                SizedBox(width: screenWidth * 0.04),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx(() => Text(
                          controller.welcomeMessage.value,
                          style: GoogleFonts.poppins(
                            color: AppColors.appNeon,
                            fontWeight: FontWeight.bold,
                            fontSize: welcomeMessageFontSize,
                          ),
                        )),
                    Obx(() => Text(
                          controller.userName.value.split(' ').first,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: userNameFontSize,
                          ),
                        )),
                  ],
                ),
              ],
            ),
          ),
        ),
        leadingWidth: screenWidth * 0.6,
        actions: [
          Padding(
            padding: EdgeInsets.all(screenWidth * 0.02),
            child: Row(
              children: [
                IconButton(
                  onPressed: () {
                    print(controller.fcm.toString());
                    print(controller.user!.uid.toString());

                    Get.toNamed('/NotificationScreen', arguments: _notifs);
                    notifications!.forEach((notif) async {
                      if (!notif.opened
                          .contains(controller.user!.uid.toString())) {
                        opened = await Database_Service
                            .updateNotificationOpenedStatus(
                                notif.id, controller.user!.uid);
                      }
                    });
                    setState(() {});
                  },
                  icon: Icon(
                    FontAwesomeIcons.bell,
                    color: opened ? Colors.white : AppColors.appNeon,
                  ),
                ),
                IconButton(
                  onPressed: _logout,
                  icon: const Icon(
                    Icons.logout,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        color: AppColors.appNeon,
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.05),
          child: Container(
            padding: EdgeInsets.all(0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    controller: searchController,
                    onChanged: (value) {
                      _initialize(value);
                      setState(() {});
                    },
                    style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: screenWidth * 0.04 * 0.9),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFF282828),
                      hintText: 'Search gym by name or location',
                      hintStyle: GoogleFonts.poppins(
                        fontSize: screenWidth * 0.04 * 0.9,
                        color: const Color.fromARGB(255, 186, 186, 186),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(screenWidth * 0.05),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(
                          vertical: screenWidth * 0.01,
                          horizontal: screenWidth * 0.03),
                      suffixIcon: Padding(
                        padding: EdgeInsets.all(screenWidth * 0.007),
                        child: IconButton(
                          disabledColor:
                              const Color.fromARGB(255, 186, 186, 186),
                          icon: Icon(
                            Icons.filter_list,
                            color: const Color.fromARGB(255, 186, 186, 186),
                          ),
                          onPressed: _showOptionsPopup,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.07),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Explore',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: screenWidth * 0.09,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Top-Rated gyms',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w400,
                                  fontSize: screenWidth * 0.04 * 0.9,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  FutureBuilder<List<Gym>>(
                    future: _gymsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator(
                          color: AppColors.appNeon,
                        );
                      } else if (snapshot.hasError) {
                        return Text(
                          'Error: ${snapshot.error}',
                          style: TextStyle(color: Colors.white),
                        );
                      } else if (snapshot.hasData) {
                        List<Gym> gyms = snapshot.data!;
                        return ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: gyms.length,
                          itemBuilder: (context, index) {
                            return GymWidget(gym: gyms[index]);
                          },
                        );
                      } else {
                        return Text(
                          'No gyms found',
                          style: TextStyle(color: Colors.white),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showOptionsPopup() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 54, 54, 54),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(MediaQuery.of(context).size.width * 0.1),
              topRight:
                  Radius.circular(MediaQuery.of(context).size.width * 0.1),
            ),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select Country',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: selectedCountry,
                    onChanged: (value) {
                      setState(() {
                        selectedCountry = value!;
                        selectedCity = "Lahore";
                        _initialize();
                      });
                    },
                    items: ["None","Pakistan"]
                        .map((country) => DropdownMenuItem<String>(
                              value: country,
                              child: Text(
                                country,
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ))
                        .toList(),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFF282828),
                      contentPadding: EdgeInsets.symmetric(horizontal: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Select City',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: selectedCity,
                    onChanged: (value) {
                      setState(() {
                        selectedCity = value!;
                        _initialize();
                      });
                    },
                    items: ["None","Lahore", "Karachi", "Islamabad"]
                        .map((city) => DropdownMenuItem<String>(
                              value: city,
                              child: Text(
                                city,
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ))
                        .toList(),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFF282828),
                      contentPadding: EdgeInsets.symmetric(horizontal: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}