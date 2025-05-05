import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:withme/core/fire_base/firestore_keys.dart';

import '../../mock/mock_customer.dart';

class FBase {
  // Customer

  Future registerCustomer({
    required String userKey,
    required Map<String, dynamic> customerData,
  }) async {
    DocumentReference customerRef = FirebaseFirestore.instance
        .collection(collectionUsers)
        .doc(userKey)
        .collection(collectionCustomer)
        .doc(customerData[keyCustomerKey]);
    customerRef.set(customerData);
  }

  Future<List<Map<String, dynamic>>> getCustomers() async {
    return mockCustomers;
  }
}
