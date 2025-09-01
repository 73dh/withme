import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/data/fire_base/firestore_keys.dart';
import '../../core/domain/enum/policy_state.dart';

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
  final String premium;
  final int paymentPeriod; // ✅ 연 단위 납입기간
  final DateTime? startDate;
  final DateTime? endDate;
  final String policyState;
  final String customerKey;
  final String policyKey;
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
    required this.paymentPeriod, // 연 단위
    required this.startDate,
    required this.endDate,
    required this.policyState,
    required this.customerKey,
    required this.policyKey,
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
              : null,
      policyHolderSex: map[keyPolicyHolderSex] ?? '',
      insured: map[keyInsured] ?? '',
      insuredBirth:
          map[keyInsuredBirth] is Timestamp
              ? (map[keyInsuredBirth] as Timestamp).toDate()
              : null,
      insuredSex: map[keyInsuredSex] ?? '',
      productCategory: map[keyProductCategory] ?? '',
      insuranceCompany: map[keyInsuranceCompany] ?? '',
      productName: map[keyProductName] ?? '',
      paymentMethod: map[keyPaymentMethod] ?? '',
      premium: map[keyPremium] ?? '',
      paymentPeriod: map[keyPaymentPeriod] ?? 0,
      // 연 단위
      startDate:
          map[keyStartDate] is Timestamp
              ? (map[keyStartDate] as Timestamp).toDate()
              : null,
      endDate:
          map[keyEndDate] is Timestamp
              ? (map[keyEndDate] as Timestamp).toDate()
              : null,
      policyState: map[keyPolicyState] ?? PolicyStatus.keep.label,
      customerKey: map[keyCustomerKey] ?? '',
      policyKey: map[keyPolicyKey] ?? '',
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
    required int paymentPeriod, // 연 단위
    required DateTime startDate,
    required DateTime endDate,
    required String customerKey,
    required String policyKey,
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
    map[keyPaymentPeriod] = paymentPeriod; // 연 단위
    map[keyStartDate] = startDate;
    map[keyEndDate] = endDate;
    map[keyPolicyState] = PolicyStatus.keep.label;
    map[keyCustomerKey] = customerKey;
    map[keyPolicyKey] = policyKey;
    return map;
  }

  PolicyModel copyWith({
    String? premium,
    int? paymentPeriod, // 연 단위
    String? policyState,
    String? policyHolder,
    DateTime? policyHolderBirth,
    String? policyHolderSex,
  }) {
    return PolicyModel(
      policyHolder: policyHolder ?? this.policyHolder,
      policyHolderBirth: policyHolderBirth ?? this.policyHolderBirth,
      policyHolderSex: policyHolderSex ?? this.policyHolderSex,
      insured: insured,
      insuredBirth: insuredBirth,
      insuredSex: insuredSex,
      productCategory: productCategory,
      insuranceCompany: insuranceCompany,
      productName: productName,
      paymentMethod: paymentMethod,
      premium: premium ?? this.premium,
      paymentPeriod: paymentPeriod ?? this.paymentPeriod,
      startDate: startDate,
      endDate: endDate,
      policyState: policyState ?? this.policyState,
      customerKey: customerKey,
      policyKey: policyKey,
      documentReference: documentReference,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      keyPolicyHolder: policyHolder,
      keyPolicyHolderBirth: policyHolderBirth,
      keyPolicyHolderSex: policyHolderSex,
      keyInsured: insured,
      keyInsuredBirth: insuredBirth,
      keyInsuredSex: insuredSex,
      keyProductCategory: productCategory,
      keyInsuranceCompany: insuranceCompany,
      keyProductName: productName,
      keyPaymentMethod: paymentMethod,
      keyPremium: premium,
      keyPaymentPeriod: paymentPeriod, // 연 단위
      keyStartDate: startDate,
      keyEndDate: endDate,
      keyPolicyState: policyState,
      keyCustomerKey: customerKey,
      keyPolicyKey: policyKey,
    };
  }
}
