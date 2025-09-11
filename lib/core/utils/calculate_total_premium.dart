import '../../domain/model/policy_model.dart';
import '../domain/enum/policy_state.dart';
import 'extension/number_format.dart';

String calculateTotalPremium(List<PolicyModel> policies) {
  int total = 0;

  for (final policy in policies) {
    // 정상 계약만
    if (policy.policyState != PolicyStatus.keep.label) continue;

    final premium =
        int.tryParse(policy.premium.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

    if (policy.paymentMethod == "일시납") {
      // ✅ 모든 일시납 계약 금액 합산
      total += premium;
    } else {
      // ✅ 월납 등 반복납입 → 이번 달에 해당하는지만 체크
      final start = policy.startDate;
      final periodMonths = policy.paymentPeriod;
      if (start == null || periodMonths <= 0) continue;

      final now = DateTime.now();
      final monthStart = DateTime(now.year, now.month, 1);
      final monthEnd = DateTime(now.year, now.month + 1, 0);
      final end = DateTime(start.year, start.month + periodMonths, start.day);

      if (!(end.isBefore(monthStart) || start.isAfter(monthEnd))) {
        total += premium;
      }
    }
  }

  return numFormatter.format(total);
}
