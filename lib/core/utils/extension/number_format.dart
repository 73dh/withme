import 'package:intl/intl.dart';

final numFormatter = NumberFormat.currency(
  locale: 'ko_KR',
  symbol: '₩',
  decimalDigits: 0,
);
