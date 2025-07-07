enum NoContactMonth {
  oneMonth,
  threeMonth,
  sixMonth,
  nineMonth;

  @override
  String toString() => switch (this) {
    NoContactMonth.oneMonth => '1개월 미관리',
    NoContactMonth.threeMonth => '3개월 미관리',
    NoContactMonth.sixMonth => '6개월 미관리',
    NoContactMonth.nineMonth => '9개월 미관리',
  };

  int get toInt => switch (this) {
    NoContactMonth.oneMonth => 1,
    NoContactMonth.threeMonth => 3,
    NoContactMonth.sixMonth => 6,
    NoContactMonth.nineMonth => 9,
  };
}
