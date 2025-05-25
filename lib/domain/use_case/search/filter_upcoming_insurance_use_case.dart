import '../../../presentation/home/search/enum/upcoming_insurance_age.dart';
import '../../domain_import.dart';

abstract class FilterUpcomingInsuranceUseCase{
  static Future<Map<UpcomingInsuranceAge, List<CustomerModel>>> call(List<CustomerModel> customers) async {
    final now = DateTime.now();

    // 초기 맵 생성
    final Map<UpcomingInsuranceAge, List<CustomerModel>> result = {
      UpcomingInsuranceAge.today: [],
      UpcomingInsuranceAge.tomorrow: [],
      UpcomingInsuranceAge.inSevenAfter: [],
      UpcomingInsuranceAge.inMonthLater: [],
    };

    for (final customer in customers) {
      final birth = customer.birth;
      if (birth == null) continue;

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

      if (remainingDays == 0) {
        result[UpcomingInsuranceAge.today]!.add(customer);
      } else if (remainingDays == 1) {
        result[UpcomingInsuranceAge.tomorrow]!.add(customer);
      } else if (remainingDays > 1 && remainingDays <= 7) {
        result[UpcomingInsuranceAge.inSevenAfter]!.add(customer);
      } else if (remainingDays > 7 && remainingDays <= 30) {
        result[UpcomingInsuranceAge.inMonthLater]!.add(customer);
      }
    }

    return result;
  }


}