import 'package:mason/mason.dart';
import '../../../../../../../shared/helper/snake_case_with_acronyms.dart';
import '../../helper/name_provider.dart';
import '../base/feature_generator.dart';

class RemoteProviderImplementationGenerator extends FeatureGenerator {
  @override
  String getDirectory(String featureName, List<String> acronyms) {
    return 'lib/features/${toSnakeCaseWithAcronyms(featureName, acronyms)}/data/providers/remote/implementations';
  }

  @override
  String getFileName(String featureName, List<dynamic> methods,
      NameProvider names, List<String> acronyms) {
    return 'remote_${toSnakeCaseWithAcronyms(featureName, acronyms)}_provider';
  }

  @override
  String buildContent(String featureName, List<dynamic> methods,
      NameProvider names, List<String> acronyms) {
    final implName = 'Remote${featureName.pascalCase}Provider';
    final interfaceName = 'IRemote${featureName.pascalCase}Provider';
    final content = StringBuffer();

    content.writeln("import 'package:injectable/injectable.dart';");
    content.writeln(
        "import '../../../../../../core/services/network_service/dio_client.dart';");
    content.writeln(
      "import '../../../../../../core/services/storage_service/secure/secure_storage_service.dart';",
    );
    // Add Mixin Import
    content.writeln(
      "import '../../../../../../core/mixins/dio_mixin.dart';",
    );
    content.writeln(
      "import '../interfaces/i_remote_${toSnakeCaseWithAcronyms(featureName, acronyms)}_provider.dart';",
    );
    // Base Models Import
    content.writeln(
        "import '../../../../../../core/services/network_service/models/base_list_request_model.dart';");
    content.writeln(
        "import '../../../../../../core/services/network_service/models/pagination_response_model.dart';");

    final usedEntities = <String>{};
    final usedModels = <String>{};

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
    content.writeln('@Injectable(as: $interfaceName)');
    content.writeln(
        'class $implName with CustomDioMixin implements $interfaceName {');
    content.writeln('  final DioClient dioClient;');
    content.writeln('  final SecureStorageService secureStorageService;');
    content.writeln();
    content.writeln(
      '  $implName({required this.dioClient, required this.secureStorageService});',
    );
    content.writeln();

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

      content.writeln('  @override');
      content.writeln('  Future<$ret> $methodName($params) async {');
      content.writeln('    // TODO: Implement $methodName');

      if (isPaginated) {
        content.writeln('    // return handlePagination(');
        content.writeln('    //   dioClient,');
        content.writeln("    //   endpoint: '/api/v1/path/to/endpoint',");
        content.writeln('    //   requestBody: params.toMap(),');
        content.writeln('    //   itemMapper: $baseType.fromMap,');
        content.writeln('    // );');
      } else if (returnType.startsWith('List<')) {
        content.writeln('    // return handleGetList(');
        content.writeln('    //   dioClient,');
        content.writeln("    //   endpoint: '/api/v1/path/to/endpoint',");
        content.writeln('    //   itemMapper: $baseType.fromMap,');
        content.writeln('    // );');
      } else {
        if (paramType != 'void' && paramType.endsWith('Model') ||
            paramType.endsWith('Request')) {
          content.writeln('    // return handlePost(');
          content.writeln('    //   dioClient,');
          content.writeln("    //   endpoint: '/api/v1/path/to/endpoint',");
          content.writeln('    //   body: params.toMap(),');
          if (baseType != 'void') {
            content.writeln('    //   mapper: $baseType.fromMap,');
          }
          content.writeln('    // );');
        } else {
          content.writeln('    // return handleGet(');
          content.writeln('    //   dioClient,');
          content.writeln("    //   endpoint: '/api/v1/path/to/endpoint',");
          if (baseType != 'void') {
            content.writeln('    //   mapper: $baseType.fromMap,');
          }
          content.writeln('    // );');
        }
      }

      content.writeln('    throw UnimplementedError();');

      content.writeln('  }');
      content.writeln();
    }
    content.writeln('}');
    return content.toString();
  }
}
