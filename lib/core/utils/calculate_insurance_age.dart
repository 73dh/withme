int calculateInsuranceAge(DateTime birthDate) {
  DateTime today = DateTime.now();
  int age = today.year - birthDate.year;

  DateTime thisYearsBirthday = DateTime(today.year, birthDate.month, birthDate.day);
  Duration diff = thisYearsBirthday.difference(today).abs();

  // 생일까지 6개월(183일) 이상 남았으면 +1
  if (diff.inDays >= 183) {
    age += 1;
  }

  return age;
}