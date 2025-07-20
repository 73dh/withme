import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:withme/domain/model/policy_model.dart';

import '../../core/data/fire_base/firestore_keys.dart';
import 'history_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:withme/domain/model/policy_model.dart';

import '../../core/data/fire_base/firestore_keys.dart';
import 'history_model.dart';

class CustomerModel {
  final String userKey;
  final String customerKey;
  final String name;
  final String sex;
  final DateTime? birth;
  final List<PolicyModel> policies;
  final String recommended;
  final DateTime registeredDate;
  final List<HistoryModel> histories;
  final DocumentReference? documentReference;
  final String memo; // ✅ 메모 필드 추가

  CustomerModel({
    required this.userKey,
    required this.customerKey,
    required this.name,
    required this.sex,
    required this.birth,
    this.policies = const [],
    required this.recommended,
    required this.registeredDate,
    required this.histories,
    required this.documentReference,
    required this.memo, // ✅ 기본값 공백
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      userKey: json[keyUserKey] as String,
      customerKey: json[keyCustomerKey] as String,
      name: json[keyCustomerName] as String,
      sex: json[keyCustomerSex] as String,
      birth:
          json[keyCustomerBirth] != null
              ? (json[keyCustomerBirth] as Timestamp).toDate()
              : null,
      policies: json[keyIsPolicy] ?? [],
      recommended: json[keyRecommendByWho] as String? ?? '',
      registeredDate: (json[keyRegisteredDate] as Timestamp).toDate(),
      histories:
          (json[keyCustomerHistory] as List<dynamic>? ?? [])
              .map((e) => HistoryModel.fromJson(e as Map<String, dynamic>))
              .toList(),
      documentReference: json[keyDocumentRef] as DocumentReference?,
      memo: json[keyCustomerMemo] as String? ?? '', // ✅ 메모 로딩
    );
  }

  CustomerModel.fromMap(
    Map<String, dynamic> map,
    this.userKey, {
    this.documentReference,
  }) : customerKey = map[keyCustomerKey] ?? '',
       name = map[keyCustomerName] ?? '',
       sex = map[keyCustomerSex] ?? '',
       birth =
           map[keyCustomerBirth] != ''
               ? (map[keyCustomerBirth] as Timestamp).toDate()
               : null,
       policies = List.from(map[keyIsPolicy] ?? []),
       recommended = map[keyRecommendByWho] ?? '',
       registeredDate = (map[keyRegisteredDate] as Timestamp).toDate(),
       histories =
           (map[keyCustomerHistory] as List<dynamic>? ?? [])
               .map((e) => HistoryModel.fromMap(e as Map<String, dynamic>))
               .toList(),
       memo = map[keyCustomerMemo] ?? ''; // ✅ 메모 로딩

  CustomerModel.fromSnapshot(DocumentSnapshot snapshot)
    : this.fromMap(
        snapshot.data() as Map<String, dynamic>,
        snapshot.id,
        documentReference: snapshot.reference,
      );

  static Map<String, dynamic> toMapForCreateCustomer({
    required String userKey,
    required String customerKey,
    required String name,
    required String sex,
    required DateTime registeredDate,
    String? recommender,
    DateTime? birth,
    required String memo, // ✅ 추가
  }) {
    final map = <String, dynamic>{};
    map[keyUserKey] = userKey;
    map[keyCustomerKey] = customerKey;
    map[keyCustomerName] = name;
    map[keyCustomerSex] = sex;
    map[keyCustomerBirth] = birth ?? '';
    map[keyRegisteredDate] = registeredDate;
    map[keyRecommendByWho] = recommender ?? '';
    map[keyCustomerMemo] = memo ?? ''; // ✅ 저장
    return map;
  }

  @override
  String toString() {
    return 'CustomerModel{userKey: $userKey, customerKey: $customerKey, name: $name, sex: $sex, birth: $birth, policies: $policies, recommended: $recommended, registeredDate: $registeredDate, histories: $histories, documentReference: $documentReference, memo: $memo}';
  }

  CustomerModel copyWith({
    List<PolicyModel>? policies,
    List<HistoryModel>? histories,
    String? memo, // ✅ copyWith도 반영
  }) {
    return CustomerModel(
      userKey: userKey,
      customerKey: customerKey,
      name: name,
      sex: sex,
      birth: birth,
      policies: policies ?? this.policies,
      recommended: recommended,
      registeredDate: registeredDate,
      histories: histories ?? this.histories,
      documentReference: documentReference,
      memo: memo ?? this.memo,
    );
  }
}
