import '../../domain/model/policy_model.dart';

/// 남은 납입기간 계산 및 문자열 반환
String calculateRemainingPaymentMonth(PolicyModel policy) {
  if (policy.startDate == null) return '잔여납기: 0년 0개월';

  final now = DateTime.now();
  final endDate = DateTime(
    policy.startDate!.year + policy.paymentPeriod,
    policy.startDate!.month,
    policy.startDate!.day,
  );

  int remainingMonths = (endDate.year - now.year) * 12 + (endDate.month - now.month);
  if (remainingMonths < 0) remainingMonths = 0;

  final years = remainingMonths ~/ 12;
  final months = remainingMonths % 12;

  return ' 잔여: $years년 $months개월';
}

/// 남은 개월 수 계산
int monthsUntilEnd(PolicyModel policy) {
  if (policy.startDate == null) return 0;

  final now = DateTime.now();
  final endDate = DateTime(
    policy.startDate!.year + policy.paymentPeriod,
    policy.startDate!.month,
    policy.startDate!.day,
  );

  int remainingMonths = (endDate.year - now.year) * 12 + (endDate.month - now.month);
  if (remainingMonths < 0) remainingMonths = 0;

  return remainingMonths;
}
