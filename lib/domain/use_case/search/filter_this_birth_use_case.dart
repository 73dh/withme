import '../../domain_import.dart';

 class FilterThisBirthUseCase{

 static Future<List<CustomerModel>> call(List<CustomerModel> customers)async{
   final now = DateTime.now();
   // final in30Days = now.add(Duration(days: 30));

   return customers.where((customer) {
     final birth = customer.birth;
     if (birth == null) return false;

     // 올해 생일 날짜 생성
     DateTime thisYearsBirthday = DateTime(now.year, birth.month, birth.day);

     // 생일이 이미 지난 경우, 내년 생일로 변경
     if (thisYearsBirthday.isBefore(now)) {
       thisYearsBirthday = DateTime(now.year + 1, birth.month, birth.day);
     }

     // 생일이 현재부터 30일 이내인지 확인
     final difference = thisYearsBirthday.difference(now).inDays;
     return difference >= 0 && difference <= 30;
   }).toList();
  }

}