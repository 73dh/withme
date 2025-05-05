
class CustomerHistory {
  final DateTime contactDate;
  final String content;

  const CustomerHistory({required this.contactDate, required this.content});


  factory CustomerHistory.fromJson(Map<String, dynamic> json) {
    return CustomerHistory(
      contactDate: DateTime.parse(json['contactDate']),
      content: json['content'] as String,
    );
  }

  factory CustomerHistory.fromMap(Map<String, dynamic> map) {
    return CustomerHistory(
      contactDate: DateTime.parse(map['contactDate']),
      content: map['content'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'contactDate': contactDate.toIso8601String(),
      'content': content,
    };
  }
}
