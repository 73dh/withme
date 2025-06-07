import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/data/fire_base/firestore_keys.dart';

class HistoryModel {
  final DateTime contactDate;
  final String content;
  final DocumentReference? reference;

  HistoryModel({
    required this.contactDate,
    required this.content,
    this.reference,
  });

  factory HistoryModel.fromJson(Map<String, dynamic> json) {
    return HistoryModel(
      contactDate: DateTime.parse(json[keyContactDate]),
      content: json[keyContent],
    );
  }

  HistoryModel.fromMap(Map<String, dynamic> map, {this.reference})
    : contactDate =  map[keyContactDate] is Timestamp
      ? (map[keyContactDate] as Timestamp).toDate()
      : DateTime.now(),
      content = map[keyContent]??'';

  HistoryModel.fromSnapshot(DocumentSnapshot snapshot)
    : this.fromMap(
        snapshot.data() as Map<String, dynamic>,
        reference: snapshot.reference,
      );

  static Map<String, dynamic> toMapForHistory({
    required String content,
    DateTime? registeredDate,
  }) {
    final map = <String, dynamic>{};
    map[keyContactDate] = registeredDate;
    map[keyContent] = content;
    return map;
  }
}
