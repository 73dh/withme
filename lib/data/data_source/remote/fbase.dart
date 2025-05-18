import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/data/fire_base/firestore_keys.dart';

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
    DocumentReference historyRef =
        customerRef.collection(collectionHistories).doc();

    FirebaseFirestore.instance.runTransaction((Transaction tx) async {
      tx.set(customerRef, customerData);
      tx.set(historyRef, historyData);
    });
  }

  Future updateCustomer({
    required String userKey,
    required Map<String, dynamic> customerData,
  }) async {
    DocumentReference customerRef = FirebaseFirestore.instance
        .collection(collectionUsers)
        .doc(userKey)
        .collection(collectionCustomer)
        .doc(customerData[keyCustomerKey]);

    await customerRef.update(customerData);
  }

  Future<void> deleteCustomer({required String customerKey}) async {
    DocumentReference customerRef = FirebaseFirestore.instance
        .collection(collectionUsers)
        .doc('user1')
        .collection(collectionCustomer)
        .doc(customerKey);
    await customerRef.delete();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getAll() {
    return FirebaseFirestore.instance
        .collection(collectionUsers)
        .doc('user1')
        .collection(collectionCustomer)
        .snapshots();
  }

  // History
  Stream<QuerySnapshot<Map<String, dynamic>>> getHistories({
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

  Future<void> addHistory({
    required String userKey,
    required String customerKey,
    required Map<String, dynamic> historyData,
  }) async {
    DocumentReference historyRef =
        FirebaseFirestore.instance
            .collection(collectionUsers)
            .doc(userKey)
            .collection(collectionCustomer)
            .doc(customerKey)
            .collection(collectionHistories)
            .doc();
    FirebaseFirestore.instance.runTransaction((Transaction tx) async {
      tx.set(historyRef, historyData);
    });
  }

  // Policy

  Stream<QuerySnapshot<Map<String, dynamic>>> fetchPolicies({
    required String customerKey,
  }) {
    return FirebaseFirestore.instance
        .collection(collectionUsers)
        .doc('user1')
        .collection(collectionCustomer)
        .doc(customerKey)
        .collection(collectionPolicies)
        .snapshots();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getPolicies({
    required String customerKey,
  }) {
    return FirebaseFirestore.instance
        .collection(collectionUsers)
        .doc('user1')
        .collection(collectionCustomer)
        .doc(customerKey)
        .collection(collectionPolicies)
        .get();
  }

  Future<void> addPolicy({
    required String userKey,
    required String customerKey,
    required Map<String, dynamic> policyData,
  }) async {
    DocumentReference customerRef = FirebaseFirestore.instance
        .collection(collectionUsers)
        .doc('user1')
        .collection(collectionCustomer)
        .doc(customerKey);

    DocumentReference policyRef =
        FirebaseFirestore.instance
            .collection(collectionUsers)
            .doc('user1')
            .collection(collectionCustomer)
            .doc(customerKey)
            .collection(collectionPolicies)
            .doc();

    FirebaseFirestore.instance.runTransaction((Transaction tx) async {
      tx.update(customerRef, {
        keyCustomerBirth: policyData[keyPolicyHolderBirth],
      });
      tx.set(policyRef, policyData);
    });

    await policyRef.set(policyData);
  }
}
