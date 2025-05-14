import 'package:flutter/material.dart';

class PolicyViewModel with ChangeNotifier {
  Future addPolicy({required Map<String, dynamic> policyMap}) async {
    print(policyMap);
  }
}
