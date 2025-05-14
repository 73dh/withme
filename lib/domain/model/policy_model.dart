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
  final String insuranceCompany;
  final String productName;
  final String paymentMethod;
  final int premium;
  final DateTime? startDate;
  final DateTime? endDate;
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
    required this.insuranceCompany,
    required this.productName,
    required this.paymentMethod,
    required this.premium,
    required this.startDate,
    required this.endDate,
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
      insuranceCompany: map[keyInsuranceCompany] ?? '',
      productName: map[keyProductName] ?? '',
      paymentMethod: map[keyPaymentMethod] ?? '',
      premium: map[keyPremium] ?? 0,
      startDate:
          map[keyStartDate] is Timestamp
              ? (map[keyStartDate] as Timestamp).toDate()
              : DateTime.now().toUtc(),
      endDate:
          map[keyEndDate] is Timestamp
              ? (map[keyEndDate] as Timestamp).toDate()
              : DateTime.now().toUtc(),
      policyState: map[keyPolicyState] ?? '유지',
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
    required String productCategory,
    required String insuranceCompany,
    required String productName,
    required String paymentMethod,
    required String premium,

    required DateTime startDate,
    required DateTime endDate,
  }) {
    final map = <String, dynamic>{};

    map[keyPolicyHolder] = policyHolder;
    map[keyPolicyHolderBirth] = policyHolderBirth;
    map[keyPolicyHolderSex] = policyHolderSex;
    map[keyInsured] = insured;
    map[keyInsuredBirth] = insuredBirth;
    map[keyInsuredSex] = insuredSex;
    map[keyProductCategory] = productCategory;
    map[keyInsuranceCompany] = insuranceCompany;
    map[keyProductName] = productName;
    map[keyPaymentMethod] = paymentMethod;
    map[keyPremium] = premium;
    map[keyStartDate] = startDate;
    map[keyEndDate] = endDate;
    map[keyPolicyState] = '유지';

    return map;
  }
}
