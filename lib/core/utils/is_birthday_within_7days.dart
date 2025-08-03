bool isBirthdayWithin7Days(DateTime birthDate) {
  final now = getTodayDateOnly();
  final thisYearBirthday = DateTime(now.year, birthDate.month, birthDate.day);
  final difference = thisYearBirthday.difference(now).inDays;

  if (difference >= 0 && difference <= 7) {
    return true;
  }

  final nextYearBirthday = DateTime(now.year + 1, birthDate.month, birthDate.day);
  final nextDifference = nextYearBirthday.difference(now).inDays;

  return nextDifference >= 0 && nextDifference <= 7;
}

int getBirthdayCountdown(DateTime birthDate) {
  final now = getTodayDateOnly();
  final thisYearBirthday = DateTime(now.year, birthDate.month, birthDate.day);
  int days = thisYearBirthday.difference(now).inDays;

  if (days < 0) {
    final nextYearBirthday = DateTime(now.year + 1, birthDate.month, birthDate.day);
    days = nextYearBirthday.difference(now).inDays;
  }

  return days;
}

DateTime getTodayDateOnly() {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day); // 시간 제거
}
