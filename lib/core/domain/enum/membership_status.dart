enum MembershipStatus{
  free,paid;

  @override
  String toString() => switch (this) {
    MembershipStatus.free => '무료 회원',
    MembershipStatus.paid => '유료 회원',
  };
}

extension MembershipStatusExtension on MembershipStatus {
  String get name => toString().split('.').last;

  static MembershipStatus fromString(String value) {
    return MembershipStatus.values.firstWhere(
          (e) => e.name == value,
      orElse: () => MembershipStatus.free,
    );
  }
}