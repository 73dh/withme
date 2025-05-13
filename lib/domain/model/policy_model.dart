import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/data/fire_base/firestore_keys.dart';

class PolicyModel {
  final String policyHolder;
  final DateTime? policyHolderBirth;
  final String policyHolderSex;
  final String insured;
  final DateTime? insuredBirth;
  final String insuredSex;
  final String productCategory;
  final String productName;
  final DateTime? startDate;
  final DateTime? endDate;
  final String paymentMethod;
  final int payPeriod;
  final int price;
  final String policyState;
  final DocumentReference? documentReference;

  PolicyModel({
    required this.policyHolder,
    required this.policyHolderBirth,
    required this.policyHolderSex,
    required this.insured,
    required this.insuredBirth,
    required this.insuredSex,
    required this.productCategory,
    required this.productName,
    required this.startDate,
    required this.endDate,
    required this.paymentMethod,
    required this.payPeriod,
    required this.price,
    required this.policyState,
    this.documentReference,
  });

  factory PolicyModel.fromMap(
    Map<String, dynamic> map, {
    DocumentReference? reference,
  }) {
    return PolicyModel(
      policyHolder: map[keyPolicyHolder] ?? '',
      policyHolderBirth:
          map[keyPolicyHolderBirth] is Timestamp
              ? (map[keyPolicyHolderBirth] as Timestamp).toDate()
              : DateTime.now().toUtc(),
      policyHolderSex: map[keyPolicyHolderSex] ?? '',
      insured: map[keyInsured] ?? '',
      insuredBirth:
          map[keyInsuredBirth] is Timestamp
              ? (map[keyInsuredBirth] as Timestamp).toDate()
              : DateTime.now().toUtc(),
      insuredSex: map[keyInsuredSex] ?? '',
      productCategory: map[keyProductCategory] ?? '',
      productName: map[keyProductName] ?? '',
      startDate:
          map[keyStartDate] is Timestamp
              ? (map[keyStartDate] as Timestamp).toDate()
              : DateTime.now().toUtc(),
      endDate:
          map[keyEndDate] is Timestamp
              ? (map[keyEndDate] as Timestamp).toDate()
              : DateTime.now().toUtc(),
      paymentMethod: map[keyPaymentMethod] ?? '',
      payPeriod: map[keyPayPeriod] ?? 0,
      price: map[keyPrice] ?? 0,
      policyState: map[keyPolicyState] ?? 'active',
      // 기본값 지정 가능
      documentReference: reference,
    );
  }

  factory PolicyModel.fromJson(Map<String, dynamic> json) {
    return PolicyModel.fromMap(json);
  }

  factory PolicyModel.fromSnapshot(DocumentSnapshot snapshot) {
    return PolicyModel.fromMap(
      snapshot.data() as Map<String, dynamic>,
      reference: snapshot.reference,
    );
  }

 static Map<String, dynamic> toMapForCreatePolicy({
    required String policyHolder,
    required DateTime policyHolderBirth,
    required String policyHolderSex,
    required String insured,
    required DateTime insuredBirth,
    required String insuredSex,
    required DateTime startDate,
    required DateTime endDate,


}) {
   final map= <String, dynamic> {};

    map[keyPolicyHolder] = policyHolder;
    map[keyPolicyHolderBirth] = policyHolderBirth;
    map[keyPolicyHolderSex] = policyHolderSex;
    map[keyInsured] = insured;
    map[keyInsuredBirth] =insuredBirth;
    map[keyInsuredSex] = insuredSex;
    map[keyProductCategory] = '보험상품 카테고리';
    map[keyProductName] = '상품명';
    map[keyStartDate] =startDate;
    map[keyEndDate] = endDate;
    map[keyPaymentMethod] = '월납';
    map[keyPayPeriod] = 10;
    map[keyPrice] = 20000;
    map[keyPolicyState] = '유지';

    return map;
  }
}

// PolicyModel({
//    this.policyDate,
//    this.productName,
//   required this.documentReference,
// });
//
// PolicyModel.fromMap(Map<String, dynamic> map, {this.documentReference})
//   : policyDate = (map[keyPolicyDate] is Timestamp)
//     ? (map[keyPolicyDate] as Timestamp).toDate()
//     : null,
//     productName = map[keyProductName]??'';
//
// PolicyModel.fromSnapshot(DocumentSnapshot snapshot)
//   : this.fromMap(
//       snapshot.data() as Map<String, dynamic>,
//       documentReference: snapshot.reference,
//     );
//
// static Map<String, dynamic> toMapForCreatePolicy() {
//   final map = <String, dynamic>{};
//   map[keyPolicyDate] = 'policy date';
//   map[keyProductName] = '상품명';
//   return map;
// }
