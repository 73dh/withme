import '../../domain/model/policy_model.dart';

double calculateTotalPremium(List<PolicyModel> policies) {
  double total = 0;

  for (var policy in policies) {
    try {
      // 문자열에 콤마나 화폐 기호가 포함된 경우 제거
      String cleaned = policy.premium.replaceAll(RegExp(r'[^\d.]'), '');
      if (cleaned.isEmpty) continue;

      double value = double.parse(cleaned);
      total += value;
    } catch (e) {
      // premium이 숫자로 변환되지 않을 경우 무시
      continue;
    }
  }

  return total;
}
