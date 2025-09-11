import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/data/fire_base/firestore_keys.dart';

class TodoModel {
  final DateTime dueDate;
  final String content;
  final DocumentReference? reference;

  TodoModel({required this.dueDate, required this.content, this.reference});

  // JSON → TodoModel
  factory TodoModel.fromJson(Map<String, dynamic> json) {
    return TodoModel(
      dueDate: DateTime.parse(json[keyTodoDate]),
      content: json[keyTodoContent],
    );
  }

  // Firestore Map + reference → TodoModel
  factory TodoModel.fromMap(
    Map<String, dynamic> map, {
    DocumentReference? reference,
  }) {
    return TodoModel(
      dueDate:
          map[keyTodoDate] is Timestamp
              ? (map[keyTodoDate] as Timestamp).toDate()
              : DateTime.now(),
      content: map[keyTodoContent] ?? '',
      reference: reference,
    );
  }

  // Firestore Snapshot → TodoModel
  factory TodoModel.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return TodoModel.fromMap(data, reference: snapshot.reference);
  }

  // Firestore 저장용 Map 생성
  static Map<String, dynamic> toMapForCreateTodo({
    required String content,
    required DateTime dueDate,
  }) {
    return {keyTodoDate: dueDate, keyTodoContent: content};
  }

  TodoModel copyWith({
    DateTime? dueDate,
    String? content,
    DocumentReference? reference,
  }) {
    return TodoModel(
      dueDate: dueDate ?? this.dueDate,
      content: content ?? this.content,
      reference: reference ?? this.reference,
    );
  }

  // 문서 ID 추출
  String get docId => reference?.id ?? '';

  bool get isOverdue => dueDate.isBefore(DateTime.now());
}
