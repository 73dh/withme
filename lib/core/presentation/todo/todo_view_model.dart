import 'dart:async';

import 'package:flutter/material.dart';

import '../../di/di_setup_import.dart';
import '../../../domain/model/todo_model.dart';

// todo_view_model.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../../../domain/model/todo_model.dart';
import '../../di/di_setup_import.dart';

class TodoViewModel with ChangeNotifier {
  final _fbase = FBase();

  final List<TodoModel> _todoList = [];
  List<TodoModel> get todoList => _todoList;

  Stream<List<TodoModel>>? _todoStream;
  Stream<List<TodoModel>> get todoStream => _todoStream!;

  StreamSubscription<List<TodoModel>>? _subscription;

  /// 초기화: 고객별 Todo 실시간 구독
  Future<void> initializeTodos({
    required String userKey,
    required String customerKey,
  }) async {
    _todoStream = _fbase
        .getTodos(userKey: userKey, customerKey: customerKey)
        .map((snapshot) =>
        snapshot.docs.map((doc) => TodoModel.fromSnapshot(doc)).toList());

    // 이전 구독 취소
    await _subscription?.cancel();

    // 새로운 구독
    _subscription = _todoStream!.listen((todos) {
      _todoList
        ..clear()
        ..addAll(todos);
      notifyListeners();
    });
  }

  void disposeStream() {
    _subscription?.cancel();
  }
}
//
// class TodoViewModel with ChangeNotifier {
//   final _fbase = FBase();
//
//   Stream<List<TodoModel>>? _todoStream;
//
//   Stream<List<TodoModel>>? get todoStream => _todoStream;
//
//   final List<TodoModel> _todoList = [];
//
//   List<TodoModel> get todoList => _todoList;
//
//   final bool _isLoading = false;
//
//   bool get isLoading => _isLoading;
//
//   StreamSubscription<List<TodoModel>>? _subscription;
//
//   /// 초기화 및 실시간 데이터 수신 시작
//   Future<void> initializeTodos({
//     required String userKey,
//     required String customerKey,
//   }) async {
//     _todoStream = _fbase
//         .getTodos(userKey: userKey, customerKey: customerKey)
//         .map((snapshot) {
//           return snapshot.docs
//               .map((doc) => TodoModel.fromSnapshot(doc))
//               .toList();
//         });
//
//     _subscription?.cancel();
//
//     _subscription = _todoStream!.listen((todos) {
//       _todoList
//         ..clear()
//         ..addAll(todos);
//       notifyListeners();
//     });
//   }
// }
