import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/data/fire_base/firestore_keys.dart';

class TodoModel {
  final DateTime dueDate;        // 할 일 날짜
  final String content;          // 할 일 내용
  final DocumentReference? reference; // Firestore 문서 참조 (옵션)

  TodoModel({
    required this.dueDate,
    required this.content,
    this.reference,
  });

  // JSON → TodoModel (ex. 서버나 로컬에서 Map<String, dynamic> 받았을 때)
  factory TodoModel.fromJson(Map<String, dynamic> json) {
    return TodoModel(
      dueDate: DateTime.parse(json[keyTodoDate]),
      content: json[keyTodoContent],
    );
  }

  // Firestore Map → TodoModel
  TodoModel.fromMap(Map<String, dynamic> map, {this.reference})
      : dueDate = map[keyTodoDate] is Timestamp
      ? (map[keyTodoDate] as Timestamp).toDate()
      : DateTime.now(),
        content = map[keyTodoContent] ?? '';

  // Firestore Snapshot → TodoModel
  TodoModel.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data() as Map<String, dynamic>, reference: snapshot.reference);

  // TodoModel → Map (Firestore 저장용)
  static Map<String, dynamic> toMapForCreateTodo({
    required String content,
    required DateTime dueDate,
  }) {
    return {
      keyTodoDate: dueDate,
      keyTodoContent: content,
    };
  }
}
