import 'package:flutter/material.dart';

import '../../ui/icon/const.dart';


Widget sexIcon(String sex) => switch (sex) {
  '남' => Image.asset(IconsPath.manIcon, width: 15,color: Colors.blueAccent,),
  _ => Image.asset(IconsPath.womanIcon, width: 15,color: Colors.redAccent,),
};
