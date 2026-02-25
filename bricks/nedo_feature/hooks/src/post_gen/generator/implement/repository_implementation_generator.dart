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
        "import '../../../../core/services/network_service/models/request/base_pagination_request.dart';");
    content.writeln(
        "import '../../../../core/services/network_service/models/response/base_pagination_response.dart';");

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
          modelName = '${innerType.substring(0, innerType.length - 6)}Model';
        } else {
          modelName =
              '${innerType.substring(0, innerType.length - 6)}Model'; // For Params which is also 6 chars
        }
        usedMappers
            .add('${toSnakeCaseWithAcronyms(modelName, acronyms)}_mapper');
      }

      final isPaginated = m['isPaginated'] as bool? ?? false;

      if (!isPaginated) {
        final paramType = m['paramType'] as String;
        final innerParam = names.getInnerType(paramType);

        String mappedInnerParam = innerParam;
        if (innerParam.endsWith('BaseRequest')) {
          mappedInnerParam =
              '${innerParam.substring(0, innerParam.length - 11)}Params';
        } else if (innerParam.endsWith('Request')) {
          mappedInnerParam =
              '${innerParam.substring(0, innerParam.length - 7)}Params';
        } else if (innerParam.endsWith('Model')) {
          mappedInnerParam =
              '${innerParam.substring(0, innerParam.length - 5)}Params';
        }

        if (mappedInnerParam != 'void' &&
            !['String', 'int', 'bool', 'double'].contains(mappedInnerParam)) {
          if (mappedInnerParam.endsWith('Params') ||
              mappedInnerParam.endsWith('Entity')) {
            String modelName;
            if (mappedInnerParam.endsWith('Entity')) {
              modelName =
                  '${mappedInnerParam.substring(0, mappedInnerParam.length - 6)}Model';
            } else {
              modelName =
                  '${mappedInnerParam.substring(0, mappedInnerParam.length - 6)}Model';
            }
            usedMappers
                .add('${toSnakeCaseWithAcronyms(modelName, acronyms)}_mapper');
          }
        }
      }
    }

    for (final mapper in usedMappers) {
      content.writeln("import '../mappers/$mapper.dart';");
    }

    final usedParams = <String>{};
    for (final m in methods) {
      final isPaginated = m['isPaginated'] as bool? ?? false;

      if (!isPaginated) {
        final param = m['paramType'] as String;
        final innerParam = names.getInnerType(param);

        String mappedInnerParam = innerParam;
        if (innerParam.endsWith('BaseRequest')) {
          mappedInnerParam =
              '${innerParam.substring(0, innerParam.length - 11)}Params';
        } else if (innerParam.endsWith('Request')) {
          mappedInnerParam =
              '${innerParam.substring(0, innerParam.length - 7)}Params';
        } else if (innerParam.endsWith('Model')) {
          mappedInnerParam =
              '${innerParam.substring(0, innerParam.length - 5)}Params';
        }

        if (mappedInnerParam != 'void' &&
            !['String', 'int', 'bool', 'double'].contains(mappedInnerParam)) {
          if (!usedParams.contains(mappedInnerParam)) {
            usedParams.add(mappedInnerParam);
            if (mappedInnerParam.endsWith('Model')) {
              content.writeln(
                "import '../models/${toSnakeCaseWithAcronyms(mappedInnerParam, acronyms)}.dart';",
              );
            } else if (mappedInnerParam.endsWith('Entity') ||
                mappedInnerParam.endsWith('Params')) {
              content.writeln(
                "import '../../domain/entities/${toSnakeCaseWithAcronyms(mappedInnerParam, acronyms)}.dart';",
              );
            }
          }
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
      final innerParam = names.getInnerType(paramType);
      final isPaginated = m['isPaginated'] as bool? ?? false;

      String mappedInnerParam = innerParam;
      if (innerParam.endsWith('BaseRequest')) {
        mappedInnerParam =
            '${innerParam.substring(0, innerParam.length - 11)}Params';
      } else if (innerParam.endsWith('Request')) {
        mappedInnerParam =
            '${innerParam.substring(0, innerParam.length - 7)}Params';
      } else if (innerParam.endsWith('Model')) {
        mappedInnerParam =
            '${innerParam.substring(0, innerParam.length - 5)}Params';
      }

      String mappedParamType =
          paramType.replaceFirst(innerParam, mappedInnerParam);

      String ret = returnType == 'void' ? 'void' : returnType;
      if (isPaginated && innerReturn.endsWith('Entity')) {
        ret = 'BasePaginationResponse<$innerReturn>';
      }

      final pathParams =
          (m['pathParams'] as List?)?.cast<Map<String, dynamic>>() ?? [];

      String params = '';
      String callParams = '';
      List<String> paramParts = [];
      List<String> callParts = [];
      for (var p in pathParams) {
        final pName = p['name'];
        final pType = p['type'];
        paramParts.add('$pType $pName');
        callParts.add(pName);
      }

      if (isPaginated) {
        paramParts.add('BasePaginationRequest params');
        callParts.add('params');
      } else if (mappedParamType != 'void') {
        paramParts.add('$mappedParamType params');
        if (mappedParamType.endsWith('Entity') ||
            mappedParamType.endsWith('Params')) {
          callParts.add('params.toModel()');
        } else {
          callParts.add('params');
        }
      }

      params = paramParts.join(', ');
      callParams = callParts.join(', ');

      content.writeln('  @override');
      content.writeln(
        '  Future<Either<Failure, $ret>> $methodName($params) async {',
      );
      content.writeln('    return safeCall(() async {');

      if (isPaginated) {
        content.writeln(
          '      final result = await $remoteVar.$methodName($callParams);',
        );
        content.writeln('      return BasePaginationResponse(');
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
