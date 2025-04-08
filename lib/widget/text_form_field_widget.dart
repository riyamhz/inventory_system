import 'package:flutter/material.dart';

class TextformfieldWidget extends StatefulWidget {
  final String labelText;
  final TextEditingController controller;
  final TextInputType? keyboardType;

  const TextformfieldWidget({
    super.key,
    required this.labelText,
    required this.controller,
    required this.keyboardType,
  });

  @override
  State<TextformfieldWidget> createState() => _TextformfieldWidgetState();
}

class _TextformfieldWidgetState extends State<TextformfieldWidget> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      validator: (value) {
        if (value == null || value == "") {
          return "This field is required.";
        } else {
          return null;
        }
      },
      keyboardType: widget.keyboardType,
      decoration: InputDecoration(
        labelText: widget.labelText,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 20,
        ),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(32),
          ),
          borderSide: BorderSide(
            color: Colors.blue,
          ),
        ),
      ),
    );
  }
}
