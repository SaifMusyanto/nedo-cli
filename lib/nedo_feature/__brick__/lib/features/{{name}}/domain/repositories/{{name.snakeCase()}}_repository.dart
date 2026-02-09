import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';

abstract class {{name.pascalCase()}}Repository {
  Future<Either<Failure, {{name.pascalCase()}}Model>> getDetail(String id);
}