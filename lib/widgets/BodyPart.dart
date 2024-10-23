import 'package:flutter/material.dart';
import 'package:gymvisa/const/AppColors.dart';

enum Alignment { left, right, centerRight, centerLeft }

class BodyPart extends StatelessWidget {
  final String text;
  final double dividerWidth;
  final Alignment alignment;
  final VoidCallback onTap;

  const BodyPart({
    Key? key,
    required this.text,
    required this.dividerWidth,
    required this.onTap,
    this.alignment = Alignment.left, // Default alignment is left
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      width: screenWidth * 0.5,
      height: screenHeight * 0.06,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: GestureDetector(
          onTap: onTap,
          child: Row(
            mainAxisAlignment: alignment == Alignment.left
                ? MainAxisAlignment.start
                : MainAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: alignment == Alignment.left ? CrossAxisAlignment.start : CrossAxisAlignment.end,
                children: [
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: screenWidth*0.03,
                      color: AppColors.appTextColor, 
                    ),
                  ),
                  SizedBox(height: 4.0),
                  Container(
                    height: 2.0,
                    width: dividerWidth,
                    color: Color(0xff9C9696),
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

