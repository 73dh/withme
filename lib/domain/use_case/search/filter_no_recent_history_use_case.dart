import '../../../presentation/home/search/enum/no_contact_month.dart';
import '../../domain_import.dart';

abstract class FilterNoRecentHistoryUseCase {
  static Future<List<CustomerModel>> call({
    required List<CustomerModel> customers,
    required NoContactMonth month,
  }) async {
    final now = DateTime.now();
    final threeMonthsAgo = now.subtract(Duration(days: month.toInt * 30));

    List<CustomerModel> filtered = [];

    for (final customer in customers) {
      final histories = customer.histories;

      if (histories.isEmpty) {
        // 이력이 전혀 없으면 포함
        filtered.add(customer);
        continue;
      }

      // 가장 최근 dateTime 찾기
      final latestDate = histories
          .map((h) => h.contactDate)
          .whereType<DateTime>()
          .reduce((a, b) => a.isAfter(b) ? a : b);

      // 최근 이력이 기준개월 보다 이전이면 포함
      if (latestDate.isBefore(threeMonthsAgo)) {
        filtered.add(customer);
      }
    }
    return filtered;
  }
}
