import 'package:flutter/material.dart';

class CustomElevatedButton extends StatefulWidget {
  final String buttonText;
  final void Function()? onPressed;

  const CustomElevatedButton({
    super.key,
    required this.buttonText,
    this.onPressed,
  });

  @override
  State<CustomElevatedButton> createState() => _CustomElevatedButtonState();
}

class _CustomElevatedButtonState extends State<CustomElevatedButton> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ButtonStyle(
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
        side: WidgetStatePropertyAll(
          BorderSide(
            color: Colors.blue,
            width: 1.0,
          ),
        ),
        backgroundColor: WidgetStatePropertyAll(
          Colors.blue,
        ),
        foregroundColor: WidgetStatePropertyAll(
          Colors.white,
        ),
      ),
      onPressed: widget.onPressed,
      child: Text(
        widget.buttonText,
      ),
    );
  }
}
