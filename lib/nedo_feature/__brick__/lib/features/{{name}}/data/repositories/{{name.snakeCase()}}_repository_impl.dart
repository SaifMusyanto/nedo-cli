import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/repository_helper.dart';
import '../../domain/repositories/{{name.snakeCase()}}_repository.dart';
import '../providers/remote/interfaces/i_remote_{{name.snakeCase()}}_provider.dart';

class {{name.pascalCase()}}RepositoryImpl with RepositoryHelper implements {{name.pascalCase()}}Repository {
  final IRemote{{name.pascalCase()}}Provider remote{{name.pascalCase()}}Provider;

  {{name.pascalCase()}}RepositoryImpl(this.remote{{name.pascalCase()}}Provider);

  @override
  Future<Either<Failure, {{name.pascalCase()}}Model>> getDetail(String id) async {
    return safeCall(() async {
      final result = await remote{{name.pascalCase()}}Provider.getDetail(id);
      return result;
    });
  }
}