import 'package:withme/domain/repository/todo_repository.dart';

import '../../model/todo_model.dart';
import '../base/base_stream_use_case.dart';

class GetTodosUseCase
    extends BaseStreamUseCase<List<TodoModel>, TodoRepository> {
  final String userKey;
  final String customerKey;

  GetTodosUseCase({required this.userKey, required this.customerKey});

  @override
  Stream<List<TodoModel>> call(TodoRepository repository) {
    return repository.getTodos(userKey: userKey, customerKey: customerKey);
  }
}