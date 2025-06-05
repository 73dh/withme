import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:withme/core/di/setup.dart';

import 'app.dart';
import 'core/data/fire_base/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  diSetup();
  runApp(const App());
}
