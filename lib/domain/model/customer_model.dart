import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:withme/core/utils/generate_customer_key.dart';

import '../../core/data/fire_base/firestore_keys.dart';
import 'history_model.dart';

class CustomerModel {
  final String userKey;
  final String customerKey;
  final String name;
  final String sex;
  final DateTime? birth;

  // final List<dynamic> policies;
  final String recommended;
  final DateTime registeredDate;
  final List<HistoryModel> histories;
  final DocumentReference? documentReference;

  CustomerModel({
    required this.userKey,
    required this.customerKey,
    required this.name,
    required this.sex,
    required this.birth,
    // required this.policies,
    required this.recommended,
    required this.registeredDate,
    required this.histories,
    required this.documentReference,
  });

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
       // policies = List.from(map[keyIsPolicy] ?? []),
       recommended = map[keyRecommendByWho] ?? '',
       registeredDate =
           map[keyRegisteredDate] == null
               ? (map[keyRegisteredDate] as Timestamp).toDate()
               : DateTime.now().toUtc(),
       histories =
           (map[keyCustomerHistory] as List<dynamic>? ?? [])
               .map((e) => HistoryModel.fromMap(e as Map<String, dynamic>))
               .toList();

  CustomerModel.fromSnapshot(DocumentSnapshot snapshot)
    : this.fromMap(
        snapshot.data() as Map<String, dynamic>,
        snapshot.id,
        documentReference: snapshot.reference,
      );

  static Map<String, dynamic> toMapForCreateCustomer({
    required String customerKey,
    required String name,
    required String sex,
    String? recommender,

    // required String history,
    DateTime? birth,
  }) {
    final map = <String, dynamic>{};
    map[keyUserKey] = 'user1';
    map[keyCustomerKey] = customerKey;
    map[keyCustomerName] = name;
    map[keyCustomerSex] = sex;
    map[keyCustomerBirth] = birth ?? '';
    // map[keyCustomerHistory] = [history];
    // map[keyIsPolicy] = [];
    map[keyRegisteredDate] = DateTime.now().toUtc();
    map[keyRecommendByWho] = recommender ?? '';

    return map;
  }

  @override
  String toString() {
    return 'CustomerModel{customerKey: $customerKey}';
  }
}
