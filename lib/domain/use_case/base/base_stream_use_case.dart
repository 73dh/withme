import 'package:withme/domain/repository/repository.dart';

abstract class BaseStreamUseCase<R,T extends Repository>{
  Stream<R> call(T repository);
}