enum SortType { name, birth, insuredDate, manage }

class SortStatus {
  final SortType type;
  final bool isAscending;

  SortStatus(this.type, this.isAscending);
}
