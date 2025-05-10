import 'package:flutter/material.dart';

void renderSnackBar(BuildContext context, {required String text}) {
  SnackBar snackBar = SnackBar(
    content: Text(text),
    duration: const Duration(seconds: 1),
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
