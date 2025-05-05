import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:withme/core/utils/generate_customer_key.dart';

import '../../core/fire_base/firestore_keys.dart';
import 'customer_history.dart';

class Customer {
  final String userKey;
  final String customerKey;
  final String name;
  final DateTime? birth;
  final bool isPolicy;
  final String recommended;
  final DateTime registeredDate;
  final List<CustomerHistory> histories;
  final DocumentReference? documentReference;

  Customer({
    required this.userKey,
    required this.customerKey,
    required this.name,
    required this.birth,
    required this.isPolicy,
    required this.recommended,
    required this.registeredDate,
    required this.histories,
    required this.documentReference,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      userKey: json['userKey'] as String,
      customerKey: json['customerKey'] as String,
      name: json['name'] as String,
      birth: json['birth'] != null ? DateTime.parse(json['birth']) : null,
      isPolicy: json['isPolicy'] ?? false,
      recommended: json['recommended'] as String,
      registeredDate: DateTime.parse(json['registeredDate']),
      histories:
          (json['histories'] as List<dynamic>? ?? [])
              .map((e) => CustomerHistory.fromJson(e as Map<String, dynamic>))
              .toList(),
      documentReference: json['documentReference'] as DocumentReference?,
    );
  }

  Customer.fromMap(
    Map<String, dynamic> map,
    this.userKey, {
    this.documentReference,
  }) : customerKey = map[keyCustomerKey] ?? '',
       name = map[keyCustomerName] ?? '',
       birth =
           map[keyCustomerBirth] != null
               ? DateTime.parse(map[keyCustomerBirth])
               : null,
       isPolicy = map[keyIsPolicy] ?? false,
       recommended = map[keyRecommendByWho] ?? '',
       registeredDate =
           map[keyRegisteredDate] == null
               ? (map[keyRegisteredDate] as Timestamp).toDate()
               : DateTime.now().toUtc(),
       histories =
           (map[keyCustomerHistory] as List<dynamic>? ?? [])
               .map((e) => CustomerHistory.fromMap(e as Map<String, dynamic>))
               .toList();

  Customer.fromSnapshot(DocumentSnapshot snapshot)
    : this.fromMap(
        snapshot.data() as Map<String, dynamic>,
        snapshot.id,
        documentReference: snapshot.reference,
      );

  static Map<String, dynamic> toMapForCreateCustomer({ required String name}) {
    final map = <String, dynamic>{};
    map[keyUserKey] = 'user1';
    map[keyCustomerKey] = generateCustomerKey('user1');
    map[keyCustomerName] = name;
    map[keyCustomerBirth] = '';
    map[keyCustomerHistory] = [];
    map[keyIsPolicy] = '';
    map[keyRegisteredDate] = DateTime.now().toUtc();
    map[keyRecommendByWho] = '';

    return map;
  }
}
