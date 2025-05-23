enum SearchOption {
  noRecentHistory,
  comingBirth,
  upcomingInsuranceAge;

  @override
  String toString() => switch (this) {
    SearchOption.noRecentHistory => '직전 3개월 미관리',
    SearchOption.comingBirth => '생일(30일 이내)',
    SearchOption.upcomingInsuranceAge => '상령일 예정(10~30일)',
  };
}
