import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final String labelText;
  final bool isValid;
  final ValueChanged<String>? onChanged;

  const CustomTextField({
    Key? key,
    required this.controller,
    required this.hintText,
    required this.labelText,
    required this.isValid,
    this.onChanged,
  }) : super(key: key);

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      autofocus: false,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintStyle: TextStyle(color: Color.fromARGB(255, 168, 160, 160)),
        hintText: widget.hintText,
        labelText: widget.labelText,
        labelStyle: TextStyle(color: Colors.white),
        floatingLabelStyle: TextStyle(color: Colors.white),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          borderSide: BorderSide(
            color: widget.isValid ? Colors.white : Colors.red,
            width: 1.0,
            ),
        ),
        
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          borderSide: BorderSide(
            color: widget.isValid ? Colors.white : Colors.red,
            width: 1.0,
          ),
        ),
      ),
      onChanged: widget.onChanged,
    );
  }
}
