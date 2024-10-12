import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/GymModel.dart';

// ignore: must_be_immutable
class MembershipsWidget extends StatefulWidget {
  Gym gym;
  final double rating;
  final Color color;

  MembershipsWidget({
    Key? key,
    required this.gym,
    required this.rating,
    required this.color,
  }) : super(key: key);

  @override
  State<MembershipsWidget> createState() => _MembershipsWidgetState();
}

class _MembershipsWidgetState extends State<MembershipsWidget> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    double gymNameFontSize = 25;
    // ignore: unused_local_variable
    double rating = 20;
    double cityFontSize = 22;

    if (screenWidth < 700) {
      gymNameFontSize = 23;
      rating = 16;
      cityFontSize = 20;
    }
    if (screenWidth < 640) {
      gymNameFontSize = 21;
      rating = 16;
      cityFontSize = 18;
    }
    if (screenWidth < 570) {
      gymNameFontSize = 18;
      rating = 16;
      cityFontSize = 16;
    }
    if (screenWidth < 490) {
      gymNameFontSize = 15;
      rating = 13;
      cityFontSize = 12;
    }
    if (screenWidth < 420) {
      gymNameFontSize = 14;
      rating = 11;
      cityFontSize = 10;
    }
    if (screenWidth < 390) {
      gymNameFontSize = 11;
      rating = 9;
    }
    if (screenWidth < 350) {
      gymNameFontSize = 10;
      rating = 7;
    }
    return Padding(
        padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child:  Container(
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius:
                    BorderRadius.circular(10), // Adjust the radius as needed
              ),
              width: screenWidth * 0.4,
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                      side: BorderSide.none,
                    ),
                    padding: EdgeInsets.zero, // Remove default padding
                  ),
                  onPressed: () {
                      Get.toNamed("/gymInformation", arguments: widget.gym);
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        color: Colors.black,
                        child: ClipRRect(
                          child: Image.network(
                            widget.gym.imageUrl1,
                            height: screenHeight * 0.20,
                            width: screenWidth,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Container(
                        color: Color.fromARGB(255, 81, 81, 81),
                        child: Center(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.fromLTRB(15, 15, 15, 0),
                                child: Row(
                                  children: [
                                    Text(
                                      widget.gym.name,
                                      style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontSize: gymNameFontSize,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Spacer(),
                                    Icon(
                                    CupertinoIcons.arrow_right,
                                    color: Colors.white,
                                  ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.fromLTRB(15, 5, 10, 10),
                                child: Text(widget.gym.address +' ,' + widget.gym.city,
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: cityFontSize,
                                    )),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )),
            ),
        
 ));
}
}