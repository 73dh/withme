import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:withme/core/data/fire_base/user_session.dart';

import '../../../core/data/fire_base/firestore_keys.dart';
import '../../../core/domain/core_domain_import.dart';
import '../../../core/presentation/core_presentation_import.dart';
import '../../../domain/model/customer_model.dart';
import '../../../domain/model/policy_model.dart';
import '../../../domain/model/user_model.dart';

class FBase {
  // User
  Future<DocumentSnapshot<Map<String, dynamic>>> getUserInfo() async {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (userId.isEmpty) {
      throw Exception('FirebaseAuth returned empty userId');
    }

    return await FirebaseFirestore.instance
        .collection(collectionUsers)
        .doc(userId)
        .get();
  }

  Future<void> createUser({
    required String userId,
    required String email,
  }) async {
    final docRef = FirebaseFirestore.instance
        .collection(collectionUsers)
        .doc(userId);

    final snapshot = await docRef.get();

    if (!snapshot.exists) {
      final user = UserModel(
        userKey: userId,
        email: email,
        membershipStatus: MembershipStatus.free,
        paidAt: DateTime(2020),
        agreedDate: DateTime.now(),
      );

      await docRef.set(user.toMap());
      debugPrint('✅ 새 사용자 생성 완료');
    } else {
      debugPrint('ℹ️ 사용자 이미 존재함. 생성 생략');
    }
  }

  Future<void> deleteUserAccountAndData({
    required String userId,
    required String email,
    required String password,
  }) async {
    final userDocRef = FirebaseFirestore.instance
        .collection(collectionUsers)
        .doc(userId);

    try {
      final user = FirebaseAuth.instance.currentUser!;

      // 🔸 1. 재인증 (email/password 로그인 사용자 기준)
      final credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );
      await user.reauthenticateWithCredential(credential);

      // 🔸 2. Firestore 사용자 데이터 삭제
      await userDocRef.delete();

      // 🔸 3. Firebase Auth 계정 삭제
      await user.delete();

      debugPrint('계정과 데이터가 모두 삭제되었습니다.');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        debugPrint('비밀번호가 틀렸습니다.');
      } else if (e.code == 'user-mismatch') {
        debugPrint('계정이 일치하지 않습니다.');
      } else {
        debugPrint('FirebaseAuth 오류: ${e.message}');
      }
      rethrow;
    } catch (e) {
      debugPrint('알 수 없는 오류: $e');
      rethrow;
    }
  }

  // Customer

  Future registerCustomer({
    required String userKey,
    required Map<String, dynamic> customerData,
    required Map<String, dynamic> historyData,
    required Map<String,dynamic> todoData,
  }) async {
    DocumentReference customerRef = FirebaseFirestore.instance
        .collection(collectionUsers)
        .doc(userKey)
        .collection(collectionCustomer)
        .doc(customerData[keyCustomerKey]);
    DocumentReference historyRef =
        customerRef.collection(collectionHistories).doc();
    DocumentReference todoRef =
    customerRef.collection(collectionTodos).doc();

    await FirebaseFirestore.instance.runTransaction((Transaction tx) async {
      tx.set(customerRef, customerData);
      tx.set(historyRef, historyData);
      tx.set(todoRef, todoData);
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

  // Todos
  Stream<QuerySnapshot<Map<String, dynamic>>> getTodos({
    required String userKey,
    required String customerKey,
  }) {
    return FirebaseFirestore.instance
        .collection(collectionUsers)
        .doc(userKey)
        .collection(collectionCustomer)
        .doc(customerKey)
        .collection(collectionTodos)
        .snapshots();
  }
  Future<void> addTodo({
    required String userKey,
    required String customerKey,
    required Map<String, dynamic> todoData,
  }) async {
    DocumentReference todoRef =
    FirebaseFirestore.instance
        .collection(collectionUsers)
        .doc(userKey)
        .collection(collectionCustomer)
        .doc(customerKey)
        .collection(collectionTodos)
        .doc();
    await FirebaseFirestore.instance.runTransaction((Transaction tx) async {
      tx.set(todoRef, todoData);
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

  Future<void> deletePolicy({
    required String customerKey,
    required String policyKey,
  }) async {
    try {
      DocumentReference policyRef = FirebaseFirestore.instance
          .collection(collectionUsers)
          .doc(UserSession.userId)
          .collection(collectionCustomer)
          .doc(customerKey)
          .collection(collectionPolicies)
          .doc(policyKey);
      await policyRef.delete();
    } catch (e) {
      log('Error deleting policy: $e');
    }
  }
}
