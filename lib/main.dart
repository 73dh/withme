import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:withme/core/di/setup.dart';

import 'app.dart';
import 'core/data/fire_base/firebase_options.dart';
import 'core/di/di_setup_import.dart';
import 'presentation/home/dash_board/dash_board_view_model.dart';
import 'presentation/home/search/search_page_view_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  diSetup();

  runApp(const App());
}
