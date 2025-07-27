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
  final validHistories = histories
      .toList()
    ..sort((a, b) => b.contactDate.compareTo(a.contactDate));

  final recent = validHistories.isNotEmpty ? validHistories.first : null;
  final previous = validHistories.length > 1 ? validHistories[1] : null;

  final managePeriod = getIt<UserSession>().managePeriodDays;
  final now = DateTime.now();

  // 관리주기 초과 여부
  final isOld = recent == null
      ? true
      : now.difference(recent.contactDate).inDays >= managePeriod;

  // 최근 이력이 있는 경우에만 평가
  final noRecentFollowUp = recent != null
      ? validHistories
      .skip(1)
      .every((h) => h.contactDate.isBefore(
      recent.contactDate.add( Duration(days: UserSession().managePeriodDays))))
      : true;

  final showReminder = isOld && noRecentFollowUp;

  return HistoryCheckResult(
    recent: recent,
    previous: previous,
    showReminder: showReminder,
  );
}

