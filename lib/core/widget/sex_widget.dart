import 'package:flutter/material.dart';

import '../ui/icon/const.dart';

Widget sexIcon(String sex) => switch (sex) {
  'man' => Image.asset(IconsPath.manIcon, width: 15),
  _ => Image.asset(IconsPath.womanIcon, width: 15),
};
