// lib/core/utils/history_utils.dart

import 'package:withme/core/data/fire_base/user_session.dart';
import 'package:withme/domain/model/history_model.dart';

import '../di/setup.dart';

bool isNeedNewHistory(List<HistoryModel> histories) {
  if (histories.isEmpty) return true;

  final recent = histories
      .map((h) => h.contactDate)
      .whereType<DateTime>()
      .fold<DateTime?>(
    null,
        (prev, curr) => prev == null || curr.isAfter(prev) ? curr : prev,
  );

  if (recent == null) return true;

  final managePeriod = getIt<UserSession>().managePeriodDays;
  final now = DateTime.now();

  return now.difference(recent).inDays >= managePeriod;
}
