import 'dart:io';
import 'package:mason/mason.dart';
import '../../nedo_model/hooks/post_gen.dart' as model_post_gen;

Future<void> run(HookContext context) async {
  final featureName = context.vars['name'] as String;
  final methods = context.vars['methods'] as List<dynamic>? ?? [];

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
    await _generateRepositoryInterface(featureName, methods, nameProvider);
    await _generateUseCases(featureName, methods, nameProvider);

    // Data Layer
    await _generateRepositoryImplementation(featureName, methods, nameProvider);
    await _generateRemoteProviderInterface(featureName, methods, nameProvider);
    await _generateRemoteProviderImplementation(
      featureName,
      methods,
      nameProvider,
    );

    featureProgress.complete('Feature $featureName generated successfully!');
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
) async {
  final className = '${featureName.pascalCase}Repository';
  final fileName = '${featureName.snakeCase}_repository';
  final content = StringBuffer();

  content.writeln("import 'package:fpdart/fpdart.dart';");
  content.writeln("import '../../../../core/error/failures.dart';");

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
      "import '../entities/${entity.snakeCase}.dart';",
    );
  }

  final usedParams = <String>{};
  for (final m in methods) {
    final param = m['paramType'] as String;
    final innerParam = _getInnerType(param);
    if (innerParam != 'none (void)' &&
        !['String', 'int', 'bool', 'double'].contains(innerParam)) {
      usedParams.add(innerParam);
    }
  }

  for (final param in usedParams) {
    if (param.endsWith('Model')) {
      content.writeln(
        "import '../data/models/${param.snakeCase}.dart';",
      );
    } else if (param.endsWith('Entity')) {
      content.writeln(
        "import '../entities/${param.snakeCase}.dart';",
      );
    } else if (param.endsWith('Params')) {
      content.writeln(
        "import '../entities/${param.snakeCase}.dart';",
      );
    }
  }

  content.writeln();

  content.writeln('abstract class $className {');
  for (final m in methods) {
    final methodName = m['name'] as String;
    final returnType = m['returnType'] as String;
    final paramType = m['paramType'] as String;

    String ret = returnType == 'void' ? 'void' : returnType;
    String params = '';

    if (paramType != 'none (void)') {
      params = '$paramType params';
    }

    content.writeln('  Future<Either<Failure, $ret>> $methodName($params);');
  }
  content.writeln('}');

  final file = File(
    'lib/features/${featureName.snakeCase}/domain/repositories/$fileName.dart',
  );
  await file.create(recursive: true);
  await file.writeAsString(content.toString());
}

Future<void> _generateRepositoryImplementation(
  String featureName,
  List<dynamic> methods,
  _NameProvider names,
) async {
  final repoName = '${featureName.pascalCase}Repository';
  final repoImplName = '${repoName}Impl';
  final providerName = 'IRemote${featureName.pascalCase}Provider';
  final remoteVar = 'remote${featureName.pascalCase}Provider';

  final content = StringBuffer();
  final featureSnake = featureName.snakeCase;

  content.writeln("import 'package:fpdart/fpdart.dart';");
  content.writeln("import '../../../../core/error/failures.dart';");
  content.writeln("import '../../../../core/utils/repository_helper.dart';");
  content.writeln(
    "import '../../domain/repositories/${featureSnake}_repository.dart';",
  );
  content.writeln(
    "import '../providers/remote/interfaces/i_remote_${featureSnake}_provider.dart';",
  );

  final usedMappers = <String>{};
  for (final m in methods) {
    final returnType = m['returnType'] as String;
    final innerType = _getInnerType(returnType);
    if (innerType.endsWith('Entity') || innerType.endsWith('Params')) {
      content.writeln(
        "import '../../domain/entities/${innerType.snakeCase}.dart';",
      );
      String modelName;
      if (innerType.endsWith('Entity')) {
        modelName = innerType.replaceAll('Entity', 'Model');
      } else {
        modelName = innerType.replaceAll('Params', 'Model');
      }
      usedMappers.add('${modelName.snakeCase}_mapper');
    }
  }

  for (final mapper in usedMappers) {
    content.writeln("import '../mappers/$mapper.dart';");
  }

  final usedParams = <String>{};
  for (final m in methods) {
    final param = m['paramType'] as String;
    final innerParam = _getInnerType(param);

    if (innerParam != 'none (void)' &&
        !['String', 'int', 'bool', 'double'].contains(innerParam)) {
      usedParams.add(innerParam);
      if (innerParam.endsWith('Model')) {
        content.writeln(
          "import '../models/${innerParam.snakeCase}.dart';",
        );
      } else if (innerParam.endsWith('Entity') ||
          innerParam.endsWith('Params')) {
        content.writeln(
          "import '../../domain/entities/${innerParam.snakeCase}.dart';",
        );
      }
    }
  }

  content.writeln();

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
    final paramType = m['paramType'] as String;

    String ret = returnType == 'void' ? 'void' : returnType;
    String params = '';
    String callParams = '';

    if (paramType != 'none (void)') {
      params = '$paramType params';
      callParams = 'params';
    }

    content.writeln('  @override');
    content.writeln(
      '  Future<Either<Failure, $ret>> $methodName($params) async {',
    );
    content.writeln('    return safeCall(() async {');

    if (returnType == 'void') {
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
    'lib/features/${featureName.snakeCase}/data/repositories/${featureName.snakeCase}_repository_impl.dart',
  );
  await file.create(recursive: true);
  await file.writeAsString(content.toString());
}

