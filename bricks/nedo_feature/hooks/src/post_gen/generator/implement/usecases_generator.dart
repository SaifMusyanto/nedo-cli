import 'dart:io';
import 'package:mason/mason.dart';
import '../../../../../../../shared/helper/snake_case_with_acronyms.dart';
import '../../helper/name_provider.dart';
import '../base/feature_generator.dart';

class UsecasesGenerator extends FeatureGenerator {
  @override
  String getDirectory(String featureName, List<String> acronyms) {
    return 'lib/features/${toSnakeCaseWithAcronyms(featureName, acronyms)}/domain/usecases';
  }

  @override
  String getFileName(String featureName, List<dynamic> methods,
      NameProvider names, List<String> acronyms) {
    return ''; // Overridden by custom generate implementation
  }

  @override
  String buildContent(String featureName, List<dynamic> methods,
      NameProvider names, List<String> acronyms) {
    return ''; // Overridden by custom generate implementation
  }

  @override
  Future<void> generate({
    required String featureName,
    required List<dynamic> methods,
    required NameProvider names,
    required List<String> acronyms,
  }) async {
    final directory = getDirectory(featureName, acronyms);

    for (final m in methods) {
      final methodName = m['name'] as String;
      String returnType = m['returnType'] as String;
      if (returnType == 'GuidObjectBaseResponse' || returnType == 'Guid') {
        returnType = 'String';
      } else if (returnType == 'List<GuidObjectBaseResponse>' ||
          returnType == 'List<Guid>') {
        returnType = 'List<String>';
      }
      final innerReturn = names.getInnerType(returnType);
      final paramType = m['paramType'] as String;
      final isPaginated = m['isPaginated'] as bool? ?? false;

      final useCaseName = '${methodName.pascalCase}UseCase';
      final fileName =
          '${toSnakeCaseWithAcronyms(methodName, acronyms)}_usecase';

      final content = StringBuffer();

      content.writeln("import 'package:fpdart/fpdart.dart';");
      content.writeln("import 'package:injectable/injectable.dart';");
      content.writeln("import '../../../../core/errors/failures.dart';");
      content.writeln(
        "import '../../../../core/usecases/usecase.dart';",
      );
      content.writeln(
        "import '../repositories/${toSnakeCaseWithAcronyms(featureName, acronyms)}_repository.dart';",
      );
      // Base Models Import
      if (isPaginated) {
        content.writeln(
            "import '../../../../core/services/network_service/models/request/base_pagination_request.dart';");
        content.writeln(
            "import '../../../../core/services/network_service/models/response/base_pagination_response.dart';");
      }

      if (innerReturn.endsWith('Entity')) {
        content.writeln(
          "import '../entities/${toSnakeCaseWithAcronyms(innerReturn, acronyms)}.dart';",
        );
      }

      final innerParam = names.getInnerType(paramType);

      String mappedInnerParam = innerParam;
      if (innerParam == 'BasePaginationRequest') {
        mappedInnerParam = innerParam;
      } else if (innerParam.endsWith('BaseRequest')) {
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

      final queryParamType = m['queryParamType'] as String? ?? 'void';
      final innerQueryParam = names.getInnerType(queryParamType);
      String mappedInnerQueryParam = innerQueryParam;
      if (innerQueryParam == 'BasePaginationRequest') {
        mappedInnerQueryParam = innerQueryParam;
      } else if (innerQueryParam.endsWith('BaseRequest')) {
        mappedInnerQueryParam =
            '${innerQueryParam.substring(0, innerQueryParam.length - 11)}Params';
      } else if (innerQueryParam.endsWith('Request')) {
        mappedInnerQueryParam =
            '${innerQueryParam.substring(0, innerQueryParam.length - 7)}Params';
      } else if (innerQueryParam.endsWith('Model') ||
          innerQueryParam.endsWith('QueryParams')) {
        mappedInnerQueryParam =
            '${innerQueryParam}Entity'; // Assuming query params are suffixed to entity
      }
      if (queryParamType.endsWith('QueryParams')) {
        mappedInnerQueryParam = '${queryParamType}Entity';
      }
      String mappedQueryParamType =
          queryParamType.replaceFirst(innerQueryParam, mappedInnerQueryParam);

      if (!isPaginated) {
        if (mappedInnerParam == 'BasePaginationRequest') {
          content.writeln(
              "import '../../../../core/services/network_service/models/request/base_pagination_request.dart';");
        } else if (mappedInnerParam.endsWith('Entity') ||
            mappedInnerParam.endsWith('Params')) {
          content.writeln(
            "import '../entities/${toSnakeCaseWithAcronyms(mappedInnerParam, acronyms)}.dart';",
          );
        }
      }

      if (mappedInnerQueryParam == 'BasePaginationRequest') {
        content.writeln(
            "import '../../../../core/services/network_service/models/request/base_pagination_request.dart';");
      } else if (mappedInnerQueryParam.endsWith('Entity') ||
          mappedInnerQueryParam.endsWith('Params')) {
        content.writeln(
          "import '../entities/${toSnakeCaseWithAcronyms(mappedInnerQueryParam, acronyms)}.dart';",
        );
      }

      final pathParams =
          (m['pathParams'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      bool needsWrapper = false;
      String wrapperName = '${methodName.pascalCase}Params';

      int extraParams = (mappedParamType != 'void' || isPaginated ? 1 : 0) +
          (mappedQueryParamType != 'void' ? 1 : 0);
      if (pathParams.isNotEmpty && (extraParams > 0 || pathParams.length > 1)) {
        needsWrapper = true;
      } else if (extraParams > 1) {
        needsWrapper = true;
      }

      if (needsWrapper) {
        content.writeln('class $wrapperName {');
        for (var p in pathParams) {
          content.writeln('  final ${p['type']} ${p['name']};');
        }
        if (mappedQueryParamType != 'void') {
          content.writeln('  final $mappedQueryParamType queryParams;');
        }
        if (isPaginated) {
          content.writeln('  final BasePaginationRequest params;');
        } else if (mappedParamType != 'void') {
          content.writeln('  final $mappedParamType params;');
        }
        content.writeln();
        content.writeln('  $wrapperName({');
        for (var p in pathParams) {
          content.writeln('    required this.${p['name']},');
        }
        if (mappedQueryParamType != 'void') {
          content.writeln('    required this.queryParams,');
        }
        if (isPaginated || mappedParamType != 'void') {
          content.writeln('    required this.params,');
        }
        content.writeln('  });');
        content.writeln('}');
        content.writeln();
      }

      content.writeln('@injectable');

      String ret = returnType == 'void' ? 'void' : returnType;
      if (isPaginated && innerReturn.endsWith('Entity')) {
        ret = 'BasePaginationResponse<$innerReturn>';
      }

      String useCaseParam = 'NoParams';
      if (needsWrapper) {
        useCaseParam = wrapperName;
      } else if (pathParams.isNotEmpty) {
        useCaseParam = pathParams.first['type']; // Example: String
      } else if (mappedQueryParamType != 'void') {
        useCaseParam = mappedQueryParamType;
      } else if (isPaginated) {
        useCaseParam = 'BasePaginationRequest';
      } else if (mappedParamType != 'void') {
        useCaseParam = mappedParamType;
      }

      content.writeln(
          'class $useCaseName implements UseCase<$ret, $useCaseParam> {');
      content
          .writeln('  final ${featureName.pascalCase}Repository repository;');
      content.writeln();
      content.writeln('  $useCaseName(this.repository);');
      content.writeln();
      content.writeln('  @override');
      content.writeln(
          '  Future<Either<Failure, $ret>> call($useCaseParam params) async {');

      List<String> repoCallArgs = [];
      if (needsWrapper) {
        for (var p in pathParams) {
          repoCallArgs.add('params.${p['name']}');
        }
        if (mappedQueryParamType != 'void') {
          repoCallArgs.add('params.queryParams');
        }
        if (isPaginated || mappedParamType != 'void') {
          repoCallArgs.add('params.params'); // The body params
        }
      } else if (pathParams.isNotEmpty) {
        repoCallArgs.add('params');
      } else if (mappedQueryParamType != 'void') {
        repoCallArgs.add('params');
      } else if (isPaginated || mappedParamType != 'void') {
        repoCallArgs.add('params');
      }

      String repoCallStr = repoCallArgs.join(', ');

      content.writeln('    return repository.$methodName($repoCallStr);');
      content.writeln('  }');
      content.writeln('}');

      final file = File('$directory/$fileName.dart');
      if (!file.parent.existsSync()) {
        await file.parent.create(recursive: true);
      }
      await file.writeAsString(content.toString());
    }
  }
}
