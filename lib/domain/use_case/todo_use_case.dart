import 'package:withme/domain/repository/todo_repository.dart';

import 'base/base_stream_use_case.dart';
import 'base/base_use_case.dart';

class TodoUseCase {
  final TodoRepository _todoRepository;

  TodoUseCase({required TodoRepository todoRepository})
      : _todoRepository = todoRepository;

  Future execute<T>({required BaseUseCase usecase}) async {
    return usecase(_todoRepository);
  }

  Stream<R> call<R>({required BaseStreamUseCase<R,TodoRepository> usecase}) {
    return usecase(_todoRepository);
  }
}