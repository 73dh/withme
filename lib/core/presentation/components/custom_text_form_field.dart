import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../ui/text_style/text_styles.dart';

class CustomTextFormField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final String? labelText;
  final bool obscureText;
  final TextAlign? textAlign;
  final TextInputType? inputType;
  final TextStyle? textStyle;
  final bool autoFocus;
  final bool readOnly;
  final List<TextInputFormatter>? inputFormatters;
  final Function(String)? onChanged;
  final VoidCallback? onCompleted;
  final Function(String)? validator;
  final Function(String)? onSaved;
  final FocusNode? focusNode;

  const CustomTextFormField({
    super.key,
    this.controller,
    this.hintText,
    this.labelText,
    this.obscureText = false,
    this.autoFocus = false,
    this.textStyle,
    this.textAlign = TextAlign.start,
    this.inputType,
    this.inputFormatters,
    this.readOnly = false,
    this.onChanged,
    this.onCompleted,
    this.validator,
    this.onSaved,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    final baseBorder =OutlineInputBorder(borderSide: BorderSide.none);
    // const OutlineInputBorder(
    //   borderSide: BorderSide(color: Colors.blueGrey, width: 1.0),
    // );

    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      cursorColor: Colors.black87,
      obscureText: obscureText,
      autofocus: autoFocus,
      focusNode: focusNode,
      textAlign: textAlign!,
      style: textStyle,
      keyboardType: inputType,
      onChanged: (text) => onChanged,
      onEditingComplete: onCompleted,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 10),
        hintText: hintText,
        hintStyle: TextStyles.hintStyle,
        labelText: labelText,
        labelStyle: TextStyles.labelStyle,
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
