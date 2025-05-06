import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:withme/core/fire_base/firestore_keys.dart';

class HistoryModel {
  final DateTime contactDate;
  final String content;

  const HistoryModel({required this.contactDate, required this.content});

  // factory CustomerHistory.fromJson(Map<String, dynamic> json) {
  //   return CustomerHistory(
  //     contactDate: DateTime.parse(json['contactDate']),
  //     content: json['content'] as String,
  //   );
  // }

  HistoryModel.fromMap(Map<String, dynamic> map)
    : contactDate = (map[keyContactDate] as Timestamp).toDate(),
      content = map[keyContent];

  HistoryModel.fromSnapshot(DocumentSnapshot snapshot)
    : this.fromMap(snapshot.data() as Map<String, dynamic>);

  static Map<String, dynamic> toMapForHistory({required String content}) {
    final map = <String, dynamic>{};
    map[keyContactDate] = DateTime.now();
    map[keyContent] = content;
    return map;
  }
}
