import 'dart:io';
import 'package:mason/mason.dart';
import '../../nedo_model/hooks/post_gen.dart' as model_post_gen;
import '../../nedo_bloc_generic/hooks/post_gen.dart' as bloc_post_gen;
import '../../../shared/helper/snake_case_with_acronyms.dart';

Future<void> run(HookContext context) async {
  final featureName = context.vars['name'] as String;
  final methods = context.vars['methods'] as List<dynamic>? ?? [];
  final acronyms = (context.vars['acronyms'] as List?)?.cast<String>() ?? [];

  final progress = context.logger.progress('Generating models and entities...');
  try {
    await model_post_gen.run(context);
    progress.complete('Models generated successfully.');
  } catch (e) {
    progress.fail('Failed to generate models: $e');
    return;
  }
  final featureProgress = context.logger.progress(
    'Generating clean architecture layers for $featureName...',
  );

  final models = context.vars['models'] as List<dynamic>? ?? [];
  final nameProvider = _NameProvider(models);

  try {
    // Domain Layer
    await _generateRepositoryInterface(
        featureName, methods, nameProvider, acronyms);
    await _generateUseCases(featureName, methods, nameProvider, acronyms);

    // Data Layer
    await _generateRepositoryImplementation(
        featureName, methods, nameProvider, acronyms);
    await _generateRemoteProviderInterface(
        featureName, methods, nameProvider, acronyms);
    await _generateRemoteProviderImplementation(
      featureName,
      methods,
      nameProvider,
      acronyms,
    );
    await _generateBloc(context, acronyms);

    featureProgress.complete('Feature $featureName generated successfully!');

    // Format code
    try {
      await Process.run('dart', ['format', '.']);
    } catch (e) {
      context.logger.warn('Could not run dart format: $e');
    }
  } catch (e, stackTrace) {
    featureProgress.fail('Error generating feature: $e');
    context.logger.err(stackTrace.toString());
  }
}

String _getInnerType(String type) {
  if (type.startsWith('List<') && type.endsWith('>')) {
    return type.substring(5, type.length - 1);
  }
  return type;
}

// --- Generators ---

