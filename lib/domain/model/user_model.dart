import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/data/fire_base/firestore_keys.dart';
import '../../core/domain/enum/membership_status.dart';

class UserModel {
  final String userKey;
  final String email;
  final DateTime agreedDate;
  final MembershipStatus membershipStatus;
  final DateTime? paidAt; // 유료 결제일
  // final int prospectCycleDays; // ✅ 가망고객 관리주기
  final DocumentReference? documentReference;

  UserModel({
    required this.userKey,
    required this.email,
    required this.agreedDate,
    required this.membershipStatus,
    this.paidAt,
    // this.prospectCycleDays = 60, // ✅ 기본값 60
    this.documentReference,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userKey: json[keyUserKey] as String,
      email: json[keyEmail] as String,
      agreedDate: (json[keyAgreedDate] as Timestamp).toDate(),
      membershipStatus:
      MembershipStatusExtension.fromString(json[keyMembershipStatus] ?? 'free'),
      paidAt: json[keyPaidAt] != null
          ? (json[keyPaidAt] as Timestamp).toDate()
          : null,
      // prospectCycleDays: (json['prospectCycleDays'] as int?) ?? 60, // ✅
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
      membershipStatus:
      MembershipStatusExtension.fromString(map[keyMembershipStatus] ?? 'free'),
      paidAt: map[keyPaidAt] != null
          ? (map[keyPaidAt] as Timestamp).toDate()
          : null,
      // prospectCycleDays: (map['prospectCycleDays'] as int?) ?? 60, // ✅
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
      if (paidAt != null) keyPaidAt: Timestamp.fromDate(paidAt!),
    };
  }

  @override
  String toString() {
    return 'UserModel{userKey: $userKey, email: $email, agreedDate: $agreedDate, '
        'membershipStatus: ${membershipStatus.name}, paidAt: $paidAt}';
  }

  /// 유료회원 유효한지 검사
  bool get isMembershipValid {
    if (membershipStatus == MembershipStatus.free || paidAt == null) {
      return false;
    }

    final validity = membershipStatus.validityDuration;
    if (validity == null) return false;

    return paidAt!.add(validity).isAfter(DateTime.now());
  }

  /// 유효기간 만료일 반환
  DateTime? get membershipExpiresAt {
    if (paidAt == null) return null;
    return paidAt!.add(membershipStatus.validityDuration ?? Duration.zero);
  }

  UserModel copyWith({
    String? userKey,
    String? email,
    DateTime? agreedDate,
    MembershipStatus? membershipStatus,
    DateTime? paidAt,
    // int? prospectCycleDays,
    DocumentReference? documentReference,
  }) {
    return UserModel(
      userKey: userKey ?? this.userKey,
      email: email ?? this.email,
      agreedDate: agreedDate ?? this.agreedDate,
      membershipStatus: membershipStatus ?? this.membershipStatus,
      paidAt: paidAt ?? this.paidAt,
      // prospectCycleDays: prospectCycleDays ?? this.prospectCycleDays,
      documentReference: documentReference ?? this.documentReference,
    );
  }

}