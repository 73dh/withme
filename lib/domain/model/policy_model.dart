import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:withme/core/fire_base/firestore_keys.dart';

class PolicyModel {
  final DateTime policyDate;
  final String productName;
  final DocumentReference? documentReference;

  PolicyModel({
    required this.policyDate,
    required this.productName,
    required this.documentReference,
  });

  PolicyModel.fromMap(Map<String, dynamic> map, {this.documentReference})
    : policyDate = map[keyPolicyDate],
      productName = map[keyProductName];

  PolicyModel.fromSnapshot(DocumentSnapshot snapshot)
    : this.fromMap(
        snapshot.data() as Map<String, dynamic>,
        documentReference: snapshot.reference,
      );

  static Map<String, dynamic> toMapForCreatePolicy() {
    final map = <String, dynamic>{};
    map[keyPolicyDate] = 'policy date';
    map[keyProductName] = '상품명';
    return map;
  }
}
