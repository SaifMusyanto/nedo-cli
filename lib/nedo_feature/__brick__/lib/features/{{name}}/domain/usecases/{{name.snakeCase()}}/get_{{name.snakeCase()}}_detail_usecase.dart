import 'package:fpdart/fpdart.dart';
import '../../../../../core/error/failures.dart';
import '../../../../../core/usecase/usecase.dart';
import '../../repositories/{{name.snakeCase()}}_repository.dart';

class Get{{name.pascalCase()}}DetailUseCase implements UseCase<Future<Either<Failure, {{name.pascalCase()}}Model>>, String> {
  final {{name.pascalCase()}}Repository repository;

  Get{{name.pascalCase()}}DetailUseCase(this.repository);

  @override
  Future<Either<Failure, {{name.pascalCase()}}Model>> call(String params) {
    return repository.getDetail(params);
  }
}