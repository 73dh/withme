enum SelectedMenuNoContact {
  oneMonth,
  threeMonth,
  sixMonth,
  nineMonth;

  @override
  String toString() => switch (this) {
    SelectedMenuNoContact.oneMonth => '1개월',
    SelectedMenuNoContact.threeMonth => '3개월',
    SelectedMenuNoContact.sixMonth => '6개월',
    SelectedMenuNoContact.nineMonth => '9개월',
  };

  int get toInt => switch (this) {
    SelectedMenuNoContact.oneMonth => 1,
    SelectedMenuNoContact.threeMonth => 3,
    SelectedMenuNoContact.sixMonth => 6,
    SelectedMenuNoContact.nineMonth => 9,
  };
}
