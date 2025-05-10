import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/data/fire_base/firestore_keys.dart';

class HistoryModel {
  // final String userKey;
  // final String customerKey;
  final DateTime contactDate;
  final String content;
  final DocumentReference? reference;

  // const HistoryModel({required this.userKey, required this.customerKey, required this.contactDate, required this.content});

  // factory CustomerHistory.fromJson(Map<String, dynamic> json) {
  //   return CustomerHistory(
  //     contactDate: DateTime.parse(json['contactDate']),
  //     content: json['content'] as String,
  //   );
  // }

  HistoryModel.fromMap(
    Map<String, dynamic> map,
    {
    this.reference,
  }) : contactDate = (map[keyContactDate] as Timestamp).toDate(),
       content = map[keyContent];

  HistoryModel.fromSnapshot(DocumentSnapshot snapshot)
    : this.fromMap(
        snapshot.data() as Map<String, dynamic>,
      reference:   snapshot.reference,
      );

  static Map<String, dynamic> toMapForHistory({required String content}) {
    final map = <String, dynamic>{};
    map[keyContactDate] = DateTime.now();
    map[keyContent] = content;
    return map;
  }
}
