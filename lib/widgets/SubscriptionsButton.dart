import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gymvisa/const/AppColors.dart';
import 'package:gymvisa/models/SubscriptionsModel.dart';


// ignore: must_be_immutable
class SubscriptionsButton extends StatefulWidget {
  Subscription subscription;
  final String description;
  final VoidCallback? onPressed;

  SubscriptionsButton({
    Key? key,
    required this.subscription,
    required this.description,
    required this.onPressed,
  }) : super(key: key);

  @override
  _SubscriptionsButtonState createState() => _SubscriptionsButtonState();
}

class _SubscriptionsButtonState extends State<SubscriptionsButton> {



  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    Color buttonColor = widget.subscription.name == "Standard"
        ? AppColors.standardColor
        : AppColors.premiumColor;


    double memberShipFontSize = 25;
    double descriptionFontSize = 20;

    if (screenWidth < 450) {
      memberShipFontSize = 20;
    }
    if (screenWidth < 350) {
      memberShipFontSize = 15;
    }
    if (screenWidth < 650) {
      descriptionFontSize = 17;
    }
    if (screenWidth < 550) {
      descriptionFontSize = 15;
    }
    if (screenWidth < 500) {
      descriptionFontSize = 13;
    }
    if (screenWidth < 430) {
      descriptionFontSize = 12;
    }
    if (screenWidth < 300) {
      descriptionFontSize = 8;
    }
    return Padding(
      padding: EdgeInsets.fromLTRB(30, 0, 30, 0),
      child: ElevatedButton(
        onPressed: widget.onPressed,
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
            side: BorderSide.none,
          ),
          padding: EdgeInsets.zero, // Remove default padding
        ),
        child: Container(
          width: screenWidth * 0.9,
          height: screenHeight * 0.20,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.0),
            boxShadow: [
              BoxShadow(
                color: buttonColor.withOpacity(0.6),
                spreadRadius: 1,
                blurRadius: 10,
                offset: Offset(-5, -5),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.8),
                spreadRadius: 1,
                blurRadius: 10,
                offset: Offset(5, 5),
              ),
            ],
            color: buttonColor,
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(20, 10, 0, 0),
                    child: Text(
                      widget.subscription.name,
                      style: GoogleFonts.poppins(
                        fontSize: memberShipFontSize,
                        color: Colors.white,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  Spacer(),
                  Padding(
                    padding: EdgeInsets.fromLTRB(0, 10, 20, 0),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_forward),
                      onPressed: widget.onPressed,
                    ),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(20, 10, 20, 0),
                child: Text(
                  widget.description,
                  style: GoogleFonts.poppins(
                    fontSize: descriptionFontSize,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
