import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/data/fire_base/firestore_keys.dart';
import '../../core/domain/enum/membership_status.dart';

class UserModel {
  final String userKey;
  final String email;
  final DateTime agreedDate;
  final MembershipStatus membershipStatus;
  final DocumentReference? documentReference;

  UserModel({
    required this.userKey,
    required this.email,
    required this.agreedDate,
    required this.membershipStatus,
    this.documentReference,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userKey: json[keyUserKey] as String,
      email: json[keyEmail] as String,
      agreedDate: (json[keyAgreedDate] as Timestamp).toDate(),
      membershipStatus: MembershipStatusExtension.fromString(json[keyMembershipStatus] ?? 'free'),
      documentReference: json['documentReference'] as DocumentReference?,
    );
  }

  factory UserModel.fromMap(
      Map<String, dynamic> map,
      String userKey, {
        DocumentReference? documentReference,
      }) {
    return UserModel(
      userKey: userKey,
      email: map[keyEmail] ?? '',
      agreedDate: (map[keyAgreedDate] as Timestamp).toDate(),
      membershipStatus: MembershipStatusExtension.fromString(map[keyMembershipStatus] ?? 'free'),
      documentReference: documentReference,
    );
  }

  factory UserModel.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return UserModel.fromMap(data, snapshot.id, documentReference: snapshot.reference);
  }

  Map<String, dynamic> toMap() {
    return {
      keyUserKey: userKey,
      keyEmail: email,
      keyAgreedDate: Timestamp.fromDate(agreedDate),
      keyMembershipStatus: membershipStatus.name,
    };
  }

  @override
  String toString() {
    return 'UserModel{userKey: $userKey, email: $email, agreedDate: $agreedDate, membershipStatus: ${membershipStatus.name}}';
  }
}