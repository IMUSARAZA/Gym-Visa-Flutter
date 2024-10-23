import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gymvisa/const/AppColors.dart';
import 'package:gymvisa/models/GymModel.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../widgets/CustomAppBar.dart';

class GymInform extends StatefulWidget {
  final Gym gym;

  GymInform({
    required this.gym,
    Key? key,
  }) : super(key: key);

  @override
  State<GymInform> createState() => _GymInformState();
}

class _GymInformState extends State<GymInform> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: CustomAppBar(
        title: "About",
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
            
              width: double.infinity,
              height: screenHeight * 0.3,
              child: Image.network(
                widget.gym.imageUrl1,
                fit: BoxFit.cover,
              ),
            ),
            Container(
              width: screenWidth,
              height: screenHeight*0.7,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(screenWidth * 0.09),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            widget.gym.name,
                            softWrap: true,
                            textAlign: TextAlign.left,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontSize: screenWidth * 0.06,

                              fontWeight: FontWeight.bold,
                              color: AppColors.appNeon,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.location_on,
                            color: AppColors.appNeon,
                          ),
                          onPressed: () async {
                            String googleMapsUrl = widget.gym.googleMapsLink;

                            if (await canLaunch(googleMapsUrl)) {
                              await launch(googleMapsUrl);
                            } else {
                              throw 'Could not launch $googleMapsUrl';
                            }
                          },
                        ),
                      ],
                    ),
                    Divider(color: Colors.white),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
                      child: Container(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          widget.gym.description,
                          softWrap: true,
                          textAlign: TextAlign.left,
                          style: GoogleFonts.poppins(
                            fontSize: screenWidth * 0.040,
                            fontWeight: FontWeight.w400,
                            color: Colors.white, // Adjust text color as needed
                          ),
                        ),
                      ),
                    ),
                    _buildTextItem("Subscriptions ", widget.gym.subscription, screenWidth),
                    _buildTextItem("City ", widget.gym.city, screenWidth),
                    _buildTextItem("Phone No ", widget.gym.phoneNo, screenWidth),
                    _buildTextItem("Email ", widget.gym.email, screenWidth),
                    _buildTextItem("Address ", widget.gym.address, screenWidth),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextItem(String label, String value, double screenWidth) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Text(
            "$label: ",
            softWrap: true,
            style: GoogleFonts.poppins(
              color: Colors.white, // Adjust text color as needed
              fontSize: screenWidth * 0.040,
              fontWeight: FontWeight.bold,
            ),
          ),
          Flexible(
            child: Text(
              value,
              softWrap: true,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                color: Colors.white, // Adjust text color as needed
                fontSize: screenWidth * 0.040,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
