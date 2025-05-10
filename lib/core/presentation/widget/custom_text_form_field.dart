import 'package:flutter/material.dart';

import '../../ui/text_style/text_styles.dart';


class CustomTextFormField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final bool obscureText;
  final bool autoFocus;
  final Function(String)? onChanged;
  final VoidCallback? onCompleted;
  final Function(String)? validator;
  final Function(String)? onSaved;
  final FocusNode? focusNode;

  const CustomTextFormField({
    super.key,
    this.controller,
    this.hintText,
    this.obscureText = false,
    this.autoFocus = false,
    this.onChanged,
    this.onCompleted,
     this.validator,
    this.onSaved,
    this.focusNode,
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
      focusNode: focusNode,
      onChanged: (text) => onChanged,
      onEditingComplete: onCompleted,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20),
        hintText: hintText,
        hintStyle: TextStyles.hintStyle,
        errorStyle: TextStyles.errorStyle,
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
