import '../../../core/domain/enum/sort_type.dart';
import '../../../core/utils/core_utils_import.dart';
import '../../domain_import.dart';

class ApplyCurrentSortUseCase {
  final SortType currentSortType;
  final bool isAscending;

  ApplyCurrentSortUseCase({
    required this.isAscending,
    required this.currentSortType,
  });

  List<CustomerModel> call(List<CustomerModel> list) {
    final sortedList = List<CustomerModel>.from(list);

    switch (currentSortType) {
      case SortType.name:
        // 1차: 이름순 / 2차: 생일순
        sortedList.sort((a, b) {
          final nameCompare =
              isAscending ? a.name.compareTo(b.name) : b.name.compareTo(a.name);
          if (nameCompare != 0) return nameCompare;

          final aBirth = a.birth ?? DateTime(1900);
          final bBirth = b.birth ?? DateTime(1900);
          return aBirth.compareTo(bBirth); // 항상 오름차순
        });
        break;

      case SortType.birth:
        // 1차: 생일순 / 2차: 이름순
        sortedList.sort((a, b) {
          final aBirth = a.birth ?? DateTime(1900);
          final bBirth = b.birth ?? DateTime(1900);

          final birthCompare =
              isAscending ? aBirth.compareTo(bBirth) : bBirth.compareTo(aBirth);
          if (birthCompare != 0) return birthCompare;

          return a.name.compareTo(b.name); // 항상 오름차순
        });
        break;

      case SortType.insuredDate:
        // 1차: 상령일순 / 2차: 이름순
        sortedList.sort((a, b) {
          final aDate =
              a.birth != null
                  ? getInsuranceAgeChangeDate(a.birth!)
                  : DateTime(1900);
          final bDate =
              b.birth != null
                  ? getInsuranceAgeChangeDate(b.birth!)
                  : DateTime(1900);

          final insuredCompare =
              isAscending ? aDate.compareTo(bDate) : bDate.compareTo(aDate);
          if (insuredCompare != 0) return insuredCompare;

          return a.name.compareTo(b.name); // 항상 오름차순
        });
        break;

      case SortType.manage:
        // 1차: 관리수 / 2차: 이름순
        sortedList.sort((a, b) {
          final countCompare =
              isAscending
                  ? a.histories.length.compareTo(b.histories.length)
                  : b.histories.length.compareTo(a.histories.length);
          if (countCompare != 0) return countCompare;

          return a.name.compareTo(b.name); // 항상 오름차순
        });
        break;
    }

    return sortedList;
  }
}