Future<void> _generateRemoteProviderInterface(
  String featureName,
  List<dynamic> methods,
  _NameProvider names,
) async {
  final interfaceName = 'IRemote${featureName.pascalCase}Provider';
  final fileName = 'i_remote_${featureName.snakeCase}_provider';
  final content = StringBuffer();

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
      "import '../../../models/${model.snakeCase}.dart';",
    );
  }

  for (final entity in usedEntities) {
    content.writeln(
      "import '../../../../domain/entities/${entity.snakeCase}.dart';",
    );
  }

  content.writeln();
  content.writeln('abstract class $interfaceName {');
  for (final m in methods) {
    final methodName = m['name'] as String;
    final returnType = m['returnType'] as String;
    final innerReturn = _getInnerType(returnType);
    final paramType = m['paramType'] as String;

    String baseType = innerReturn;
    if (innerReturn.endsWith('Entity')) {
      baseType = innerReturn.replaceAll('Entity', 'Model');
    }

    String ret = baseType;
    if (returnType.startsWith('List<')) {
      ret = 'List<$baseType>';
    }

    String params = '';
    if (paramType != 'none (void)') {
      params = '$paramType params';
    }

    content.writeln('  Future<$ret> $methodName($params);');
  }
  content.writeln('}');

  final file = File(
    'lib/features/${featureName.snakeCase}/data/providers/remote/interfaces/$fileName.dart',
  );
  await file.create(recursive: true);
  await file.writeAsString(content.toString());
}

Future<void> _generateRemoteProviderImplementation(
  String featureName,
  List<dynamic> methods,
  _NameProvider names,
) async {
  final implName = 'Remote${featureName.pascalCase}Provider';
  final interfaceName = 'IRemote${featureName.pascalCase}Provider';
  final fileName = 'remote_${featureName.snakeCase}_provider';
  final content = StringBuffer();

  content.writeln("import 'package:injectable/injectable.dart';");
  content.writeln("import '../../../../../../core/network/dio_client.dart';");
  content.writeln(
    "import '../../../../../../core/services/secure_storage/secure_storage_service.dart';",
  );
  content.writeln(
    "import '../interfaces/i_remote_${featureName.snakeCase}_provider.dart';",
  );

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
      "import '../../../models/${model.snakeCase}.dart';",
    );
  }

  for (final entity in usedEntities) {
    content.writeln(
      "import '../../../../domain/entities/${entity.snakeCase}.dart';",
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

    String baseType = innerReturn;
    if (innerReturn.endsWith('Entity')) {
      baseType = innerReturn.replaceAll('Entity', 'Model');
    }

    String ret = baseType;
    if (returnType.startsWith('List<')) {
      ret = 'List<$baseType>';
    }

    String params = '';
    if (paramType != 'none (void)') {
      params = '$paramType params';
    }

    content.writeln('  @override');
    content.writeln('  Future<$ret> $methodName($params) async {');
    content.writeln('    // TODO: Implement $methodName');

    if (paramType.endsWith('Model')) {
      content.writeln('    final data = params.toMap();');
    }

    if (ret == 'void') {
      content.writeln(
        '    // await dioClient.post(EndpointConstant.$methodName, ...);',
      );
    } else {
      content.writeln('    throw UnimplementedError();');
    }

    content.writeln('  }');
    content.writeln();
  }
  content.writeln('}');

  final file = File(
    'lib/features/${featureName.snakeCase}/data/providers/remote/implementations/$fileName.dart',
  );
  await file.create(recursive: true);
  await file.writeAsString(content.toString());
}

Future<void> _generateUseCases(
  String featureName,
  List<dynamic> methods,
  _NameProvider names,
) async {
  for (final m in methods) {
    final methodName = m['name'] as String;
    final returnType = m['returnType'] as String;
    final paramType = m['paramType'] as String;

    final useCaseName = '${methodName.pascalCase}UseCase';
    final fileName = '${methodName.snakeCase}_usecase';

    final content = StringBuffer();

    content.writeln("import 'package:fpdart/fpdart.dart';");
    content.writeln("import 'package:injectable/injectable.dart';");
    content.writeln("import '../../../../core/error/failures.dart';");
    content.writeln(
      "import '../../../../core/usecase/usecase.dart';",
    );
    content.writeln(
      "import '../repositories/${featureName.snakeCase}_repository.dart';",
    );

    final innerReturn = _getInnerType(returnType);
    if (innerReturn.endsWith('Entity')) {
      content.writeln(
        "import '../entities/${innerReturn.snakeCase}.dart';",
      );
    }

    final innerParam = _getInnerType(paramType);
    if (innerParam.endsWith('Entity') || innerParam.endsWith('Params')) {
      content.writeln(
        "import '../entities/${innerParam.snakeCase}.dart';",
      );
    }

    content.writeln();
    content.writeln('@injectable');

    String ret = returnType == 'void' ? 'void' : returnType;
    String param = paramType == 'none (void)' ? 'NoParams' : paramType;

    content.writeln('class $useCaseName implements UseCase<$ret, $param> {');
    content.writeln('  final ${featureName.pascalCase}Repository repository;');
    content.writeln();
    content.writeln('  $useCaseName(this.repository);');
    content.writeln();
    content.writeln('  @override');
    content.writeln(
      '  Future<Either<Failure, $ret>> call($param params) async {',
    );
    if (paramType == 'none (void)') {
      content.writeln('    return repository.$methodName();');
    } else {
      content.writeln('    return repository.$methodName(params);');
    }
    content.writeln('  }');
    content.writeln('}');

    final file = File(
      'lib/features/${featureName.snakeCase}/domain/usecases/$fileName.dart',
    );
    await file.create(recursive: true);
    await file.writeAsString(content.toString());
  }
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
