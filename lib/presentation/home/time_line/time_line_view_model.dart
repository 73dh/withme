import 'dart:async';
import 'package:flutter/material.dart';
import 'package:rxdart/subjects.dart';
import 'package:withme/core/data/fire_base/user_session.dart';
import 'package:withme/domain/use_case/customer/get_edited_all_use_case.dart';
import 'package:withme/domain/use_case/customer/get_all_data_use_case.dart';
import 'package:withme/domain/domain_import.dart';
import '../../../core/di/setup.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:rxdart/subjects.dart';
import 'package:withme/core/data/fire_base/user_session.dart';
import 'package:withme/core/di/setup.dart';
import 'package:withme/domain/domain_import.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:rxdart/subjects.dart';
import 'package:withme/core/data/fire_base/user_session.dart';
import 'package:withme/domain/use_case/customer/get_edited_all_use_case.dart';
import '../../../core/di/setup.dart';
import '../../../domain/domain_import.dart';
import '../../../domain/model/todo_model.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/subjects.dart';
import 'package:withme/core/data/fire_base/user_session.dart';
import 'package:withme/core/di/setup.dart';
import 'package:withme/domain/domain_import.dart';
import 'package:withme/domain/model/todo_model.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/subjects.dart';
import 'package:withme/core/data/fire_base/user_session.dart';
import 'package:withme/core/di/setup.dart';
import 'package:withme/domain/domain_import.dart';
import 'package:withme/domain/model/todo_model.dart';
import 'package:withme/domain/use_case/customer/get_all_data_use_case.dart';
import 'package:withme/domain/use_case/customer/get_edited_all_use_case.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/subjects.dart';
import 'package:withme/core/data/fire_base/user_session.dart';
import 'package:withme/core/di/setup.dart';
import 'package:withme/domain/domain_import.dart';
import 'package:withme/domain/model/todo_model.dart';
import 'package:withme/domain/use_case/customer/get_all_data_use_case.dart';
import 'package:withme/domain/use_case/customer/get_edited_all_use_case.dart';

/// 고객 + Todo 묶음
class TodoWithCustomer {
  final CustomerModel customer; // 고객 전체 모델
  final TodoModel todo;

  TodoWithCustomer(this.customer, this.todo);

  String get customerName => customer.name; // 이름 접근 편의
}

class TimeLineViewModel with ChangeNotifier {
  final BehaviorSubject<List<CustomerModel>> _cachedCustomers =
  BehaviorSubject.seeded([]);

  Stream<List<CustomerModel>> get customersStream => _cachedCustomers.stream;

  List<CustomerModel> allCustomers = [];

  /// 로딩 상태
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// 전체 todos (flatten)
  List<TodoWithCustomer> get allTodos {
    return allCustomers
        .expand((c) => c.todos.map((t) => TodoWithCustomer(c, t)))
        .toList()
      ..sort((a, b) => a.todo.dueDate.compareTo(b.todo.dueDate));
  }

  /// 전체 todo 개수
  int get totalTodos =>
      allCustomers.fold<int>(0, (sum, c) => sum + c.todos.length);

  /// 데이터 로드
  Future<void> fetchData({bool force = false}) async {
    // ✅ 캐시가 있고 force 요청이 없으면 캐시만 사용
    if (!force && allCustomers.isNotEmpty) {
      _cachedCustomers.add(List.from(allCustomers));
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final usecase = force
          ? GetEditedAllUseCase(userKey: UserSession.userId)
          : GetAllDataUseCase(userKey: UserSession.userId);

      final result =
      await getIt<CustomerUseCase>().execute(usecase: usecase);

      allCustomers = result;
      _cachedCustomers.add(List.from(allCustomers));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearCache() {
    _cachedCustomers.add([]);
    allCustomers = [];
    notifyListeners();
  }

  @override
  void dispose() {
    _cachedCustomers.close();
    super.dispose();
  }
}
