enum MembershipStatus{
  free,paid;
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