enum UpcomingInsuranceAge{
  today,tomorrow,inSevenAfter,inMonthLater;
  @override
  String toString()=>switch(this){

    UpcomingInsuranceAge.today => '오늘 상령일',
    UpcomingInsuranceAge.tomorrow => '내일 상령일',
    UpcomingInsuranceAge.inSevenAfter => '7일 이내 상령일',
    UpcomingInsuranceAge.inMonthLater => '1개월 이내 상령일',
  };
}