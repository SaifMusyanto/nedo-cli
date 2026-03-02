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
    content.writeln(
        "import '../../../../../../core/config/constants/endpoint_constant.dart';");
    // Base Models Import
    content.writeln(
        "import '../../../../../../core/services/network_service/models/request/base_pagination_request.dart';");
    content.writeln(
        "import '../../../../../../core/services/network_service/models/response/base_pagination_response.dart';");

    final usedModels = <String>{};

    for (final m in methods) {
      String returnType = m['returnType'] as String;
      if (returnType == 'GuidObjectBaseResponse' || returnType == 'Guid') {
        returnType = 'String';
      } else if (returnType == 'List<GuidObjectBaseResponse>' ||
          returnType == 'List<Guid>') {
        returnType = 'List<String>';
      }
      final innerReturn = names.getInnerType(returnType);

      if (innerReturn.endsWith('Entity')) {
        usedModels
            .add('${innerReturn.substring(0, innerReturn.length - 6)}Model');
      } else if (innerReturn != 'void' &&
          !['String', 'int', 'bool', 'double'].contains(innerReturn)) {
        usedModels.add(innerReturn);
      }

      final isPaginated = m['isPaginated'] as bool? ?? false;

      if (!isPaginated) {
        final paramType = m['paramType'] as String;
        final innerParam = names.getInnerType(paramType);

        String mappedInnerParam = innerParam;
        if (innerParam == 'BasePaginationRequest') {
          mappedInnerParam = innerParam;
        } else if (innerParam.endsWith('BaseRequest')) {
          mappedInnerParam =
              '${innerParam.substring(0, innerParam.length - 11)}Model';
        } else if (innerParam.endsWith('Request')) {
          mappedInnerParam =
              '${innerParam.substring(0, innerParam.length - 7)}Model';
        } else if (innerParam.endsWith('Params')) {
          mappedInnerParam =
              '${innerParam.substring(0, innerParam.length - 6)}Model';
        } else if (innerParam.endsWith('Entity')) {
          mappedInnerParam =
              '${innerParam.substring(0, innerParam.length - 6)}Model';
        }

        if (mappedInnerParam != 'void' &&
            !['String', 'int', 'bool', 'double'].contains(mappedInnerParam)) {
          usedModels.add(mappedInnerParam);
        }
      }

      final queryParamType = m['queryParamType'] as String? ?? 'void';
      if (queryParamType != 'void') {
        final innerQueryParam = names.getInnerType(queryParamType);
        String mappedInnerQueryParam = innerQueryParam;
        if (innerQueryParam == 'BasePaginationRequest') {
          mappedInnerQueryParam = innerQueryParam;
        } else if (innerQueryParam.endsWith('BaseRequest')) {
          mappedInnerQueryParam =
              '${innerQueryParam.substring(0, innerQueryParam.length - 11)}Model';
        } else if (innerQueryParam.endsWith('Request')) {
          mappedInnerQueryParam =
              '${innerQueryParam.substring(0, innerQueryParam.length - 7)}Model';
        } else if (innerQueryParam.endsWith('Params')) {
          mappedInnerQueryParam =
              '${innerQueryParam.substring(0, innerQueryParam.length - 6)}Model';
        } else if (innerQueryParam.endsWith('Entity') ||
            innerQueryParam.endsWith('QueryParams')) {
          mappedInnerQueryParam = '${innerQueryParam}Model';
        }
        if (queryParamType.endsWith('QueryParams')) {
          mappedInnerQueryParam = '${queryParamType}Model';
        }
        if (!['String', 'int', 'bool', 'double']
            .contains(mappedInnerQueryParam)) {
          usedModels.add(mappedInnerQueryParam);
        }
      }
    }

    for (final model in usedModels) {
      if (![
        'void',
        'String',
        'int',
        'bool',
        'double',
        'BasePaginationRequest',
        'BasePaginationResponse'
      ].contains(model)) {
        content.writeln(
          "import '../../../models/${toSnakeCaseWithAcronyms(model, acronyms)}.dart';",
        );
      }
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
      String returnType = m['returnType'] as String;
      if (returnType == 'GuidObjectBaseResponse' || returnType == 'Guid') {
        returnType = 'String';
      } else if (returnType == 'List<GuidObjectBaseResponse>' ||
          returnType == 'List<Guid>') {
        returnType = 'List<String>';
      }
      final innerReturn = names.getInnerType(returnType);
      final paramType = m['paramType'] as String;
      final innerParam = names.getInnerType(paramType);
      final isPaginated = m['isPaginated'] as bool? ?? false;

      String mappedInnerParam = innerParam;
      if (innerParam == 'BasePaginationRequest') {
        mappedInnerParam = innerParam;
      } else if (innerParam.endsWith('BaseRequest')) {
        mappedInnerParam =
            '${innerParam.substring(0, innerParam.length - 11)}Model';
      } else if (innerParam.endsWith('Request')) {
        mappedInnerParam =
            '${innerParam.substring(0, innerParam.length - 7)}Model';
      } else if (innerParam.endsWith('Params')) {
        mappedInnerParam =
            '${innerParam.substring(0, innerParam.length - 6)}Model';
      } else if (innerParam.endsWith('Entity')) {
        mappedInnerParam =
            '${innerParam.substring(0, innerParam.length - 6)}Model';
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
            '${innerQueryParam.substring(0, innerQueryParam.length - 11)}Model';
      } else if (innerQueryParam.endsWith('Request')) {
        mappedInnerQueryParam =
            '${innerQueryParam.substring(0, innerQueryParam.length - 7)}Model';
      } else if (innerQueryParam.endsWith('Params')) {
        mappedInnerQueryParam =
            '${innerQueryParam.substring(0, innerQueryParam.length - 6)}Model';
      } else if (innerQueryParam.endsWith('Entity') ||
          innerQueryParam.endsWith('QueryParams')) {
        mappedInnerQueryParam = '${innerQueryParam}Model';
      }
      if (queryParamType.endsWith('QueryParams')) {
        mappedInnerQueryParam = '${queryParamType}Model';
      }
      String mappedQueryParamType =
          queryParamType.replaceFirst(innerQueryParam, mappedInnerQueryParam);

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
      final urlConstName = m['urlConstName'] as String?;

      String params = '';
      List<String> paramParts = [];
      for (var p in pathParams) {
        final pName = p['name'];
        final pType = p['type'];
        paramParts.add('$pType $pName');
      }

      if (mappedQueryParamType != 'void') {
        paramParts.add('$mappedQueryParamType queryParams');
      }

      if (isPaginated) {
        paramParts.add('BasePaginationRequest params');
      } else if (mappedParamType != 'void') {
        paramParts.add('$mappedParamType params');
      }

      params = paramParts.join(', ');

      content.writeln('  @override');
      content.writeln('  Future<$ret> $methodName($params) async {');

      if (urlConstName != null) {
        if (pathParams.isEmpty) {
          content
              .writeln('    final endpoint = EndpointConstant.$urlConstName;');
        } else {
          content.writeln('    var endpoint = EndpointConstant.$urlConstName;');
          for (var p in pathParams) {
            final pName = p['name'];
            content.writeln(
                "    endpoint = endpoint.replaceAll('{$pName}', $pName.toString());");
          }
        }
      } else {
        content.writeln("    final endpoint = '/api/v1/path/to/endpoint';");
        content.writeln('    // TODO: Implement $methodName');
      }

      final httpMethod = m['httpMethod'] as String? ?? 'get';

      if (isPaginated) {
        content.writeln('    return handlePagination<$baseType>(');
        content.writeln('      dioClient,');
        content.writeln('      endpoint: endpoint,');
        if (mappedQueryParamType != 'void') {
          content.writeln('      queryParameters: queryParams.toMap(),');
        }
        content.writeln('      requestBody: {"data": params.toMap()},');
        content.writeln('      itemMapper: (json) => $baseType.fromMap(json),');
        content.writeln('    );');
      } else if (returnType.startsWith('List<')) {
        content.writeln('    return handleGetList(');
        content.writeln('      dioClient,');
        content.writeln('      endpoint: endpoint,');
        if (mappedQueryParamType != 'void') {
          content.writeln('      queryParameters: queryParams.toMap(),');
        }
        if (['String', 'int', 'bool', 'double'].contains(baseType)) {
          content.writeln('      itemMapper: (json) => json as $baseType,');
        } else {
          content
              .writeln('      itemMapper: (json) => $baseType.fromMap(json),');
        }
        content.writeln('    );');
      } else {
        if (httpMethod == 'post' ||
            httpMethod == 'put' ||
            httpMethod == 'patch') {
          String handleCall = httpMethod == 'put'
              ? 'handlePut'
              : (httpMethod == 'patch' ? 'handlePatch' : 'handlePost');
          content.writeln('    return $handleCall(');
          content.writeln('      dioClient,');
          content.writeln('      endpoint: endpoint,');

          if (mappedParamType != 'void') {
            content.writeln('      body: {"data": params.toMap()},');
          }
          if (mappedQueryParamType != 'void') {
            content.writeln('      queryParameters: queryParams.toMap(),');
          }

          if (baseType != 'void') {
            if (['String', 'int', 'bool', 'double'].contains(baseType)) {
              content.writeln('      mapper: (json) => json as $baseType,');
            } else {
              content
                  .writeln('      mapper: (json) => $baseType.fromMap(json),');
            }
          }
          content.writeln('    );');
        } else if (httpMethod == 'delete') {
          content.writeln('    return handleDelete(');
          content.writeln('      dioClient,');
          content.writeln('      endpoint: endpoint,');

          if (mappedParamType != 'void') {
            content.writeln('      body: {"data": params.toMap()},');
          }
          if (mappedQueryParamType != 'void') {
            content.writeln('      queryParameters: queryParams.toMap(),');
          }

          if (baseType != 'void') {
            if (['String', 'int', 'bool', 'double'].contains(baseType)) {
              content.writeln('      mapper: (json) => json as $baseType,');
            } else {
              content
                  .writeln('      mapper: (json) => $baseType.fromMap(json),');
            }
          }
          content.writeln('    );');
        } else {
          // get method
          content.writeln('    return handleGet(');
          content.writeln('      dioClient,');
          content.writeln('      endpoint: endpoint,');

          if (mappedQueryParamType != 'void') {
            content.writeln('      queryParameters: queryParams.toMap(),');
          }

          if (baseType != 'void') {
            if (['String', 'int', 'bool', 'double'].contains(baseType)) {
              content.writeln('      mapper: (json) => json as $baseType,');
            } else {
              content
                  .writeln('      mapper: (json) => $baseType.fromMap(json),');
            }
          }
          content.writeln('    );');
        }
      }

      content.writeln('  }');
      content.writeln();
    }
    content.writeln('}');
    return content.toString();
  }
}
