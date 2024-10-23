import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gymvisa/const/AppColors.dart';

class CustomPasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final String labelText;
  final bool isValid;
  final ValueChanged<String>? onChanged;

  CustomPasswordField({
    Key? key,
    required this.controller,
    required this.hintText,
    required this.labelText,
    required this.isValid,
    this.onChanged, required bool obscure,
  }) : super(key: key);

  @override
  _CustomPasswordFieldState createState() => _CustomPasswordFieldState();
}

class _CustomPasswordFieldState extends State<CustomPasswordField> {
  bool obscure = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      style: TextStyle(color: Colors.white),
      obscureText: obscure,
      enableSuggestions: false,
      autocorrect: false,
      decoration: InputDecoration(
        hintStyle: GoogleFonts.poppins(
          color: Color.fromARGB(255, 168, 160, 160),
        ),
        hintText: widget.hintText,
        labelStyle: GoogleFonts.poppins(
          color: Colors.white,
        ),
        floatingLabelStyle: GoogleFonts.poppins(
          color: Colors.white,
        ),
        labelText: widget.labelText,
        disabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(15)),
          borderSide: BorderSide(color: Colors.white, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(15)),
          borderSide: BorderSide(
            color: widget.isValid ? AppColors.appNeon : Colors.red,
            width: 1.0,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(15)),
          borderSide: BorderSide(
            color: widget.isValid ? Colors.white : Colors.red,
            width: 1.0,
          ),
        ),
        suffixIcon: GestureDetector(
          onTap: () {
            setState(() {
              obscure = !obscure;
            });
          },
          child: Padding(
            padding: EdgeInsets.only(right: 8),
            child: Icon(
              obscure ? Icons.visibility : Icons.visibility_off,
              color: Colors.white,
            ),
          ),
        ),
      ),
      onChanged: widget.onChanged,
    );
  }
}