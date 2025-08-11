import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/data/fire_base/firestore_keys.dart';
import '../../../core/domain/core_domain_import.dart';
import '../../../core/presentation/core_presentation_import.dart';
import '../../../domain/model/customer_model.dart';
import '../../../domain/model/history_model.dart';
import '../../../domain/model/policy_model.dart';
import '../../../domain/model/user_model.dart';

class FBase {
  // ───────────────────────────── Auth helper ─────────────────────────────
  String get _userId => FirebaseAuth.instance.currentUser?.uid ?? '';

  DocumentReference<Map<String, dynamic>> _userDoc(String userId) =>
      FirebaseFirestore.instance.collection(collectionUsers).doc(userId);

  CollectionReference<Map<String, dynamic>> _customersCol(String userId) =>
      _userDoc(userId).collection(collectionCustomers);

  DocumentReference<Map<String, dynamic>> _customerDoc(
    String userId,
    String customerKey,
  ) => _customersCol(userId).doc(customerKey);

  CollectionReference<Map<String, dynamic>> _subCol(
    String userId,
    String customerKey,
    String subColName,
  ) => _customerDoc(userId, customerKey).collection(subColName);

  // ───────────────────────────── User ─────────────────────────────
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

  // ───────────────────────────── Customer ─────────────────────────────

  Future<void> registerCustomer({
    required String userKey,
    required Map<String, dynamic> customerData,
    required Map<String, dynamic> historyData,
  }) async {
    final customerRef = _customerDoc(userKey, customerData[keyCustomerKey]);
    final historyRef =
        _subCol(
          userKey,
          customerData[keyCustomerKey],
          collectionHistories,
        ).doc();

    await FirebaseFirestore.instance.runTransaction((tx) async {
      tx.set(customerRef, customerData);
      tx.set(historyRef, historyData);
    });
  }

  Future<void> updateCustomer({
    required String userKey,
    required Map<String, dynamic> customerData,
  }) async =>
      _customerDoc(userKey, customerData[keyCustomerKey]).update(customerData);

  Future<void> deleteCustomer({
    required String userKey,
    required String customerKey,
  }) async {
    final ref = _customerDoc(userKey, customerKey);

    Future<void> deleteSub(String sub) async {
      final subRef = _subCol(userKey, customerKey, sub);
      final snapshot = await subRef.limit(1).get();
      if (snapshot.size > 0) {
        final allDocs = await subRef.get();
        await Future.wait(allDocs.docs.map((d) => d.reference.delete()));
      }
    }

    await Future.wait([
      deleteSub(collectionHistories),
      deleteSub(collectionTodos),
      deleteSub(collectionPolicies),
    ]);
    await ref.delete();
  }

  Future<List<CustomerModel>> getAllCustomers(String userKey) async {
    final snapshot = await _customersCol(
      userKey,
    ).get(const GetOptions(source: Source.serverAndCache));
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

  Future<List<CustomerModel>> getEditedAll({required String userKey}) async {
    final snapshot = await _customersCol(
      userKey,
    ).get(const GetOptions(source: Source.server));

    // 각 고객 문서에 대해 policies도 병렬로 로드
    final List<Future<CustomerModel>> futures =
        snapshot.docs.map((doc) async {
          final customer = CustomerModel.fromMap(
            doc.data(),
            doc.id,
            documentReference: doc.reference,
          );

          // policies 서브컬렉션 가져오기
          final policySnapshot =
              await doc.reference.collection(collectionPolicies).get();
          customer.policies =
              policySnapshot.docs
                  .map((p) => PolicyModel.fromMap(p.data()))
                  .toList();

          return customer;
        }).toList();

    return await Future.wait(futures);
  }

  // ───────────────────────────── History ─────────────────────────────

  Stream<QuerySnapshot<Map<String, dynamic>>> getHistories({
    required String userKey,
    required String customerKey,
  }) => _subCol(userKey, customerKey, collectionHistories).snapshots();

  Future<void> addHistory({
    required String userKey,
    required String customerKey,
    required Map<String, dynamic> historyData,
  }) async {
    final ref = _subCol(userKey, customerKey, collectionHistories).doc();
    await ref.set(historyData);
  }

  // ───────────────────────────── Todos ─────────────────────────────

  Stream<QuerySnapshot<Map<String, dynamic>>> getTodos({
    required String userKey,
    required String customerKey,
  }) => _subCol(userKey, customerKey, collectionTodos).snapshots();

  Future<void> addTodo({
    required String userKey,
    required String customerKey,
    required Map<String, dynamic> todoData,
  }) async {
    final ref = _subCol(userKey, customerKey, collectionTodos).doc();
    await ref.set(todoData);
  }


  Future<void> updateTodo({
    required String userKey,
    required String customerKey,
    required String todoDocId,
    required Map<String, dynamic> todoData,
  }) async {
    final ref = _subCol(userKey, customerKey, collectionTodos).doc(todoDocId);
    await ref.update(todoData);
  }
  Future<void> deleteTodo({
    required String userKey,
    required String customerKey,
    required String todoId,
  }) async {
    final ref = _subCol(userKey, customerKey, collectionTodos).doc(todoId);
    await ref.delete();
  }

  Future<void> completeTodo({
    required String customerKey,
    required String todoId,
    required HistoryModel newHistory,
  }) async {
    final String uid = FirebaseAuth.instance.currentUser?.uid
        ?? (throw Exception("User not authenticated"));

    final todoRef = _subCol(uid, customerKey, collectionTodos).doc(todoId);
    final historyRef = _subCol(uid, customerKey, collectionHistories).doc();

    await FirebaseFirestore.instance.runTransaction((tx) async {
      final historyData = HistoryModel.toMapForHistory(
        content: newHistory.content,
        registeredDate: newHistory.contactDate,
      );

      tx.set(historyRef, historyData);
      tx.delete(todoRef);
    });
  }

  // ───────────────────────────── Policies ─────────────────────────────

  Stream<QuerySnapshot<Map<String, dynamic>>> fetchPolicies(
    String customerKey,
  ) => _subCol(_userId, customerKey, collectionPolicies).snapshots();

  Future<void> addPolicy({
    required String userKey,
    required String customerKey,
    required Map<String, dynamic> policyData,
  }) async {
    final customerRef = _customerDoc(userKey, customerKey);
    final policyRef = _subCol(
      userKey,
      customerKey,
      collectionPolicies,
    ).doc(policyData[keyPolicyKey]);

    await FirebaseFirestore.instance.runTransaction((tx) async {
      tx.update(customerRef, {
        keyCustomerBirth: policyData[keyPolicyHolderBirth],
      });
      tx.set(policyRef, policyData);
    });
  }

  Future<void> changePolicyState({
    required String customerKey,
    required String policyKey,
    required String policyState,
  }) async {
    final ref = _subCol(
      _userId,
      customerKey,
      collectionPolicies,
    ).doc(policyKey);
    await ref.update({keyPolicyState: policyState});
  }

  Future<void> updatePolicy({
    required String customerKey,
    required PolicyModel policy,
  }) async {
    final ref = _subCol(
      _userId,
      customerKey,
      collectionPolicies,
    ).doc(policy.policyKey);
    await ref.update(policy.toJson());
  }

  Future<void> deletePolicy({
    required String customerKey,
    required String policyKey,
  }) async {
    final ref = _subCol(
      _userId,
      customerKey,
      collectionPolicies,
    ).doc(policyKey);
    await ref.delete();
  }
}
