import '../../../domain/model/history_model.dart';
import '../data/fire_base/user_session.dart';
import '../di/setup.dart';

class HistoryCheckResult {
  final HistoryModel? recent;
  final HistoryModel? previous;
  final bool showReminder;

  HistoryCheckResult({
    required this.recent,
    required this.previous,
    required this.showReminder,
  });
}


HistoryCheckResult showHistoryUtil(List<HistoryModel> histories) {
  final validHistories = histories.where((h) => h.contactDate != null).toList()
    ..sort((a, b) => b.contactDate!.compareTo(a.contactDate!)); // 최근 이력이 먼저

  final recent = validHistories.isNotEmpty ? validHistories.first : null;
  final previous = validHistories.length > 1 ? validHistories[1] : null;

  final managePeriod = getIt<UserSession>().managePeriodDays;
  final now = DateTime.now();

  final isOld = recent == null ||
      now.difference(recent.contactDate!).inDays >= managePeriod;

  final noRecentFollowUp = recent == null ||
      validHistories
          .skip(1)
          .every((h) => h.contactDate!.isBefore(recent.contactDate!.add(const Duration(days: 90))));

  final showReminder = isOld && noRecentFollowUp;

  return HistoryCheckResult(
    recent: recent,
    previous: previous,
    showReminder: showReminder,
  );
}



