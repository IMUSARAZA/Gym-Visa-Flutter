import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_indicator/loading_indicator.dart';

// ignore: must_be_immutable
class CustomButton extends StatelessWidget {
  final Color color, textcolor;
  final String text;
  IconData? icon;
  Image? imgIcon;
  final VoidCallback? onPressed;
  final double pad;
  bool? isLoading = false;

  CustomButton({
    required this.color,
    required this.textcolor,
    required this.text,
    required this.pad,
    this.icon,
    this.imgIcon,
    required this.onPressed,
    this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    double fontSize = screenWidth * 0.04;

    return ElevatedButton(
      onPressed: isLoading != null && isLoading! ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        fixedSize: Size(screenWidth * 0.85, screenHeight * 0.05),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Center(
        child: isLoading != null && isLoading!
            ?  LoadingIndicator(
     indicatorType: Indicator.ballPulse,
     colors: const [Colors.white],       
    strokeWidth: 2,                    
     backgroundColor: Colors.transparent,      
     pathBackgroundColor: Colors.transparent   
) 
            : Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null)
              Padding(
                padding: EdgeInsets.only(right: pad),
                child: Icon(
                  icon,
                  size: screenWidth * 0.05,
                  color: const Color.fromARGB(255, 0, 0, 0),
                ),
              ),
            if (imgIcon != null)
              Center(
                child: Padding(
                  padding: EdgeInsets.only(right: pad),
                  child: imgIcon!,
                ),
              ),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  text,
                  textAlign: TextAlign.left,
                  style: GoogleFonts.poppins(
                    fontSize: fontSize,
                    color: textcolor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
