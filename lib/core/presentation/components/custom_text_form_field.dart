import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextFormField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final String? labelText;
  final bool obscureText;
  final TextAlign? textAlign;
  final TextInputType? inputType;
  final bool autoFocus;
  final bool readOnly;
  final List<TextInputFormatter>? inputFormatters;
  final Function(String)? onChanged;
  final VoidCallback? onCompleted;
  final Function(String)? validator;
  final Function(String)? onSaved;
  final FocusNode? focusNode;

  final TextStyle? textStyle;
  final Color? fillColor;
  final TextStyle? hintStyle;

  const CustomTextFormField({
    super.key,
    this.controller,
    this.hintText,
    this.labelText,
    this.obscureText = false,
    this.autoFocus = false,
    this.textAlign,
    this.inputType,
    this.inputFormatters,
    this.readOnly = false,
    this.onChanged,
    this.onCompleted,
    this.validator,
    this.onSaved,
    this.focusNode,
    this.textStyle,
    this.fillColor,
    this.hintStyle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final baseBorder = OutlineInputBorder(
      borderSide: BorderSide(color: colorScheme.outline, width: 1),
      borderRadius: BorderRadius.circular(8),
    );

    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      cursorColor: colorScheme.primary,
      obscureText: obscureText,
      autofocus: autoFocus,
      focusNode: focusNode,
      textAlign: textAlign ?? TextAlign.start,
      style:
          textStyle ??
          theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
      keyboardType: inputType,
      inputFormatters: inputFormatters,
      onEditingComplete: onCompleted,
      onChanged: onChanged,
      validator: validator != null ? (text) => validator!(text ?? '') : null,
      onSaved: onSaved != null ? (text) => onSaved!(text ?? '') : null,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        hintText: hintText,
        hintStyle:
            hintStyle ??
            theme.textTheme.labelMedium?.copyWith(
              fontStyle: FontStyle.italic,
              color: colorScheme.onSurfaceVariant,
            ),
        labelText: labelText,
        labelStyle: theme.textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
        errorStyle: theme.textTheme.labelMedium?.copyWith(
          fontStyle: FontStyle.italic,
          color: colorScheme.error,
        ),
        fillColor: fillColor ?? colorScheme.surface,
        filled: true,
        border: baseBorder,
        enabledBorder: baseBorder,
        focusedBorder: baseBorder.copyWith(
          borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
        ),
        errorBorder: baseBorder.copyWith(
          borderSide: BorderSide(color: colorScheme.error),
        ),
      ),
    );
  }
}