Future<void> _generateRepositoryInterface(
  String featureName,
  List<dynamic> methods,
  _NameProvider names,
  List<String> acronyms,
) async {
  final className = '${featureName.pascalCase}Repository';
  final fileName =
      '${toSnakeCaseWithAcronyms(featureName, acronyms)}_repository';
  final content = StringBuffer();

  content.writeln("import 'package:fpdart/fpdart.dart';");
  content.writeln("import '../../../../core/errors/failures.dart';");
  // Base Models Import
  content.writeln(
      "import '../../../../core/network/models/base_list_request_model.dart';");
  content.writeln(
      "import '../../../../core/network/models/pagination_response_model.dart';");

  final usedEntities = <String>{};
  for (final m in methods) {
    final returnType = m['returnType'] as String;
    final innerType = _getInnerType(returnType);
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
    final innerParam = _getInnerType(param);
    if (innerParam != 'void' &&
        !['String', 'int', 'bool', 'double'].contains(innerParam)) {
      usedParams.add(innerParam);
    }
  }

  for (final param in usedParams) {
    if (param.endsWith('Model')) {
      content.writeln(
        "import '../data/models/${toSnakeCaseWithAcronyms(param, acronyms)}.dart';",
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
    final innerReturn = _getInnerType(returnType);
    final paramType = m['paramType'] as String;
    final isPaginated = m['isPaginated'] as bool? ?? false;

    String ret = returnType == 'void' ? 'void' : returnType;
    if (isPaginated && innerReturn.endsWith('Entity')) {
      ret = 'PaginationResponseModel<$innerReturn>';
    }

    String params = '';

    if (isPaginated) {
      params = 'BaseListRequestModel params';
    } else if (paramType != 'void') {
      params = '$paramType params';
    }

    content.writeln('  Future<Either<Failure, $ret>> $methodName($params);');
  }
  content.writeln('}');

  final file = File(
    'lib/features/${toSnakeCaseWithAcronyms(featureName, acronyms)}/domain/repositories/$fileName.dart',
  );
  await file.create(recursive: true);
  await file.writeAsString(content.toString());
}

Future<void> _generateRepositoryImplementation(
  String featureName,
  List<dynamic> methods,
  _NameProvider names,
  List<String> acronyms,
) async {
  final repoName = '${featureName.pascalCase}Repository';
  final repoImplName = '${repoName}Impl';
  final providerName = 'IRemote${featureName.pascalCase}Provider';
  final remoteVar = 'remote${featureName.pascalCase}Provider';

  final content = StringBuffer();
  final featureSnake = toSnakeCaseWithAcronyms(featureName, acronyms);

  content.writeln("import 'package:fpdart/fpdart.dart';");
  content.writeln("import 'package:injectable/injectable.dart';");
  content.writeln("import '../../../../core/errors/failures.dart';");
  content.writeln(
      "import '../../../../core/utils/helpers/repository_helper.dart';");
  content.writeln(
    "import '../../domain/repositories/${featureSnake}_repository.dart';",
  );
  content.writeln(
    "import '../providers/remote/interfaces/i_remote_${featureSnake}_provider.dart';",
  );
  // Base Models Import
  content.writeln(
      "import '../../../../core/network/models/base_list_request_model.dart';");
  content.writeln(
      "import '../../../../core/network/models/pagination_response_model.dart';");

  final usedMappers = <String>{};
  for (final m in methods) {
    final returnType = m['returnType'] as String;
    final innerType = _getInnerType(returnType);
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
      usedMappers.add('${toSnakeCaseWithAcronyms(modelName, acronyms)}_mapper');
    }
  }

  for (final mapper in usedMappers) {
    content.writeln("import '../mappers/$mapper.dart';");
  }

  final usedParams = <String>{};
  for (final m in methods) {
    final param = m['paramType'] as String;
    final innerParam = _getInnerType(param);

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
    'class $repoImplName with RepositoryHelper implements $repoName {',
  );
  content.writeln('  final $providerName $remoteVar;');
  content.writeln();
  content.writeln('  $repoImplName(this.$remoteVar);');
  content.writeln();

  for (final m in methods) {
    final methodName = m['name'] as String;
    final returnType = m['returnType'] as String;
    final innerReturn = _getInnerType(returnType);
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
        content
            .writeln('      return result.map((e) => e.toEntity()).toList();');
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

  final file = File(
    'lib/features/${toSnakeCaseWithAcronyms(featureName, acronyms)}/data/repositories/${toSnakeCaseWithAcronyms(featureName, acronyms)}_repository_impl.dart',
  );
  await file.create(recursive: true);
  await file.writeAsString(content.toString());
}

Future<void> _generateRemoteProviderInterface(
  String featureName,
  List<dynamic> methods,
  _NameProvider names,
  List<String> acronyms,
) async {
  final interfaceName = 'IRemote${featureName.pascalCase}Provider';
  final fileName =
      'i_remote_${toSnakeCaseWithAcronyms(featureName, acronyms)}_provider';
  final content = StringBuffer();

  // Base Models Import
  content.writeln(
      "import '../../../../../../core/network/models/base_list_request_model.dart';");
  content.writeln(
      "import '../../../../../../core/network/models/pagination_response_model.dart';");

  final usedModels = <String>{};
  final usedEntities = <String>{};
  for (final m in methods) {
    final returnType = m['returnType'] as String;
    final innerReturn = _getInnerType(returnType);

    if (innerReturn.endsWith('Entity')) {
      usedModels.add(innerReturn.replaceAll('Entity', 'Model'));
    }

    final paramType = m['paramType'] as String;
    final innerParam = _getInnerType(paramType);

    if (innerParam.endsWith('Model')) {
      usedModels.add(innerParam);
    } else if (innerParam.endsWith('Entity') || innerParam.endsWith('Params')) {
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
    final innerReturn = _getInnerType(returnType);
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

  final file = File(
    'lib/features/${toSnakeCaseWithAcronyms(featureName, acronyms)}/data/providers/remote/interfaces/$fileName.dart',
  );
  await file.create(recursive: true);
  await file.writeAsString(content.toString());
}

Future<void> _generateRemoteProviderImplementation(
  String featureName,
  List<dynamic> methods,
  _NameProvider names,
  List<String> acronyms,
) async {
  final implName = 'Remote${featureName.pascalCase}Provider';
  final interfaceName = 'IRemote${featureName.pascalCase}Provider';
  final fileName =
      'remote_${toSnakeCaseWithAcronyms(featureName, acronyms)}_provider';
  final content = StringBuffer();

  content.writeln("import 'package:injectable/injectable.dart';");
  content.writeln("import '../../../../../../core/network/dio_client.dart';");
  content.writeln(
    "import '../../../../../../core/storage/secure/secure_storage_service.dart';",
  );
  content.writeln(
    "import '../interfaces/i_remote_${toSnakeCaseWithAcronyms(featureName, acronyms)}_provider.dart';",
  );
  // Base Models Import
  content.writeln(
      "import '../../../../../../core/network/models/base_list_request_model.dart';");
  content.writeln(
      "import '../../../../../../core/network/models/pagination_response_model.dart';");

  final usedEntities = <String>{};
  final usedModels = <String>{};

  for (final m in methods) {
    final returnType = m['returnType'] as String;
    final innerReturn = _getInnerType(returnType);

    if (innerReturn.endsWith('Entity')) {
      usedModels.add(innerReturn.replaceAll('Entity', 'Model'));
    }

    final paramType = m['paramType'] as String;
    final innerParam = _getInnerType(paramType);

    if (innerParam.endsWith('Model')) {
      usedModels.add(innerParam);
    } else if (innerParam.endsWith('Entity') || innerParam.endsWith('Params')) {
      usedEntities.add(paramType);
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
  content.writeln('class $implName implements $interfaceName {');
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
    final innerReturn = _getInnerType(returnType);
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
      content.writeln('    // final response = await dioClient.post(');
      content.writeln("    //   '/api/v1/path/to/endpoint',");
      content.writeln('    //   data: params.toMap(),');
      content.writeln('    // );');
      content.writeln('    // if (response.statusCode == 200) {');
      content.writeln('    //   return PaginationResponseModel.fromJson(');
      content.writeln(
          "    //     response.data['data'], // Unwrap ObjectBaseResponse");
      content.writeln('    //     (json) => $baseType.fromMap(json),');
      content.writeln('    //   );');
      content.writeln('    // }');
    } else if (paramType.endsWith('Model')) {
      content.writeln('    final data = params.toMap();');
    }

    content.writeln('    throw UnimplementedError();');

    content.writeln('  }');
    content.writeln();
  }
  content.writeln('}');

  final file = File(
    'lib/features/${toSnakeCaseWithAcronyms(featureName, acronyms)}/data/providers/remote/implementations/$fileName.dart',
  );
  await file.create(recursive: true);
  await file.writeAsString(content.toString());
}

Future<void> _generateUseCases(
  String featureName,
  List<dynamic> methods,
  _NameProvider names,
  List<String> acronyms,
) async {
  for (final m in methods) {
    final methodName = m['name'] as String;
    final returnType = m['returnType'] as String;
    final innerReturn = _getInnerType(returnType);
    final paramType = m['paramType'] as String;
    final isPaginated = m['isPaginated'] as bool? ?? false;

    final useCaseName = '${methodName.pascalCase}UseCase';
    final fileName = '${toSnakeCaseWithAcronyms(methodName, acronyms)}_usecase';

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
          "import '../../../../core/network/models/base_list_request_model.dart';");
      content.writeln(
          "import '../../../../core/network/models/pagination_response_model.dart';");
    }

    if (innerReturn.endsWith('Entity')) {
      content.writeln(
        "import '../entities/${toSnakeCaseWithAcronyms(innerReturn, acronyms)}.dart';",
      );
    }

    final innerParam = _getInnerType(paramType);
    if (innerParam.endsWith('Entity') || innerParam.endsWith('Params')) {
      content.writeln(
        "import '../entities/${toSnakeCaseWithAcronyms(innerParam, acronyms)}.dart';",
      );
    }

    content.writeln();
    content.writeln('@injectable');

    String ret = returnType == 'void' ? 'void' : returnType;
    if (isPaginated && innerReturn.endsWith('Entity')) {
      ret = 'PaginationResponseModel<$innerReturn>';
    }

    String param = paramType == 'void' ? 'NoParams' : paramType;
    if (isPaginated) {
      param = 'BaseListRequestModel';
    }

    content.writeln('class $useCaseName implements UseCase<$ret, $param> {');
    content.writeln('  final ${featureName.pascalCase}Repository repository;');
    content.writeln();
    content.writeln('  $useCaseName(this.repository);');
    content.writeln();
    content.writeln('  @override');
    content.writeln(
      '  Future<Either<Failure, $ret>> call($param params) async {',
    );
    if (paramType == 'void' && !isPaginated) {
      content.writeln('    return repository.$methodName();');
    } else {
      content.writeln('    return repository.$methodName(params);');
    }
    content.writeln('  }');
    content.writeln('}');

    final file = File(
      'lib/features/${toSnakeCaseWithAcronyms(featureName, acronyms)}/domain/usecases/$fileName.dart',
    );
    await file.create(recursive: true);
    await file.writeAsString(content.toString());
  }
}

Future<void> _generateBloc(HookContext context, List<String> acronyms) async {
  context.logger.info('Generating Presentation Layer...');

  final featureName = context.vars['name'] as String;
  final methods = context.vars['methods'] as List<dynamic>? ?? [];

  context.vars['feature_name'] = featureName;
  context.vars['is_bloc'] = context.vars['type'] == 'bloc';
  context.vars['is_cubit'] = context.vars['type'] != 'bloc';

  // Generate handlers for bloc/cubit from methods
  // Note: nedo_bloc_generic expects 'handlers'.
  // We must construct 'handlers' from 'methods' similar to how nedo_bloc_generic's pre_gen does it.
  // However, nedo_bloc_generic's pre_gen does interactive prompting for handlers!
  // Here we have 'methods'. We should map 'methods' to 'handlers'.

  final handlers = <Map<String, dynamic>>[];
  final imports = <String>{};

  for (final method in methods) {
    final rawName = method['name'] as String;
    final returnType = method['returnType'] as String;
    final paramType = method['paramType'] as String;
    final pascalName = rawName.pascalCase;
    final camelName = rawName.camelCase;
    final isPaginated = method['isPaginated'] as bool? ?? false;

    // Map types to imports if necessary (similar logic to nedo_bloc_generic pre_gen)
    // But here we know where they come from (our generation).

    // Re-construct imports logic briefly or assume standard locations?
    // Let's rely on standard locations.

    imports.add(
        "import '../../domain/usecases/${toSnakeCaseWithAcronyms(rawName, acronyms)}_usecase.dart';");

    // Check params/return for Entity import
    if (paramType != 'void' && !['String', 'int', 'bool'].contains(paramType)) {
      final innerParam = _getInnerType(paramType);
      if (innerParam.endsWith('Entity')) {
        imports.add(
            "import '../../domain/entities/${toSnakeCaseWithAcronyms(innerParam, acronyms)}.dart';");
      }
    }
    if (returnType != 'void' &&
        !['String', 'int', 'bool'].contains(returnType)) {
      final innerReturn = _getInnerType(returnType);
      if (innerReturn.endsWith('Entity')) {
        imports.add(
            "import '../../domain/entities/${toSnakeCaseWithAcronyms(innerReturn, acronyms)}.dart';");
      }
    }

    if (isPaginated) {
      imports.add(
          "import '../../../../core/network/models/base_list_request_model.dart';");
      imports.add(
          "import '../../../../core/network/models/pagination_response_model.dart';");
    }

    final innerReturn = _getInnerType(returnType);
    final mappedReturnType =
        isPaginated ? 'PaginationResponseModel<$innerReturn>' : returnType;
    final mappedParamType = isPaginated ? 'BaseListRequestModel' : paramType;

    handlers.add({
      'name': rawName,
      'pascalName': pascalName,
      'eventName': '${pascalName}Requested',
      'stateSuccess': '${pascalName}Success',
      'stateFailure':
          '${featureName.pascalCase}Error', // Fixed from '${pascalName}Failure' to match standard pattern
      'useCaseName': '${pascalName}UseCase',
      'useCaseVar': '_${camelName}UseCase',
      'hasParams': isPaginated ? true : paramType != 'void',
      'paramType': mappedParamType,
      'isVoidReturn': returnType == 'void',
      'returnType': mappedReturnType,
      // Transformer? Default null.
      'statePattern': 'standard', // Defaulting to standard for auto-generated
    });
  }

  context.vars['handlers'] = handlers;
  // Merge existing imports?
  context.vars['imports'] = imports.toList();

  await bloc_post_gen.run(context);
}

class _NameProvider {
  final Map<String, String> _originalToModel = {};
  final Map<String, String> _originalToEntity = {};

  _NameProvider(List models) {
    for (final m in models) {
      final originalName = m['name'] as String;
      _originalToModel[originalName] = _getModelName(originalName);
      _originalToEntity[originalName] = _getEntityName(originalName);
    }
  }

  String getModelName(String original) =>
      _originalToModel[original] ?? original;
  String getEntityName(String original) =>
      _originalToEntity[original] ?? original;

  String _getModelName(String original) {
    if (original.endsWith('DTO')) {
      return original.replaceAll('DTO', 'Model');
    } else if (original.endsWith('Data')) {
      return original.replaceAll('Data', 'Model');
    } else if (original.endsWith('Request')) {
      return '${original}Model';
    }
    return '${original}Model';
  }

  String _getEntityName(String original) {
    if (original.endsWith('DTO')) {
      return original.replaceAll('DTO', 'Entity');
    } else if (original.endsWith('Data')) {
      return original.replaceAll('Data', 'Entity');
    } else if (original.endsWith('Request')) {
      return original.replaceAll('Request', 'Params');
    }
    return '${original}Entity';
  }
}
