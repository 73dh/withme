import 'package:flutter/material.dart';
import 'package:withme/core/ui/const/duration.dart';

void renderSnackBar(BuildContext context, {required String text}) {
  SnackBar snackBar = SnackBar(
    content: Text(text),
    duration: AppDurations.durationOneSec,
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
