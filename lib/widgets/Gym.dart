import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gymvisa/const/size.dart';
import 'package:gymvisa/models/GymModel.dart';

// ignore: must_be_immutable
class GymWidget extends StatelessWidget {
  late Gym gym;

  GymWidget({Key? key, required this.gym}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: ScreenSize.getScreenWidth(context) * 0.2,
      child: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: ScreenSize.getScreenHeight(context) * 0.01),
              child: Container(
                height: ScreenSize.getScreenHeight(context) * 0.11,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5.0),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10.0),
                          bottomLeft: Radius.circular(10.0),
                        ),
                        child: Image.network(
                          gym.imageUrl1,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(10.0),
                          bottomRight: Radius.circular(10.0),
                        ),
                        child: Image.network(
                          gym.imageUrl2,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: (){
                Get.toNamed("/gymInformation", arguments: gym);
              },
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: gym.subscription == "Premium"
                      ? Color(0xFF715F00)
                      : gym.subscription == "Standard"
                          ? Color(0xFF434343)
                              : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          gym.name,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: MediaQuery.of(context).size.width * 0.05 * 0.7,
                          ),
                        ),
                        Text(
                          gym.address,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w400,
                            fontSize: MediaQuery.of(context).size.width * 0.04 * 0.8,
                          ),
                        ),
                      ],
                    ),
                    Icon(
                      CupertinoIcons.arrow_right,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: ScreenSize.getScreenHeight(context) * 0.02),
          ],
        ),
      ),
    );
  }
}
