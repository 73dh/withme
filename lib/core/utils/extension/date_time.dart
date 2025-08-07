import 'package:intl/intl.dart';

extension DateTimeExtension on DateTime {
  String get formattedBirth=>DateFormat('yy/MM/dd').format(this);
  String get formattedYearAndMonth=>DateFormat('yy/MM').format(this);
  String get formattedMonthAndDate => DateFormat('MM/dd').format(this);
  String get formattedTime => DateFormat('HH:mm').format(this);

  String get formattedDateTime => DateFormat('dd/MM/yy HH:mm').format(this);
}

