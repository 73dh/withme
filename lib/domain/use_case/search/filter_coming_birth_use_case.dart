import 'package:flutter/material.dart';

import '../../../presentation/home/search/enum/coming_birth.dart';
import '../../domain_import.dart';

 class FilterComingBirthUseCase{

   static Future<Map<ComingBirth, List<CustomerModel>>> call( List<CustomerModel> customers) async {
     final now = DateTime.now();
     final today = DateTime(now.year, now.month, now.day);

     final Map<ComingBirth, List<CustomerModel>> result = {
       ComingBirth.today: [],
       ComingBirth.tomorrow: [],
       ComingBirth.inSevenAfter: [],
       ComingBirth.inSevenLater: [],
     };

     final filtered=[];

     for (final customer in customers) {
       final birth = customer.birth;
       if (birth == null) continue;

       DateTime birthday = DateTime(today.year, birth.month, birth.day);

       // 윤년 예외 처리 (선택적)
       if (birth.month == 2 && birth.day == 29 && !DateTime(today.year).isLeapYear()) {
         birthday = DateTime(today.year, 2, 28);
       }

       final diff = birthday.difference(today).inDays;

       if (diff == 0) {
         result[ComingBirth.today]!.add(customer);
       } else if (diff == 1) {
         result[ComingBirth.tomorrow]!.add(customer);
       } else if (diff > 1 && diff <= 7) {
         result[ComingBirth.inSevenAfter]!.add(customer);
       } else if (diff < 0 && diff >= -7) {
         result[ComingBirth.inSevenLater]!.add(customer);
       }
     }

     return result;
   }
 }

extension DateTimeX on DateTime {
  bool isLeapYear() {
    final year = this.year;
    return (year % 4 == 0 && year % 100 != 0) || year % 400 == 0;
  }

}