import 'package:flutter/material.dart';
import 'package:hercules/styles/app_colors.dart';

class AppTextField extends StatelessWidget {
  final String hint;
  final TextEditingController? controller;  // Add this line to accept a controller

  // Updated constructor to accept the controller parameter
  const AppTextField({
    super.key,
    required this.hint,
    this.controller,  // Make the controller optional
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,  // Pass the controller to the TextField
      decoration: InputDecoration(
        hintText: hint,
        labelText: hint,
        labelStyle: const TextStyle(
          color: Colors.white,
        ),
        border: const UnderlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.transparent),
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        filled: true,
        fillColor: AppColors.fieldColor,
      ),
    );
  }
}
