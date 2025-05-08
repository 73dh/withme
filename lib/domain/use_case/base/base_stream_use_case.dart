import 'package:withme/domain/repository/repository.dart';

abstract class BaseStreamUseCase<T extends Repository>{
  Stream call(T repository);
}