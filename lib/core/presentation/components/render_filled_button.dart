import 'package:flutter/material.dart';

class RenderFilledButton extends StatelessWidget {
  final void Function() onPressed;
  final String text;
  final double borderRadius;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const RenderFilledButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.borderRadius=2,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        shape:  RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
        ),
      ),
      child:  Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: SizedBox(
          width: double.infinity,
          child: Text(text, textAlign: TextAlign.center),
        ),
      ),
    );
  }
}
