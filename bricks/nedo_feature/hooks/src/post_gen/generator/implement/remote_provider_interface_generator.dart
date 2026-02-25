import 'package:mason/mason.dart';
import '../../../../../../../shared/helper/snake_case_with_acronyms.dart';
import '../../helper/name_provider.dart';
import '../base/feature_generator.dart';

class RemoteProviderInterfaceGenerator extends FeatureGenerator {
  @override
  String getDirectory(String featureName, List<String> acronyms) {
    return 'lib/features/${toSnakeCaseWithAcronyms(featureName, acronyms)}/data/providers/remote/interfaces';
  }

  @override
  String getFileName(String featureName, List<dynamic> methods,
      NameProvider names, List<String> acronyms) {
    return 'i_remote_${toSnakeCaseWithAcronyms(featureName, acronyms)}_provider';
  }

  @override
  String buildContent(String featureName, List<dynamic> methods,
      NameProvider names, List<String> acronyms) {
    final interfaceName = 'IRemote${featureName.pascalCase}Provider';
    final content = StringBuffer();

    // Base Models Import
    content.writeln(
        "import '../../../../../../core/network/models/base_list_request_model.dart';");
    content.writeln(
        "import '../../../../../../core/services/network_service/models/response/base_pagination_response.dart';");

    final usedModels = <String>{};
    final usedEntities = <String>{};
    for (final m in methods) {
      final returnType = m['returnType'] as String;
      final innerReturn = names.getInnerType(returnType);

      if (innerReturn.endsWith('Entity')) {
        usedModels
            .add('${innerReturn.substring(0, innerReturn.length - 6)}Model');
      }

      final paramType = m['paramType'] as String;
      final innerParam = names.getInnerType(paramType);

      if (innerParam.endsWith('Model')) {
        usedModels.add(innerParam);
      } else if (innerParam.endsWith('Entity') ||
          innerParam.endsWith('Params')) {
        usedEntities.add(innerParam);
      }
    }

    for (final model in usedModels) {
      content.writeln(
        "import '../../../models/${toSnakeCaseWithAcronyms(model, acronyms)}.dart';",
      );
    }

    for (final entity in usedEntities) {
      content.writeln(
        "import '../../../../domain/entities/${toSnakeCaseWithAcronyms(entity, acronyms)}.dart';",
      );
    }

    content.writeln();
    content.writeln('abstract class $interfaceName {');
    for (final m in methods) {
      final methodName = m['name'] as String;
      final returnType = m['returnType'] as String;
      final innerReturn = names.getInnerType(returnType);
      final paramType = m['paramType'] as String;
      final isPaginated = m['isPaginated'] as bool? ?? false;

      String baseType = innerReturn;
      if (innerReturn.endsWith('Entity')) {
        baseType = '${innerReturn.substring(0, innerReturn.length - 6)}Model';
      }

      String ret = baseType;
      if (isPaginated) {
        ret = 'BasePaginationResponse<$baseType>';
      } else if (returnType.startsWith('List<')) {
        ret = 'List<$baseType>';
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

      content.writeln('  Future<$ret> $methodName($params);');
    }
    content.writeln('}');
    return content.toString();
  }
}
