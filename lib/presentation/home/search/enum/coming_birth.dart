enum ComingBirth{
  today,tomorrow,inSevenAfter,inSevenLater;

  @override
  String toString()=>switch(this){

    ComingBirth.today => '오늘 생일',
    ComingBirth.tomorrow => '내일 생일',
    ComingBirth.inSevenAfter => '도래 (7일 이내)',
    ComingBirth.inSevenLater => '경과 (7일 이내)',
  };


}