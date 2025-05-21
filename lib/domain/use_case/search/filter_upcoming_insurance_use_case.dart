import '../../domain_import.dart';

abstract class FilterUpcomingInsuranceUseCase{
  static Future<List<CustomerModel>> call(List<CustomerModel> customers)async{
    final now = DateTime.now();

  return customers.where((customer) {
      final birth = customer.birth;
      if (birth == null) return false;

      // 보험 상령일 = 생일 + 6개월
      final insuranceAgeIncreaseDate = DateTime(
        birth.year,
        birth.month + 6,
        birth.day,
      );

      // 올해 또는 내년의 보험 상령일 구하기
      DateTime thisYearIncrease = DateTime(
        now.year,
        insuranceAgeIncreaseDate.month,
        insuranceAgeIncreaseDate.day,
      );

      if (thisYearIncrease.isBefore(now)) {
        thisYearIncrease = DateTime(
          now.year + 1,
          insuranceAgeIncreaseDate.month,
          insuranceAgeIncreaseDate.day,
        );
      }

      final remainingDays = thisYearIncrease.difference(now).inDays;

      // 잔여일이 10일 이상 30일 이내인지 확인
      return remainingDays >= 10 && remainingDays <= 30;
    }).toList();

  }
}