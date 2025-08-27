import '../../domain/model/policy_model.dart';
DateTime? getEarliestUpcomingBirthday(List<PolicyModel> policies) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  final upcomingBirthdays = policies
      .where((p) => p.insuredBirth != null)
      .map((p) {
    final birth = p.insuredBirth!;
    DateTime thisYear = DateTime(today.year, birth.month, birth.day);

    if (thisYear.isBefore(today)) {
      thisYear = DateTime(today.year + 1, birth.month, birth.day);
    }
    return thisYear;
  })
      .toList();

  if (upcomingBirthdays.isEmpty) return null;

  return upcomingBirthdays.reduce((a, b) => a.isBefore(b) ? a : b);
}
