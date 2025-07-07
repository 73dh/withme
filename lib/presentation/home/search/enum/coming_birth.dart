enum ComingBirth {
  noBirthInfo,
  today,
  tomorrow,
  inSevenAfter,
  inSevenLater;

  @override
  String toString() => switch (this) {
    ComingBirth.noBirthInfo => '생일정보 없음',
    ComingBirth.today => '오늘 생일',
    ComingBirth.tomorrow => '내일 생일',
    ComingBirth.inSevenAfter => '7일 이내 도래',
    ComingBirth.inSevenLater => '경과 7일 이내',
  };
}
