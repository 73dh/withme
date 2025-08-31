import '../../domain/model/policy_model.dart';
import '../domain/enum/policy_state.dart';
import 'extension/number_format.dart';

// double calculateTotalPremium(List<PolicyModel> policies) {
//   double total = 0;
//
//   for (var policy in policies) {
//     try {
//       // 문자열에 콤마나 화폐 기호가 포함된 경우 제거
//       String cleaned = policy.premium.replaceAll(RegExp(r'[^\d.]'), '');
//       if (cleaned.isEmpty) continue;
//
//       double value = double.parse(cleaned);
//       total += value;
//     } catch (e) {
//       // premium이 숫자로 변환되지 않을 경우 무시
//       continue;
//     }
//   }
//
//   return total;
// }

// String calculateTotalPremium(List<PolicyModel> policies) {
//   final total = policies.fold<int>(0, (sum, policy) {
//     final premium = int.tryParse(
//       policy.premium.replaceAll(RegExp(r'[^0-9]'), ''),
//     ) ??
//         0;
//     return sum + premium;
//   });
//   // 세 자리수 콤마 포맷 적용
//   return numFormatter.format(total);
// }

// String calculateTotalPremium(List<PolicyModel> policies) {
//   final now = DateTime.now();
//   final thisMonthEnd = DateTime(now.year, now.month + 1, 0); // 이번 달 말일
//
//   final total = policies.fold<int>(0, (sum, policy) {
//     final premium = int.tryParse(
//       policy.premium.replaceAll(RegExp(r'[^0-9]'), ''),
//     ) ?? 0;
//
//     // 계약 시작일
//     final start = policy.startDate;
//     // 납입기간 (개월 단위라고 가정)
//     final periodMonths = policy.paymentPeriod ?? 0;
//
//     if (start != null && periodMonths > 0) {
//       final endDate = DateTime(start.year, start.month + periodMonths, start.day);
//
//       // 👉 이번 달 말일까지 유효한 계약만 더하기
//       if (endDate.isAfter(thisMonthEnd)) {
//         return sum + premium;
//       }
//     }
//
//     return sum;
//   });
//
//   return numFormatter.format(total);
// }

String calculateTotalPremium(List<PolicyModel> policies) {
  final now = DateTime.now();
  final monthStart = DateTime(now.year, now.month, 1); // 이번 달 시작
  final monthEnd = DateTime(now.year, now.month + 1, 0); // 이번 달 마지막 날

  int total = 0;

  for (final policy in policies) {
    // 상태 필터
    if (policy.policyState != PolicyStatus.keep.label) continue;
    final premium = int.tryParse(
      policy.premium.replaceAll(RegExp(r'[^0-9]'), ''),
    ) ?? 0;

    final start = policy.startDate;
    final periodMonths = policy.paymentPeriod ?? 0;

    if (start == null || periodMonths <= 0) continue;

    // 계약 마지막 날 계산
    final end = DateTime(start.year, start.month + periodMonths, start.day);

    // 이번 달 납입금이 포함되는지 확인
    if (!(end.isBefore(monthStart) || start.isAfter(monthEnd))) {
      total += premium;
    }
  }

  print(total);
  return numFormatter.format(total);
}

