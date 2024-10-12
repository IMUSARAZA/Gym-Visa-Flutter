import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:gymvisa/const/AppColors.dart';
import 'package:gymvisa/screens/clientSide/QRViewExample.dart';
import 'package:gymvisa/screens/clientSide/BMI.dart';
import 'package:gymvisa/screens/clientSide/ExcerciseScreen.dart';
import 'package:gymvisa/screens/clientSide/HomeScreen.dart';
import 'package:gymvisa/screens/clientSide/Subscriptions.dart';
import 'package:gymvisa/services/Database_Service.dart'; 

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final PersistentTabController _controller =
      PersistentTabController(initialIndex: 0);
  late String currentUserId;
  bool isInitialized = false;
  bool _isLoading = false;
  Future<bool>? _scanFuture;

  @override
  void initState() {
    super.initState();
    _initializeUser();
  }

  Future<void> _initializeUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        currentUserId = user.uid;
        isInitialized = true;
      });
      _scanFuture = Database_Service().checkUserScan(currentUserId);
    }
  }

  Future<void> onQrButtonPressed(BuildContext context) async {
    if (!isInitialized) return; // Ensure user is initialized

    setState(() {
      _isLoading = true; // Start loading indicator
    });

    try {
      final canScan = await _scanFuture;

      if (canScan == true) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => QRViewExample()),
        );
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showAlreadyScannedDialog(context);
        });
      }
    } catch (e) {
      print('Error checking user scan: $e');
      // Optionally handle error
    } finally {
      setState(() {
        _isLoading = false; // Stop loading indicator
      });
    }
  }

  void showAlreadyScannedDialog(BuildContext context) async {
  // Initialize Database_Service
  Database_Service database_service = Database_Service();

  // Ensure user is logged in
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  // Fetch scan data for today
  final scanData = await database_service.getScanDataForToday(user.uid);

  // Fetch user subscription
  final userSubscription = await database_service.getUserSubscription(user.uid);

  // Check if scan data is available
  if (scanData != null) {
    final gymName = scanData['gymName'] ?? 'Unknown gym';
    final gymAddress = scanData['gymAddress'] ?? 'Unknown address';
    final gymSubscription =
        scanData['gymSubscription'] ?? 'Unknown subscription';
    final userId = user.uid; // Get the user ID

    // Print the details to the terminal
    print('Gym Name: $gymName');
    print('Gym Address: $gymAddress');
    print('Gym Subscription: $gymSubscription');
    print('User ID: $userId');
    print('User Subscription: $userSubscription');

    final now = DateTime.now();
    final endOfDay = DateTime(now.year, now.month, now.day + 1);
    final remainingTime = endOfDay.difference(now);

    // Show dialog with scan details
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Already Scanned Today'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: "Already scanned today at Gym: ",
                    style: TextStyle(color: Colors.white), // Default color
                  ),
                  TextSpan(
                    text: '$gymName',
                    style: TextStyle(fontWeight: FontWeight.w700), // Neon color
                  ),
                  TextSpan(
                    text: '\nLocation: ',
                    style: TextStyle(color: Colors.white), // Default color
                  ),
                  TextSpan(
                    text: '$gymAddress',
                    style: TextStyle(fontWeight: FontWeight.w700), // Neon color
                  ),
                  TextSpan(
                    text: '\nUser subscription: ',
                    style: TextStyle(color: Colors.white), // Default color
                  ),
                  TextSpan(
                    text: '${userSubscription ?? 'No subscription found'}',
                    style: TextStyle(fontWeight: FontWeight.w700), // Neon color
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'You can scan again in:',
                    style: TextStyle(color: Colors.white), // Default color
                  ),
                  TextSpan(
                    text: '\n${remainingTime.inHours} hours and ${remainingTime.inMinutes % 60} minutes',
                    style: TextStyle(color: AppColors.appNeon, fontWeight: FontWeight.w900), // Neon color
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('OK', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  } else {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text('Unable to fetch scan details.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK', style: TextStyle(color: AppColors.appNeon)),
          ),
        ],
      ),
    );
  }
}


  List<Widget> _buildScreens(BuildContext context) {
    return [
      HomeScreen(),
      Subscriptions(),
      Builder(
        builder: (context) {
          return FutureBuilder<bool>(
            future: _scanFuture,
            builder: (context, snapshot) {
              if (_isLoading) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (snapshot.hasData && snapshot.data == true) {
                return QRViewExample();
              } else if (snapshot.hasData && snapshot.data == false) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  showAlreadyScannedDialog(context);
                });
                return Center(child: CircularProgressIndicator());
              } else {
                return Center(child: Text('No data available'));
              }
            },
          );
        },
      ),
      ExcerciseScreen(),
      BMI(),
    ];
  }

  List<PersistentBottomNavBarItem> _navBarsItems() {
    return [
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.home, size: 20, color: AppColors.appTextColor),
        title: ("Home"),
        activeColorPrimary: AppColors.appNeon,
        inactiveColorPrimary: AppColors.appTextColor,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.star, size: 20, color: AppColors.appTextColor),
        title: ("Subscriptions"),
        textStyle: TextStyle(fontSize: 12),
        activeColorPrimary: AppColors.appNeon,
        inactiveColorPrimary: AppColors.appTextColor,
      ),
      PersistentBottomNavBarItem(
        icon: SvgPicture.asset(
          'lib/assets/scan.svg',
        ),
        title: ("Scan"),
        activeColorPrimary: AppColors.appNeon,
        inactiveColorPrimary: AppColors.appTextColor,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.sports_gymnastics,
            size: 20, color: AppColors.appTextColor),
        title: ("Exercises"),
        activeColorPrimary: AppColors.appNeon,
        inactiveColorPrimary: AppColors.appTextColor,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.food_bank,
            size: 20, color: AppColors.appTextColor),
        title: ("Diet"),
        activeColorPrimary: AppColors.appNeon,
        inactiveColorPrimary: AppColors.appTextColor,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return PersistentTabView(
      context,
      controller: _controller,
      screens: _buildScreens(context),
      items: _navBarsItems(),
      confineInSafeArea: true,
      backgroundColor: const Color.fromARGB(255, 36, 36, 36),
      handleAndroidBackButtonPress: true,
      resizeToAvoidBottomInset: true,
      stateManagement: true,
      hideNavigationBarWhenKeyboardShows: true,
      decoration: NavBarDecoration(
        borderRadius: BorderRadius.circular(10.0),
        colorBehindNavBar: const Color.fromARGB(255, 36, 36, 36),
      ),
      popAllScreensOnTapOfSelectedTab: true,
      popActionScreens: PopActionScreensType.all,
      itemAnimationProperties: const ItemAnimationProperties(
        duration: Duration(milliseconds: 200),
        curve: Curves.ease,
      ),
      screenTransitionAnimation: const ScreenTransitionAnimation(
        animateTabTransition: true,
        curve: Curves.ease,
        duration: Duration(milliseconds: 200),
      ),
      navBarStyle: NavBarStyle.style15,
    );
  }
}
