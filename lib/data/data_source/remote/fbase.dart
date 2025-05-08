import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:withme/core/fire_base/firestore_keys.dart';

import '../../../domain/model/history_model.dart';

class FBase {

  // Customer

  Future registerCustomer({
    required String userKey,
    required Map<String, dynamic> customerData,
    required Map<String, dynamic> historyData,
  }) async {
    DocumentReference customerRef = FirebaseFirestore.instance
        .collection(collectionUsers)
        .doc(userKey)
        .collection(collectionCustomer)
        .doc(customerData[keyCustomerKey]);
    DocumentReference policyRef =
        customerRef.collection(collectionPolicies).doc();
    DocumentReference historyRef =
        customerRef.collection(collectionHistories).doc();

    FirebaseFirestore.instance.runTransaction((Transaction tx) async {
      tx.set(customerRef, customerData);
      tx.set(policyRef, {'test': 'test'});
      tx.set(historyRef, historyData);
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getPools() {
    return FirebaseFirestore.instance
        .collection(collectionUsers)
        .doc('user1')
        .collection(collectionCustomer)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> fetchHistories({
    required String customerKey,
  }) {
    return FirebaseFirestore.instance
        .collection(collectionUsers)
        .doc('user1')
        .collection(collectionCustomer)
        .doc(customerKey)
        .collection(collectionHistories)
        .snapshots();
  }

  Future<void> addHistory(HistoryModel history)async{
    
  }
}
