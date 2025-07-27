enum SortType { name, birth, insuredDate, manage }

class SortStatus {
  final SortType type;
  final bool isAscending; // 오름차순 여부 (true: 오름차순, false: 내림차순)

  SortStatus({required this.type, this.isAscending = true});

  // 기존 상태에서 특정 필드만 변경하여 새로운 SortStatus 객체를 생성하는 헬퍼 메서드
  SortStatus copyWith({
    SortType? type,
    bool? isAscending,
  }) {
    return SortStatus(
      type: type ?? this.type,
      isAscending: isAscending ?? this.isAscending,
    );
  }

  // 객체 동등성 비교 (선택 사항이지만 유용)
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is SortStatus &&
              runtimeType == other.runtimeType &&
              type == other.type &&
              isAscending == other.isAscending;

  @override
  int get hashCode => type.hashCode ^ isAscending.hashCode;
}
// class SortStatus {
//   final SortType type;
//   final bool isAscending;
//
//   SortStatus(this.type, this.isAscending);
// }
