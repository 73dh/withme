import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:withme/domain/model/policy_model.dart';
import 'package:withme/domain/model/todo_model.dart';

import '../../core/data/fire_base/firestore_keys.dart';
import '../../core/data/fire_base/user_session.dart';
import '../../core/di/setup.dart';
import '../../core/utils/days_until_insurance_age.dart';
import 'history_model.dart';

class CustomerModel {
  final String userKey;
  final String customerKey;
  final String name;
  final String sex;
  final DateTime? birth;
  List<PolicyModel> policies;
  final String recommended;
  final DateTime registeredDate;
  final List<HistoryModel> histories;
  final List<TodoModel> todos; // TodoModel 리스트 반영
  final DocumentReference? documentReference;
  final String memo; // 메모 필드

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
    this.todos = const [], // 기본 빈 리스트
    this.documentReference,
    required this.memo,
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
      policies:
          (json[keyIsPolicy] as List<dynamic>? ?? [])
              .map((e) => PolicyModel.fromJson(e as Map<String, dynamic>))
              .toList(),
      recommended: json[keyRecommendByWho] as String? ?? '',
      registeredDate: (json[keyRegisteredDate] as Timestamp).toDate(),
      histories:
          (json[keyCustomerHistory] as List<dynamic>? ?? [])
              .map((e) => HistoryModel.fromJson(e as Map<String, dynamic>))
              .toList(),
      todos:
          (json[keyCustomerTodo] as List<dynamic>? ?? [])
              .map((e) => TodoModel.fromJson(e as Map<String, dynamic>))
              .toList(),
      documentReference: json[keyDocumentRef] as DocumentReference?,
      memo: json[keyCustomerMemo] as String? ?? '',
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
       policies = [],
       // (map[keyIsPolicy] as List<dynamic>? ?? [])
       //     .map((e) => PolicyModel.fromMap(e as Map<String, dynamic>))
       //     .toList(),
       recommended = map[keyRecommendByWho] ?? '',
       registeredDate = (map[keyRegisteredDate] as Timestamp).toDate(),
       histories =
           (map[keyCustomerHistory] as List<dynamic>? ?? [])
               .map((e) => HistoryModel.fromMap(e as Map<String, dynamic>))
               .toList(),
       todos =
           (map[keyCustomerTodo] as List<dynamic>? ?? [])
               .map((e) => TodoModel.fromMap(e as Map<String, dynamic>))
               .toList(),
       memo = map[keyCustomerMemo] ?? '';

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
    required String memo,
  }) {
    final map = <String, dynamic>{};
    map[keyUserKey] = userKey;
    map[keyCustomerKey] = customerKey;
    map[keyCustomerName] = name;
    map[keyCustomerSex] = sex;
    map[keyCustomerBirth] = birth ?? '';
    map[keyRegisteredDate] = registeredDate;
    map[keyRecommendByWho] = recommender ?? '';
    map[keyCustomerMemo] = memo;
    return map;
  }

  @override
  String toString() {
    return 'CustomerModel{userKey: $userKey, customerKey: $customerKey, name: $name, sex: $sex, birth: $birth, policies: $policies, recommended: $recommended, registeredDate: $registeredDate, histories: $histories, todos: $todos, documentReference: $documentReference, memo: $memo}';
  }

  CustomerModel copyWith({
    List<PolicyModel>? policies,
    List<HistoryModel>? histories,
    List<TodoModel>? todos,
    String? memo,
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
      todos: todos ?? this.todos,
      documentReference: documentReference,
      memo: memo ?? this.memo,
    );
  }
}

extension CustomerInsuranceInfo on CustomerModel {
  ({int? difference, DateTime? insuranceChangeDate, bool isUrgent})
  get insuranceInfo {
    final birthDate = birth;
    final userSession = getIt<UserSession>();

    if (birthDate == null) {
      return (difference: null, insuranceChangeDate: null, isUrgent: false);
    }

    final insuranceChangeDate = getInsuranceAgeChangeDate(birthDate);
    final difference = insuranceChangeDate.difference(DateTime.now()).inDays;
    final isUrgent =
        difference >= 0 && difference <= userSession.urgentThresholdDays;

    return (
      difference: difference,
      insuranceChangeDate: insuranceChangeDate,
      isUrgent: isUrgent,
    );
  }
}
