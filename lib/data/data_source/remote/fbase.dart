import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:withme/core/data/fire_base/user_session.dart';

import '../../../core/data/fire_base/firestore_keys.dart';
import '../../../domain/model/customer_model.dart';
import '../../../domain/model/policy_model.dart';
import '../../../domain/model/user_model.dart';

class FBase {
  // User
  Future<DocumentSnapshot<Map<String, dynamic>>> getUserInfo() async {
    return await FirebaseFirestore.instance
        .collection(collectionUsers)
        .doc(UserSession.userId)
        .get();

  }

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

    await FirebaseFirestore.instance.runTransaction((Transaction tx) async {
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

  Future<void> deleteCustomer({
    required String userKey,
    required String customerKey,
  }) async {
    final customerRef = FirebaseFirestore.instance
        .collection(collectionUsers)
        .doc(userKey)
        .collection(collectionCustomer)
        .doc(customerKey);

    // 하위 컬렉션 삭제 (예: histories 존재할 경우)
    final historiesCollection = customerRef.collection(collectionHistories);
    final histories = await historiesCollection.get();
    for (var doc in histories.docs) {
      await doc.reference.delete();
    }

    // 상위 문서 삭제
    await customerRef.delete();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getAll({
    required String userKey,
  }) {
    return FirebaseFirestore.instance
        .collection(collectionUsers)
        .doc(userKey)
        .collection(collectionCustomer)
        .snapshots();
  }

  Future<List<CustomerModel>> getEditedAll({required String userKey}) async {
    final snapshot = await FirebaseFirestore.instance
        .collection(collectionUsers)
        .doc(userKey)
        .collection(collectionCustomer)
        .get(const GetOptions(source: Source.server)); // ✅ 서버에서 강제 fetch

    return snapshot.docs
        .map(
          (doc) => CustomerModel.fromMap(
            doc.data(),
            doc.id,
            documentReference: doc.reference,
          ),
        )
        .toList();
  }

  // History
  Stream<QuerySnapshot<Map<String, dynamic>>> getHistories({
    required String userKey,
    required String customerKey,
  }) {
    return FirebaseFirestore.instance
        .collection(collectionUsers)
        .doc(userKey)
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
    await FirebaseFirestore.instance.runTransaction((Transaction tx) async {
      tx.set(historyRef, historyData);
    });
  }

  // Policy

  Stream<QuerySnapshot<Map<String, dynamic>>> fetchPolicies({
    required String customerKey,
  }) {
    return FirebaseFirestore.instance
        .collection(collectionUsers)
        .doc(UserSession.userId)
        .collection(collectionCustomer)
        .doc(customerKey)
        .collection(collectionPolicies)
        .snapshots();
  }

  Future<void> addPolicy({
    required String userKey,
    required String customerKey,
    required Map<String, dynamic> policyData,
  }) async {
    DocumentReference customerRef = FirebaseFirestore.instance
        .collection(collectionUsers)
        .doc(UserSession.userId)
        .collection(collectionCustomer)
        .doc(customerKey);

    DocumentReference policyRef = FirebaseFirestore.instance
        .collection(collectionUsers)
        .doc(UserSession.userId)
        .collection(collectionCustomer)
        .doc(customerKey)
        .collection(collectionPolicies)
        .doc(policyData[keyPolicyKey]);

    await FirebaseFirestore.instance.runTransaction((Transaction tx) async {
      tx.update(customerRef, {
        keyCustomerBirth: policyData[keyPolicyHolderBirth],
      });
      tx.set(policyRef, policyData);
    });

    await policyRef.set(policyData);
  }

  Future<void> changePolicyState({
    required String customerKey,
    required String policyKey,
    required String policyState,
  }) async {
    DocumentReference policyRef = FirebaseFirestore.instance
        .collection(collectionUsers)
        .doc(UserSession.userId)
        .collection(collectionCustomer)
        .doc(customerKey)
        .collection(collectionPolicies)
        .doc(policyKey); // <- 기존 정책 문서의 key 사용

    await policyRef.update({
      keyPolicyState: policyState, // 이 필드만 업데이트됨
    });
  }

  Future<void> updatePolicy({
    required String customerKey,
    required PolicyModel policy,
  }) async {
    try {
      DocumentReference policyRef = FirebaseFirestore.instance
          .collection(collectionUsers)
          .doc(UserSession.userId)
          .collection(collectionCustomer)
          .doc(customerKey)
          .collection(collectionPolicies)
          .doc(policy.policyKey);

      await policyRef.update(policy.toJson());
    } catch (e) {
      log('Error updating policy: $e');
    }
  }
}
