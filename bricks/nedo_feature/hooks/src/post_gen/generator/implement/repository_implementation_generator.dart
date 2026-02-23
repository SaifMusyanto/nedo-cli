import 'package:mason/mason.dart';
import '../../../../../../../shared/helper/snake_case_with_acronyms.dart';
import '../../helper/name_provider.dart';
import '../base/feature_generator.dart';

class RepositoryImplementationGenerator extends FeatureGenerator {
  @override
  String getDirectory(String featureName, List<String> acronyms) {
    return 'lib/features/${toSnakeCaseWithAcronyms(featureName, acronyms)}/data/repositories';
  }

  @override
  String getFileName(String featureName, List<dynamic> methods,
      NameProvider names, List<String> acronyms) {
    return '${toSnakeCaseWithAcronyms(featureName, acronyms)}_repository_impl';
  }

  @override
  String buildContent(String featureName, List<dynamic> methods,
      NameProvider names, List<String> acronyms) {
    final repoName = '${featureName.pascalCase}Repository';
    final repoImplName = '${repoName}Impl';
    final providerName = 'IRemote${featureName.pascalCase}Provider';
    final remoteVar = 'remote${featureName.pascalCase}Provider';

    final content = StringBuffer();
    final featureSnake = toSnakeCaseWithAcronyms(featureName, acronyms);

    content.writeln("import 'package:fpdart/fpdart.dart';");
    content.writeln("import 'package:injectable/injectable.dart';");
    content.writeln("import '../../../../core/errors/failures.dart';");
    // Updated path and name
    content.writeln("import '../../../../core/mixins/repository_mixin.dart';");
    content.writeln(
      "import '../../domain/repositories/${featureSnake}_repository.dart';",
    );
    content.writeln(
      "import '../providers/remote/interfaces/i_remote_${featureSnake}_provider.dart';",
    );
    // Base Models Import updated
    content.writeln(
        "import '../../../../core/services/network_service/models/base_list_request_model.dart';");
    content.writeln(
        "import '../../../../core/services/network_service/models/pagination_response_model.dart';");

    final usedMappers = <String>{};
    for (final m in methods) {
      final returnType = m['returnType'] as String;
      final innerType = names.getInnerType(returnType);
      if (innerType.endsWith('Entity') || innerType.endsWith('Params')) {
        content.writeln(
          "import '../../domain/entities/${toSnakeCaseWithAcronyms(innerType, acronyms)}.dart';",
        );
        String modelName;
        if (innerType.endsWith('Entity')) {
          modelName = innerType.replaceAll('Entity', 'Model');
        } else {
          modelName = innerType.replaceAll('Params', 'Model');
        }
        usedMappers
            .add('${toSnakeCaseWithAcronyms(modelName, acronyms)}_mapper');
      }
    }

    for (final mapper in usedMappers) {
      content.writeln("import '../mappers/$mapper.dart';");
    }

    final usedParams = <String>{};
    for (final m in methods) {
      final param = m['paramType'] as String;
      final innerParam = names.getInnerType(param);

      if (innerParam != 'void' &&
          !['String', 'int', 'bool', 'double'].contains(innerParam)) {
        usedParams.add(innerParam);
        if (innerParam.endsWith('Model')) {
          content.writeln(
            "import '../models/${toSnakeCaseWithAcronyms(innerParam, acronyms)}.dart';",
          );
        } else if (innerParam.endsWith('Entity') ||
            innerParam.endsWith('Params')) {
          content.writeln(
            "import '../../domain/entities/${toSnakeCaseWithAcronyms(innerParam, acronyms)}.dart';",
          );
        }
      }
    }

    content.writeln();

    content.writeln('@Injectable(as: $repoName)');
    content.writeln(
      'class $repoImplName with RepositoryMixin implements $repoName {',
    );
    content.writeln('  final $providerName $remoteVar;');
    content.writeln();
    content.writeln('  $repoImplName(this.$remoteVar);');
    content.writeln();

    for (final m in methods) {
      final methodName = m['name'] as String;
      final returnType = m['returnType'] as String;
      final innerReturn = names.getInnerType(returnType);
      final paramType = m['paramType'] as String;
      final isPaginated = m['isPaginated'] as bool? ?? false;

      String ret = returnType == 'void' ? 'void' : returnType;
      if (isPaginated && innerReturn.endsWith('Entity')) {
        ret = 'PaginationResponseModel<$innerReturn>';
      }

      String params = '';
      String callParams = '';

      if (isPaginated) {
        params = 'BaseListRequestModel params';
        callParams = 'params';
      } else if (paramType != 'void') {
        params = '$paramType params';
        callParams = 'params';
      }

      content.writeln('  @override');
      content.writeln(
        '  Future<Either<Failure, $ret>> $methodName($params) async {',
      );
      content.writeln('    return safeCall(() async {');

      if (isPaginated) {
        content.writeln(
          '      final result = await $remoteVar.$methodName($callParams);',
        );
        content.writeln('      return PaginationResponseModel(');
        content.writeln(
            '        items: result.items.map((e) => e.toEntity()).toList(),');
        content.writeln('        pagination: result.pagination,');
        content.writeln('      );');
      } else if (returnType == 'void') {
        content.writeln('      await $remoteVar.$methodName($callParams);');
      } else {
        content.writeln(
          '      final result = await $remoteVar.$methodName($callParams);',
        );
        if (returnType.startsWith('List<') && returnType.contains('Entity')) {
          content.writeln(
              '      return result.map((e) => e.toEntity()).toList();');
        } else if (returnType.endsWith('Entity')) {
          content.writeln('      return result.toEntity();');
        } else {
          content.writeln('      return result;');
        }
      }

      content.writeln('    });');
      content.writeln('  }');
      content.writeln();
    }

    content.writeln('}');
    return content.toString();
  }
}
