enum MembershipStatus {
  free,
  paidMonthly,
  paidYearly;

  @override
  String toString() => switch (this) {
    MembershipStatus.free => '무료 회원',
    MembershipStatus.paidMonthly => '월간 유료 회원',
    MembershipStatus.paidYearly => '연간 유료 회원',
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

  bool get isPaid => this == MembershipStatus.paidMonthly || this == MembershipStatus.paidYearly;

  /// 각 회원 타입에 따른 유효기간
  Duration? get validityDuration => switch (this) {
    MembershipStatus.paidMonthly => const Duration(days: 30),
    MembershipStatus.paidYearly => const Duration(days: 365),
    _ => null,
  };
}