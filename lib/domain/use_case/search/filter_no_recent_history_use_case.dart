import '../../../core/di/setup.dart';
import '../../domain_import.dart';
import '../../model/history_model.dart';
import '../history/get_histories_use_case.dart';
import '../history_use_case.dart';

abstract class FilterNoRecentHistoryUseCase{
  static Future<List<CustomerModel>> call(List<CustomerModel> customers)async{
    final now = DateTime.now();
    final threeMonthsAgo = now.subtract(Duration(days: 90));

    List<CustomerModel> filtered = [];

    for (final customer in customers) {
      final histories = await getIt<HistoryUseCase>()
          .call(usecase: GetHistoriesUseCase(customerKey: customer.customerKey))
          .first as List<HistoryModel>;

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

      // 최근 이력이 3개월보다 이전이면 포함
      if (latestDate.isBefore(threeMonthsAgo)) {
        filtered.add(customer);
      }
    }
    return filtered;
  }
}