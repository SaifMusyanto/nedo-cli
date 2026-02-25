import 'package:mason/mason.dart';
import '../../../../../../../shared/helper/snake_case_with_acronyms.dart';
import '../../helper/name_provider.dart';
import '../base/feature_generator.dart';

class RepositoryInterfaceGenerator extends FeatureGenerator {
  @override
  String getDirectory(String featureName, List<String> acronyms) {
    return 'lib/features/${toSnakeCaseWithAcronyms(featureName, acronyms)}/domain/repositories';
  }

  @override
  String getFileName(String featureName, List<dynamic> methods,
      NameProvider names, List<String> acronyms) {
    return '${toSnakeCaseWithAcronyms(featureName, acronyms)}_repository';
  }

  @override
  String buildContent(String featureName, List<dynamic> methods,
      NameProvider names, List<String> acronyms) {
    final className = '${featureName.pascalCase}Repository';
    final content = StringBuffer();

    content.writeln("import 'package:fpdart/fpdart.dart';");
    content.writeln("import '../../../../core/errors/failures.dart';");
    // Base Models Import
    content.writeln(
        "import '../../../../core/network/models/base_list_request_model.dart';");
    content.writeln(
        "import '../../../../core/services/network_service/models/response/base_pagination_response.dart';");

    final usedEntities = <String>{};
    for (final m in methods) {
      final returnType = m['returnType'] as String;
      final innerType = names.getInnerType(returnType);
      if (innerType.endsWith('Entity') && innerType != 'void') {
        usedEntities.add(innerType);
      }
    }

    for (final entity in usedEntities) {
      content.writeln(
        "import '../entities/${toSnakeCaseWithAcronyms(entity, acronyms)}.dart';",
      );
    }

    final usedParams = <String>{};
    for (final m in methods) {
      final param = m['paramType'] as String;
      final innerParam = names.getInnerType(param);
      if (innerParam != 'void' &&
          !['String', 'int', 'bool', 'double'].contains(innerParam)) {
        usedParams.add(innerParam);
      }
    }

    for (final param in usedParams) {
      if (param.endsWith('Model')) {
        content.writeln(
          "import '../../data/models/${toSnakeCaseWithAcronyms(param, acronyms)}.dart';",
        );
      } else if (param.endsWith('Entity')) {
        content.writeln(
          "import '../entities/${toSnakeCaseWithAcronyms(param, acronyms)}.dart';",
        );
      } else if (param.endsWith('Params')) {
        content.writeln(
          "import '../entities/${toSnakeCaseWithAcronyms(param, acronyms)}.dart';",
        );
      }
    }

    content.writeln();

    content.writeln('abstract class $className {');
    for (final m in methods) {
      final methodName = m['name'] as String;
      final returnType = m['returnType'] as String;
      final innerReturn = names.getInnerType(returnType);
      final paramType = m['paramType'] as String;
      final isPaginated = m['isPaginated'] as bool? ?? false;

      String ret = returnType == 'void' ? 'void' : returnType;
      if (isPaginated && innerReturn.endsWith('Entity')) {
        ret = 'BasePaginationResponse<$innerReturn>';
      }

      final pathParams =
          (m['pathParams'] as List?)?.cast<Map<String, dynamic>>() ?? [];

      String params = '';
      List<String> paramParts = [];
      for (var p in pathParams) {
        final pName = p['name'];
        final pType = p['type'];
        paramParts.add('$pType $pName');
      }

      if (isPaginated) {
        paramParts.add('BaseListRequestModel params');
      } else if (paramType != 'void') {
        paramParts.add('$paramType params');
      }

      params = paramParts.join(', ');

      content.writeln('  Future<Either<Failure, $ret>> $methodName($params);');
    }
    content.writeln('}');
    return content.toString();
  }
}
