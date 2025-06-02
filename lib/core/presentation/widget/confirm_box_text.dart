import 'package:flutter/material.dart';
import 'package:withme/core/ui/color/color_style.dart';

class ConfirmBoxText extends StatelessWidget {
  final String? text;
  final String? text2;
  final double size;
  const ConfirmBoxText({super.key, this.text, this.text2,  this.size=16});


  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: TextStyle(fontSize: size),
        children: [
          TextSpan(text: text, style: const TextStyle(color: Colors.black87)),
          TextSpan(
            text: text2,
            style:  TextStyle(
              color: ColorStyles.confirmTextColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );

  }
}
