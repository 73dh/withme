import '../../../domain/model/history_model.dart';
import '../data/fire_base/user_session.dart';
import '../di/setup.dart';

class HistoryCheckResult {
  final HistoryModel recent;
  final HistoryModel? previous;
  final bool showReminder;

  HistoryCheckResult({
    required this.recent,
    required this.previous,
    required this.showReminder,
  });
}

HistoryCheckResult showHistoryUtil(List<HistoryModel> histories) {
  final int count = histories.length;
  final recent = histories[count - 1];
  final previous = count >= 2 ? histories[count - 2] : null;

  final now = DateTime.now();
  final managePeriod = getIt<UserSession>().managePeriodDays;

  final isOld = now.difference(recent.contactDate).inDays >= managePeriod;
  final noRecentFollowUp = histories
      .where((h) => h != recent)
      .every((h) => h.contactDate.isBefore(
      recent.contactDate.add(const Duration(days: 90))));

  final showReminder = isOld && noRecentFollowUp;

  return HistoryCheckResult(
    recent: recent,
    previous: previous,
    showReminder: showReminder,
  );
}

