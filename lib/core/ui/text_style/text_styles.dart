import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

abstract interface class TextStyles {
  static const normal12 = TextStyle(fontSize: 12);
  static const normal13 = TextStyle(fontSize: 13);
  static const bold12 = TextStyle(fontWeight: FontWeight.bold, fontSize: 12);
  static const bold14 = TextStyle(fontWeight: FontWeight.bold, fontSize: 14);
  static const bold16 = TextStyle(fontWeight: FontWeight.bold, fontSize: 16);
  static const bold20 = TextStyle(fontWeight: FontWeight.bold, fontSize: 20);
  static const errorStyle = TextStyle(
    color: Colors.red,
    fontSize: 12,
    fontStyle: FontStyle.italic,
  );
  static const hintStyle = TextStyle(color: Colors.blueGrey, fontSize: 14.0);
  static const labelStyle = TextStyle(color: Colors.black87, fontSize: 14.0);
  static const iconTextStyle = TextStyle(color: Colors.black87, fontSize: 8.0,fontStyle: FontStyle.italic);
}
