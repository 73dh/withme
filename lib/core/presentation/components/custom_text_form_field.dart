import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../ui/text_style/text_styles.dart';
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

  const CustomTextFormField({
    super.key,
    this.controller,
    this.hintText,
    this.labelText,
    this.obscureText = false,
    this.autoFocus = false,
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
      textAlign: textAlign!,
      style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
      // 입력 글자 색상
      keyboardType: inputType,
      inputFormatters: inputFormatters,
      onEditingComplete: onCompleted,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        hintText: hintText,
        hintStyle: theme.textTheme.labelMedium?.copyWith(
          fontStyle: FontStyle.italic,
          color: theme.primaryColor,
        ),
        labelText: labelText,
        labelStyle: theme.textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
        errorStyle: theme.textTheme.labelMedium?.copyWith(
          fontStyle: FontStyle.italic,
          color: colorScheme.error,
        ),
        errorBorder: baseBorder.copyWith(
          borderSide: BorderSide(color: colorScheme.error),
        ),
        fillColor: colorScheme.surface,
        filled: true,
        border: baseBorder,
        enabledBorder: baseBorder,
        focusedBorder: baseBorder.copyWith(
          borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
        ),
      ),
      onChanged: onChanged,
      validator: validator != null ? (text) => validator!(text ?? '') : null,
      onSaved: onSaved != null ? (text) => onSaved!(text ?? '') : null,
    );
  }
}

//
// class CustomTextFormField extends StatelessWidget {
//   final TextEditingController? controller;
//   final String? hintText;
//   final String? labelText;
//   final bool obscureText;
//   final TextAlign? textAlign;
//   final TextInputType? inputType;
//   final TextStyle? textStyle;
//   final bool autoFocus;
//   final bool readOnly;
//   final List<TextInputFormatter>? inputFormatters;
//   final Function(String)? onChanged;
//   final VoidCallback? onCompleted;
//   final Function(String)? validator;
//   final Function(String)? onSaved;
//   final FocusNode? focusNode;
//
//   const CustomTextFormField({
//     super.key,
//     this.controller,
//     this.hintText,
//     this.labelText,
//     this.obscureText = false,
//     this.autoFocus = false,
//     this.textStyle,
//     this.textAlign = TextAlign.start,
//     this.inputType,
//     this.inputFormatters,
//     this.readOnly = false,
//     this.onChanged,
//     this.onCompleted,
//     this.validator,
//     this.onSaved,
//     this.focusNode,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final baseBorder = const OutlineInputBorder(borderSide: BorderSide.none);
//
//     return TextFormField(
//       controller: controller,
//       readOnly: readOnly,
//       cursorColor: Colors.black87,
//       obscureText: obscureText,
//       autofocus: autoFocus,
//       focusNode: focusNode,
//       textAlign: textAlign!,
//       style: textStyle,
//       keyboardType: inputType,
//       onEditingComplete: onCompleted,
//       decoration: InputDecoration(
//         contentPadding: EdgeInsets.zero,
//         hintText: hintText,
//         hintStyle: Theme.of(
//           context,
//         ).textTheme.labelMedium?.copyWith(fontStyle: FontStyle.italic),
//         labelText: labelText,
//         labelStyle: Theme.of(
//           context,
//         ).textTheme.bodyMedium,
//         errorStyle: Theme.of(
//           context,
//         ).textTheme.labelMedium?.copyWith(fontStyle: FontStyle.italic),
//         errorBorder: baseBorder,
//         fillColor: Colors.white,
//         filled: true,
//         border: baseBorder,
//         enabledBorder: baseBorder,
//         focusedBorder: baseBorder.copyWith(
//           borderSide: baseBorder.borderSide.copyWith(color: Colors.blueGrey),
//         ),
//       ),
//       onChanged: (text) {
//         if (onChanged != null) onChanged!(text);
//       },
//
//       validator: (text) {
//         if (validator != null) return validator!(text!);
//         return null;
//       },
//
//       onSaved: (text) {
//         if (onSaved != null) {
//           onSaved!(text!);
//         }
//       },
//     );
//   }
// }
