import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gymvisa/const/AppColors.dart';
import 'package:gymvisa/models/UserModel.dart';
import 'package:gymvisa/services/Database_Service.dart';
import 'package:intl/intl.dart';

class SpecificUserNotify extends StatefulWidget {
  const SpecificUserNotify({Key? key});

  @override
  State<SpecificUserNotify> createState() => _SpecificUserNotifyState();
}

class _SpecificUserNotifyState extends State<SpecificUserNotify> {
  TextEditingController userSearchController = TextEditingController();
  List<bool> _selectedRows = [];
  bool _selectAll = false;
  List<UserWithToken> _fcmTokens = [];
  List _userIds = [];
  late Future<List<User>> _futureUsers;

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

  @override
  void initState() {
    _futureUsers = Database_Service.getAllUsers();
    userSearchController.addListener(_onSearchPressed);
    super.initState();
  }

  @override
  void dispose() {
    userSearchController.removeListener(_onSearchPressed);
    userSearchController.dispose();
    super.dispose();
  }

  void _onSearchPressed() {
    String searchQuery = userSearchController.text.trim();

    if (searchQuery.isEmpty) {
      setState(() {
        _futureUsers = Database_Service.getAllUsers();
      });
    } else {
      setState(() {
        _futureUsers = Database_Service.searchUser(searchQuery);
      });
    }
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
              Get.toNamed('/sendNotification', arguments: {
                'fcmToken': _fcmTokens,
                'userIds': _userIds,
              });
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
        scrollDirection: Axis.vertical,
        child: Container(
          width: screenWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(
                    screenWidth * 0.05,
                    screenHeight * 0.02,
                    screenWidth * 0.05,
                    screenHeight * 0.02),
                child: Text(
                  'Send Notification to all or a specific user',
                  style: GoogleFonts.poppins(
                    color: AppColors.appTextColor,
                    fontSize: 25,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.clip,
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(screenWidth * 0.05,
                    screenHeight * 0.05, screenWidth * 0.05, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Container(
                        height: screenHeight * 0.05,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(7),
                          border: Border.all(color: Colors.grey),
                        ),
                        child: TextField(
                          controller: userSearchController,
                          decoration: InputDecoration(
                            hintText: 'Search Users By Name',
                            hintStyle: GoogleFonts.poppins(
                              color: Colors.grey,
                              fontSize: screenWidth * 0.03,
                              fontWeight: FontWeight.w400,
                            ),
                            contentPadding: EdgeInsets.fromLTRB(
                                screenWidth * 0.02,
                                0,
                                screenWidth * 0.01,
                                screenHeight * 0.02),
                            border: InputBorder.none,
                            alignLabelWithHint: true,
                          ),
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w400,
                          ),
                          onSubmitted: (_) => _onSearchPressed(),
                        ),
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.03),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.appNeon,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      onPressed: () {
                        _onSearchPressed();
                      },
                      child: Text(
                        'Search',
                        style: GoogleFonts.poppins(
                          color: AppColors.appBackground,
                          fontSize: screenWidth * 0.03,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              FutureBuilder<List<User>>(
                future: _futureUsers,
                builder:
                    (BuildContext context, AsyncSnapshot<List<User>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.appTextColor,
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    if (_selectedRows.length != snapshot.data!.length) {
                      _selectedRows = List.generate(
                          snapshot.data!.length, (index) => false);
                    }
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        showCheckboxColumn: false,
                        showBottomBorder: true,
                        dataRowColor: MaterialStateColor.resolveWith(
                          (states) => Colors.black
                              .withOpacity(0.2), // Change checkbox color here
                        ),
                        columns: <DataColumn>[
                          DataColumn(
                            label: Checkbox(
                              value: _selectAll,
                              onChanged: (value) {
                                setState(() {
                                  if (_selectAll) {
                                    _selectAll = false;
                                    _fcmTokens.clear();
                                    _userIds.clear();
                                    _selectedRows = List.generate(
                                        _selectedRows.length, (index) => false);
                                  } else {
                                    _selectAll = true;
                                    _selectedRows = List.generate(
                                        _selectedRows.length, (index) => true);

                                    _fcmTokens.clear();
                                    _fcmTokens.addAll(snapshot.data!.map(
                                        (user) => UserWithToken(
                                            name: user.name,
                                            fcmToken: user.fcmToken)));

                                    _userIds.clear();
                                    _userIds.addAll(snapshot.data!
                                        .map((user) => user.userID));
                                  }
                                });
                              },
                              activeColor: AppColors.appNeon,
                              checkColor: AppColors.appTextColor,
                              side: BorderSide(
                                  color: AppColors.appNeon, width: 2),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Name',
                              style: GoogleFonts.poppins(
                                color: AppColors.appTextColor,
                                fontSize: screenWidth * 0.03,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Email',
                              style: GoogleFonts.poppins(
                                color: AppColors.appTextColor,
                                fontSize: screenWidth * 0.03,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          // DataColumn(
                          //   label: Text(
                          //     'FCMToken',
                          //     style: GoogleFonts.poppins(
                          //       color: AppColors.appTextColor,
                          //       fontSize: screenWidth * 0.03,
                          //       fontWeight: FontWeight.w600,
                          //     ),
                          //   ),
                          // ),
                          DataColumn(
                            label: Text(
                              'Gender',
                              style: GoogleFonts.poppins(
                                color: AppColors.appTextColor,
                                fontSize: screenWidth * 0.03,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Phone No',
                              style: GoogleFonts.poppins(
                                color: AppColors.appTextColor,
                                fontSize: screenWidth * 0.03,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'UserID',
                              style: GoogleFonts.poppins(
                                color: AppColors.appTextColor,
                                fontSize: screenWidth * 0.03,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Subscription',
                              style: GoogleFonts.poppins(
                                color: AppColors.appTextColor,
                                fontSize: screenWidth * 0.03,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Subscription Start Date',
                              style: GoogleFonts.poppins(
                                color: AppColors.appTextColor,
                                fontSize: screenWidth * 0.03,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Subscription End Date',
                              style: GoogleFonts.poppins(
                                color: AppColors.appTextColor,
                                fontSize: screenWidth * 0.03,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                        rows: snapshot.data!
                            .asMap()
                            .entries
                            .map<DataRow>((entry) {
                          final index = entry.key;
                          final user = entry.value;
                          return DataRow(
                            cells: <DataCell>[
                              DataCell(
                                Checkbox(
                                  value: _selectedRows[index],
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedRows[index] = value!;
                                      if (value) {
                                        _fcmTokens.add(UserWithToken(
                                            name: user.name,
                                            fcmToken: user.fcmToken));

                                        _userIds.add(user.userID);
                                      } else {
                                        _fcmTokens.removeWhere((selectedUser) =>
                                            selectedUser.name == user.name);

                                        _userIds.removeWhere(
                                            (Id) => Id == user.userID);
                                      }
                                    });
                                  },
                                  activeColor: AppColors.appNeon,
                                  checkColor: AppColors.appTextColor,
                                  side: const BorderSide(
                                      color: AppColors.appNeon, width: 2),
                                ),
                              ),
                              DataCell(Text(
                                user.name,
                                style: GoogleFonts.poppins(
                                  color: AppColors.appTextColor,
                                  fontSize: screenWidth * 0.03,
                                  fontWeight: FontWeight.w600,
                                ),
                              )),
                              DataCell(Text(
                                user.email,
                                style: GoogleFonts.poppins(
                                  color: AppColors.appTextColor,
                                  fontSize: screenWidth * 0.03,
                                  fontWeight: FontWeight.w600,
                                ),
                              )),
                              // DataCell(Text(
                              //   user.fcmToken,
                              //   style: GoogleFonts.poppins(
                              //     color: AppColors.appTextColor,
                              //     fontSize: screenWidth * 0.03,
                              //     fontWeight: FontWeight.w600,
                              //   ),
                              // )),
                              DataCell(Text(
                                user.gender,
                                style: GoogleFonts.poppins(
                                  color: AppColors.appTextColor,
                                  fontSize: screenWidth * 0.03,
                                  fontWeight: FontWeight.w600,
                                ),
                              )),
                              DataCell(Text(
                                user.phoneNo,
                                style: GoogleFonts.poppins(
                                  color: AppColors.appTextColor,
                                  fontSize: screenWidth * 0.03,
                                  fontWeight: FontWeight.w600,
                                ),
                              )),
                              DataCell(Text(
                                user.userID,
                                style: GoogleFonts.poppins(
                                  color: AppColors.appTextColor,
                                  fontSize: screenWidth * 0.03,
                                  fontWeight: FontWeight.w600,
                                ),
                              )),
                              DataCell(Text(
                                user.subscription,
                                style: GoogleFonts.poppins(
                                  color: AppColors.appTextColor,
                                  fontSize: screenWidth * 0.03,
                                  fontWeight: FontWeight.w600,
                                ),
                              )),
                              DataCell(Text(
                                DateFormat('yyyy-MM-dd')
                                    .format(user.subscriptionStartDate),
                                style: GoogleFonts.poppins(
                                  color: AppColors.appTextColor,
                                  fontSize: screenWidth * 0.03,
                                  fontWeight: FontWeight.w600,
                                ),
                              )),

                              DataCell(Text(
                                DateFormat('yyyy-MM-dd')
                                    .format(user.subscriptionEndDate),
                                style: GoogleFonts.poppins(
                                  color: AppColors.appTextColor,
                                  fontSize: screenWidth * 0.03,
                                  fontWeight: FontWeight.w600,
                                ),
                              )),
                            ],
                          );
                        }).toList(),
                      ),
                    );
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}

class UserWithToken {
  final String name;
  final String fcmToken;

  UserWithToken({required this.name, required this.fcmToken});
}
