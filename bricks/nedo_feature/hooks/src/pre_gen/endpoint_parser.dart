import 'package:mason/mason.dart';

class EndpointParser {
  final Logger logger;

  EndpointParser({required this.logger});

  void parseEndpoints(List<String> userEndpoints, Map<String, dynamic> schema,
      HookContext context) {
    if (!schema.containsKey('paths')) {
      logger.warn('No "paths" found in the schema.');
      return;
    }

    final Map<String, dynamic> paths = schema['paths'];
    final List<Map<String, dynamic>> parsedMethods = [];
    final Set<String> targetComponents =
        Set<String>.from(context.vars['target_component'] ?? []);
    final List<Map<String, dynamic>> additionalComponents = [];
    final List<Map<String, dynamic>> injectedEndpoints = [];

    for (var userEndpoint in userEndpoints) {
      if (userEndpoint.isEmpty) continue;

      String? matchedPath;
      Map<String, dynamic>? pathItem;

      for (var pathKey in paths.keys) {
        if (pathKey.contains(userEndpoint) || userEndpoint.contains(pathKey)) {
          matchedPath = pathKey;
          pathItem = paths[pathKey];
          break;
        }
      }

      if (matchedPath == null || pathItem == null) {
        logger.warn('Endpoint "$userEndpoint" not found in schema.');
        continue;
      }

      // Find the first HTTP method (get, post, put, etc)
      String httpMethod = '';
      Map<String, dynamic> operation = {};
      for (var method in ['get', 'post', 'put', 'patch', 'delete']) {
        if (pathItem.containsKey(method)) {
          httpMethod = method;
          operation = pathItem[method];
          break;
        }
      }

      if (httpMethod.isEmpty) {
        logger.warn('No supported HTTP method found for $matchedPath');
        continue;
      }

      // Generate names
      final pathParts = matchedPath
          .split('/')
          .where((e) =>
              e.isNotEmpty &&
              !e.startsWith('{') &&
              !RegExp(r'^(api|v\d+)$', caseSensitive: false).hasMatch(e))
          .toList();
      String rawMethodName =
          httpMethod + pathParts.map((e) => e.pascalCase).join('');
      final methodName = rawMethodName.camelCase;

      final urlConstName =
          pathParts.map((e) => e.pascalCase).join('').camelCase;

      String strippedUrl = matchedPath.replaceAll(
          RegExp(r'^/?api/v\d+/?', caseSensitive: false), '');
      if (strippedUrl.startsWith('/')) {
        strippedUrl = strippedUrl.substring(1);
      }

      injectedEndpoints.add({
        'name': urlConstName,
        'url': strippedUrl,
      });

      // Extract return type
      String returnType = 'void';
      bool isPaginated = false;

      final responses = operation['responses'] ?? {};
      final okResponse = responses['200'] ?? responses['201'] ?? {};
      final content = okResponse['content'] ?? {};

      String? refName;
      for (var format in [
        'application/json',
        'text/plain',
        'text/json',
        'application/*+json'
      ]) {
        if (content.containsKey(format)) {
          final schemaRef = content[format]['schema'] ?? {};
          if (schemaRef.containsKey(r'$ref')) {
            refName = schemaRef[r'$ref'].split('/').last;
            break;
          }
        }
      }

      if (refName != null) {
        String innerTarget = refName;
        if (refName.endsWith('PaginationResponseObjectBaseResponse')) {
          innerTarget =
              refName.replaceAll('PaginationResponseObjectBaseResponse', '');
          isPaginated = true;
          returnType = innerTarget;
        } else if (refName.endsWith('ListObjectBaseResponse')) {
          innerTarget = refName.replaceAll('ListObjectBaseResponse', '');
          returnType = 'List<$innerTarget>';
        } else if (refName.endsWith('ObjectBaseResponse')) {
          innerTarget = refName.replaceAll('ObjectBaseResponse', '');
          returnType = innerTarget;
        } else {
          returnType = innerTarget;
        }

        if (innerTarget != 'void' && innerTarget.isNotEmpty) {
          targetComponents.add(innerTarget);
        }
      }

      // Extract param type
      String paramType = 'void';
      final requestBody = operation['requestBody'] ?? {};
      final reqContent = requestBody['content'] ?? {};
      String? reqRefName;

      for (var format in [
        'application/json',
        'text/json',
        'application/*+json'
      ]) {
        if (reqContent.containsKey(format)) {
          final schemaRef = reqContent[format]['schema'] ?? {};
          if (schemaRef.containsKey(r'$ref')) {
            reqRefName = schemaRef[r'$ref'].split('/').last;
            break;
          }
        }
      }

      final parameters = (operation['parameters'] as List?) ?? [];
      final pathParams = <Map<String, dynamic>>[];
      for (var p in parameters) {
        if (p['in'] == 'path') {
          pathParams.add({
            'name': p['name'],
            'type': _mapOpenApiToDartType(p['schema']?['type'] ?? 'string'),
          });
        }
      }

      if (reqRefName != null) {
        if (reqRefName.contains('PaginationQueryBaseRequest')) {
          paramType = 'BasePaginationRequest'; // Generic catch
        } else {
          paramType = reqRefName;
          targetComponents.add(reqRefName);
        }
      } else if (parameters.isNotEmpty) {
        if (parameters.length == 1) {
          final pType = parameters[0]['schema']?['type'] ?? 'string';
          paramType = _mapOpenApiToDartType(pType);
        } else {
          // Create additional component
          final reqName = '${methodName.pascalCase}Request';
          paramType = reqName;
          final fields = <Map<String, dynamic>>[];

          for (var p in parameters) {
            final pName = p['name'] ?? '';
            final required = p['required'] == true;
            final type = p['schema']?['type'] ?? 'string';

            fields.add({
              'name': pName,
              'type': _mapOpenApiToDartType(type),
              'nullable': !required,
            });
          }

          additionalComponents.add({
            'name': reqName,
            'fields': fields,
          });
          targetComponents.add(reqName);
        }
      }

      parsedMethods.add({
        'name': methodName,
        'returnType': returnType,
        'paramType': paramType,
        'pathParams': pathParams,
        'urlConstName': urlConstName,
        'isPaginated': isPaginated,
        'isFuture': true,
      });

      logger.success(
          'Parsed endpoint "$userEndpoint" -> $methodName($paramType) returns $returnType');
    }

    context.vars['methods'] = parsedMethods;
    context.vars['target_component'] = targetComponents.toList();
    context.vars['injected_endpoints'] = injectedEndpoints;
    context.vars['generated_by_endpoints'] = true;

    if (additionalComponents.isNotEmpty) {
      final existingAdditional = context.vars['additional_components'];
      if (existingAdditional is List) {
        (context.vars['additional_components'] as List)
            .addAll(additionalComponents);
      } else {
        context.vars['additional_components'] = additionalComponents;
      }
    }
  }

  String _mapOpenApiToDartType(String openApiType) {
    switch (openApiType.toLowerCase()) {
      case 'integer':
      case 'int':
        return 'int';
      case 'boolean':
      case 'bool':
        return 'bool';
      case 'number':
        return 'double';
      default:
        return 'String';
    }
  }
}
