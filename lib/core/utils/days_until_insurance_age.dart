int daysUntilInsuranceAgeChange(DateTime birthDate) {
  DateTime today = DateTime.now();
  DateTime thisYearsBirthday = DateTime(today.year, birthDate.month, birthDate.day);

  // 올해 생일 기준 6개월 전 (보험상령일)
  DateTime insuranceAgeChangeDate = thisYearsBirthday.subtract(const Duration(days: 183));

  // 만약 보험상령일이 오늘보다 전이면 → 다음 해 생일 기준 보험상령일로 계산
  if (insuranceAgeChangeDate.isBefore(today)) {
    DateTime nextYearsBirthday = DateTime(today.year + 1, birthDate.month, birthDate.day);
    insuranceAgeChangeDate = nextYearsBirthday.subtract(const Duration(days: 183));
  }

  return insuranceAgeChangeDate.difference(today).inDays;
}

/// 생년월일을 기준으로 보험상령일(생일 6개월 전)을 계산하여 반환하는 함수
DateTime getInsuranceAgeChangeDate(DateTime birthDate) {
  DateTime today = DateTime.now();
  DateTime thisYearsBirthday = DateTime(today.year, birthDate.month, birthDate.day);

  // 올해 생일 기준 보험상령일: 생일 6개월 전 (183일)
  DateTime insuranceAgeChangeDate = thisYearsBirthday.subtract(const Duration(days: 183));

  // 이미 지났다면, 내년 생일 기준으로 다시 계산
  if (insuranceAgeChangeDate.isBefore(today)) {
    DateTime nextYearsBirthday = DateTime(today.year + 1, birthDate.month, birthDate.day);
    insuranceAgeChangeDate = nextYearsBirthday.subtract(const Duration(days: 183));
  }

  return insuranceAgeChangeDate;
}