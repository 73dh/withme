import 'package:intl/intl.dart';

extension DateTimeExtension on DateTime {
  String get formattedMonth=>DateFormat('yyyy/MM').format(this);
  String get formattedDate => DateFormat('yyyy/MM/dd').format(this);
  String get formattedTime => DateFormat('HH:mm').format(this);

  String get formattedDateTime => DateFormat('dd/MM/yyyy HH:mm').format(this);
}