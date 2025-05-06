import 'package:flutter/material.dart';

void renderSnackBar(BuildContext context, {required String text}) {
  SnackBar snackBar = SnackBar(content: Text(text));
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
