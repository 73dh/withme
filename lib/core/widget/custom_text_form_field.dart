import 'package:flutter/material.dart';

class CustomTextFormField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final bool obscureText;
  final bool autoFocus;
  final Function(String)? onChanged;
  final Function(String)? validator;
  final Function(String)? onSaved;

  const CustomTextFormField({
    super.key,
    this.controller,
    this.hintText,
    this.obscureText = false,
    this.autoFocus = false,
    this.onChanged,
    required this.validator,
    this.onSaved,
  });

  @override
  Widget build(BuildContext context) {
    final baseBorder = const OutlineInputBorder(
      borderSide: BorderSide(color: Colors.blueGrey, width: 1.0),
    );

    return TextFormField(
      controller: controller,
      cursorColor: Colors.black87,
      obscureText: obscureText,
      autofocus: autoFocus,
      onChanged: onChanged,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.all(20),
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.blueGrey, fontSize: 14.0),
        errorStyle: TextStyle(fontSize: 13, color: Colors.black87),
        errorBorder: baseBorder,
        fillColor: Colors.white,
        filled: true,
        border: baseBorder,
        enabledBorder: baseBorder,
        focusedBorder: baseBorder.copyWith(
          borderSide: baseBorder.borderSide.copyWith(color: Colors.blueGrey),
        ),
      ),
      validator: (text) => validator!(text!),
      onSaved: (text) => onSaved ?? (text!),
    );
  }
}