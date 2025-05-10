import 'package:flutter/material.dart';

Future<DateTime?> selectBirth(BuildContext context){
  return showDatePicker(context: context, firstDate: DateTime(1920), lastDate: DateTime(2050));
}