import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EditPopup extends StatefulWidget {
  final String label;
  final String initialText;
  final Function(String) onSave; // Function to handle saving the edited text

  EditPopup({
    Key? key,
    required this.label,
    required this.initialText,
    required this.onSave,
  }) : super(key: key);

  @override
  _EditPopupState createState() => _EditPopupState();
}

class _EditPopupState extends State<EditPopup> {
  late TextEditingController _textEditingController;

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController(text: widget.initialText);
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.label,
        style: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
      content: TextField(
        controller: _textEditingController,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          hintText: 'Enter new value',
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: Text('Save'),
          onPressed: () {
            String newText = _textEditingController.text;
            // Call the onSave function passed from the parent widget
            widget.onSave(newText); // Pass newText to the onSave function
            Navigator.of(context).pop(); // Close the dialog
          },
        ),
      ],
    );
  }
}
