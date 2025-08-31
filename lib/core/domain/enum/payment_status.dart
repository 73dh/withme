enum PaymentStatus {
  all,   // 전체
  paying, // 납입중
  soonPaid, //완료임박
  paid,   // 납입완료
}

extension PaymentStatusExtension on PaymentStatus {
  String get label {
    switch (this) {
      case PaymentStatus.paying:
        return "납입중";
      case PaymentStatus.paid:
        return "납입완료";
      case PaymentStatus.soonPaid:
        return "완료임박";
      default:
        return "납입전체";
    }
  }
}