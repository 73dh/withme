import '../../domain/enum/sort_status.dart';

abstract class FabViewModelInterface {
  /// FAB 표시 여부
  bool get isFabVisible;

  /// FAB 표시
  void showFab();

  /// FAB 숨김
  void hideFab();

  /// 데이터 갱신
  void fetchData({bool force = false});

  /// 정렬 메서드
  void sortByName();

  void sortByBirth();

  void sortByInsuranceAgeDate();

  void sortByHistoryCount();

  /// 현재 정렬 상태
  SortStatus get sortStatus;
}
