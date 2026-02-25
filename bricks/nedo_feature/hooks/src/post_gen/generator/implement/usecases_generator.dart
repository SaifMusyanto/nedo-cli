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
      final returnType = m['returnType'] as String;
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

      if (!isPaginated) {
        if (mappedInnerParam.endsWith('Entity') ||
            mappedInnerParam.endsWith('Params')) {
          content.writeln(
            "import '../entities/${toSnakeCaseWithAcronyms(mappedInnerParam, acronyms)}.dart';",
          );
        }
      }

      final pathParams =
          (m['pathParams'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      bool needsWrapper = false;
      String wrapperName = '${methodName.pascalCase}Params';

      if (pathParams.isNotEmpty &&
          (mappedParamType != 'void' || isPaginated || pathParams.length > 1)) {
        needsWrapper = true;
      }

      if (needsWrapper) {
        content.writeln('class $wrapperName {');
        for (var p in pathParams) {
          content.writeln('  final ${p['type']} ${p['name']};');
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
        if (isPaginated || mappedParamType != 'void') {
          repoCallArgs.add('params.params');
        }
      } else if (pathParams.isNotEmpty) {
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
