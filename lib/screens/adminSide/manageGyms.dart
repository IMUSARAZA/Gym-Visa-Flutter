import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gymvisa/const/AppColors.dart';
import 'package:gymvisa/const/size.dart';
import 'package:gymvisa/models/GymModel.dart';
import 'package:gymvisa/services/database_service.dart';

class ManageGyms extends StatefulWidget {
  const ManageGyms({Key? key}) : super(key: key);

  @override
  State<ManageGyms> createState() => _ManageGymsState();
}

class _ManageGymsState extends State<ManageGyms> {
  late Future<List<Gym>> _gymsFuture;
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _iniatialize();
  }

  Future<void> _iniatialize() async{
        _gymsFuture = Database_Service.getAllGyms();
    _searchController.addListener(_onSearchPressed);
  }

  // Future<void> refresh() async{
  //   _iniatialize();
  //   setState(() {
      
  //   });
  // }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchPressed);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchPressed() {
    String searchQuery = _searchController.text.trim();
    if (searchQuery.isEmpty) {
      setState(() {
        _gymsFuture = Database_Service.getAllGyms();
      });
    } else {
      setState(() {
        _gymsFuture = Database_Service.searchGym(searchQuery);
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
        elevation: 0,
        title: Text("Manage Gyms"),
        actions: [
          TextButton(
            onPressed: () {
              Get.toNamed("/AddGym");
            },
            child: Text(
              "Add Gym",
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          )
        ],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Get.back();
          },
        ),
      ),
      backgroundColor: AppColors.appBackground,
      body: SingleChildScrollView(
        child: Container(
          width: screenWidth,
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.only(top: ScreenSize.getScreenWidth(context)*0.1, left: 4.0),
                child: Text(
                  "Manage Gyms",
                  style: GoogleFonts.poppins(
                    fontSize: 30,
                    fontWeight: FontWeight.w400,
                    color: AppColors.appNeon,
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.05),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: screenHeight * 0.05,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(7),
                        border: Border.all(color: Colors.grey),
                      ),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search Gyms',
                          hintStyle: GoogleFonts.poppins(
                            color: Colors.grey,
                            fontSize: screenWidth * 0.03,
                            fontWeight: FontWeight.w400,
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.03,
                            vertical: screenHeight * 0.02,
                          ),
                          border: InputBorder.none,
                        ),
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: screenWidth * 0.03,
                          fontWeight: FontWeight.w400,
                        ),
                        onSubmitted: (_) => _onSearchPressed(),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.03),
              FutureBuilder<List<Gym>>(
                future: _gymsFuture,
                builder:
                    (BuildContext context, AsyncSnapshot<List<Gym>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.appNeon,
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error: ${snapshot.error}',
                        style: GoogleFonts.poppins(
                          color: Colors.red,
                          fontSize: screenWidth * 0.04,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Text(
                        'No gyms found',
                        style: GoogleFonts.poppins(
                          color: AppColors.appTextColor,
                          fontSize: screenWidth * 0.04,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  } else {
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        showCheckboxColumn: false,
                        showBottomBorder: true,
                        columns: <DataColumn>[
                          DataColumn(
                            label: Text(
                              'SrNo', // Serial number column
                              style: GoogleFonts.poppins(
                                color: AppColors.appTextColor,
                                fontSize: screenWidth * 0.03,
                                fontWeight: FontWeight.w600,
                              ),
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
                              'City',
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
                              int index = entry.key + 1;
                              Gym gym = entry.value;
                              return DataRow(
                                onSelectChanged: (bool? selected) {
                                  if (selected != null && selected) {
                                    Get.toNamed("/GymInfo", arguments: gym);
                                  }
                                },
                                cells: <DataCell>[
                                  DataCell(
                                    Text(
                                      '$index',
                                      style: GoogleFonts.poppins(
                                        color: AppColors.appTextColor,
                                        fontSize: screenWidth * 0.03,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Container(
                                      width: screenWidth * 0.3,
                                      child: Text(
                                        gym.name,
                                        style: GoogleFonts.poppins(
                                          color: AppColors.appTextColor,
                                          fontSize: screenWidth * 0.03,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Container(
                                      width: screenWidth * 0.3,
                                      child: Text(
                                        gym.subscription,
                                        style: GoogleFonts.poppins(
                                          color: AppColors.appTextColor,
                                          fontSize: screenWidth * 0.03,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Container(
                                      width: screenWidth * 0.3,
                                      child: Text(
                                        gym.city,
                                        style: GoogleFonts.poppins(
                                          color: AppColors.appTextColor,
                                          fontSize: screenWidth * 0.03,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            })
                            .toList(),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
