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
        "import '../../../../../../core/services/network_service/models/base_list_request_model.dart';");
    content.writeln(
        "import '../../../../../../core/services/network_service/models/pagination_response_model.dart';");

    final usedModels = <String>{};
    final usedEntities = <String>{};
    for (final m in methods) {
      final returnType = m['returnType'] as String;
      final innerReturn = names.getInnerType(returnType);

      if (innerReturn.endsWith('Entity')) {
        usedModels.add(innerReturn.replaceAll('Entity', 'Model'));
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
        baseType = innerReturn.replaceAll('Entity', 'Model');
      }

      String ret = baseType;
      if (isPaginated) {
        ret = 'PaginationResponseModel<$baseType>';
      } else if (returnType.startsWith('List<')) {
        ret = 'List<$baseType>';
      }

      String params = '';
      if (isPaginated) {
        params = 'BaseListRequestModel params';
      } else if (paramType != 'void') {
        params = '$paramType params';
      }

      content.writeln('  Future<$ret> $methodName($params);');
    }
    content.writeln('}');
    return content.toString();
  }
}
