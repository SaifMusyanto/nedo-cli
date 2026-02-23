import 'dart:io';
import 'package:mason/mason.dart';
import '../../nedo_model/hooks/post_gen.dart' as model_post_gen;
import '../../nedo_bloc_generic/hooks/post_gen.dart' as bloc_post_gen;
import '../../../shared/helper/snake_case_with_acronyms.dart';

import 'src/post_gen/helper/name_provider.dart';
import 'src/post_gen/generator/base/feature_generator.dart';
import 'src/post_gen/generator/implement/repository_interface_generator.dart';
import 'src/post_gen/generator/implement/repository_implementation_generator.dart';
import 'src/post_gen/generator/implement/remote_provider_interface_generator.dart';
import 'src/post_gen/generator/implement/remote_provider_implementation_generator.dart';
import 'src/post_gen/generator/implement/usecases_generator.dart';

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
  final nameProvider = NameProvider(models);

  try {
    final generators = <FeatureGenerator>[
      RepositoryInterfaceGenerator(),
      UsecasesGenerator(),
      RepositoryImplementationGenerator(),
      RemoteProviderInterfaceGenerator(),
      RemoteProviderImplementationGenerator(),
    ];

    for (final generator in generators) {
      await generator.generate(
        featureName: featureName,
        methods: methods,
        names: nameProvider,
        acronyms: acronyms,
      );
    }

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

Future<void> _generateBloc(HookContext context, List<String> acronyms) async {
  context.logger.info('Generating Presentation Layer...');

  final featureName = context.vars['name'] as String;
  final methods = context.vars['methods'] as List<dynamic>? ?? [];

  context.vars['feature_name'] = featureName;
  context.vars['is_bloc'] = context.vars['type'] == 'bloc';
  context.vars['is_cubit'] = context.vars['type'] != 'bloc';

  final handlers = <Map<String, dynamic>>[];
  final imports = <String>{};

  // Note: we instantiate a throwaway NameProvider here just for helper methods,
  // or use the static-like functionality we extracted.
  final nameProvider = NameProvider([]);

  for (final method in methods) {
    final rawName = method['name'] as String;
    final returnType = method['returnType'] as String;
    final paramType = method['paramType'] as String;
    final pascalName = rawName.pascalCase;
    final camelName = rawName.camelCase;
    final isPaginated = method['isPaginated'] as bool? ?? false;

    imports.add(
        "import '../../domain/usecases/${toSnakeCaseWithAcronyms(rawName, acronyms)}_usecase.dart';");

    if (paramType != 'void' && !['String', 'int', 'bool'].contains(paramType)) {
      final innerParam = nameProvider.getInnerType(paramType);
      if (innerParam.endsWith('Entity')) {
        imports.add(
            "import '../../domain/entities/${toSnakeCaseWithAcronyms(innerParam, acronyms)}.dart';");
      }
    }
    if (returnType != 'void' &&
        !['String', 'int', 'bool'].contains(returnType)) {
      final innerReturn = nameProvider.getInnerType(returnType);
      if (innerReturn.endsWith('Entity')) {
        imports.add(
            "import '../../domain/entities/${toSnakeCaseWithAcronyms(innerReturn, acronyms)}.dart';");
      }
    }

    if (isPaginated) {
      imports.add(
          "import '../../../../core/services/network_service/models/base_list_request_model.dart';");
      imports.add(
          "import '../../../../core/services/network_service/models/pagination_response_model.dart';");
    }

    final innerReturn = nameProvider.getInnerType(returnType);
    final mappedReturnType =
        isPaginated ? 'PaginationResponseModel<$innerReturn>' : returnType;
    final mappedParamType = isPaginated ? 'BaseListRequestModel' : paramType;

    handlers.add({
      'name': rawName,
      'pascalName': pascalName,
      'eventName': '${pascalName}Requested',
      'stateSuccess': '${pascalName}Success',
      'stateFailure': '${featureName.pascalCase}Error',
      'useCaseName': '${pascalName}UseCase',
      'useCaseVar': '_${camelName}UseCase',
      'hasParams': isPaginated ? true : paramType != 'void',
      'paramType': mappedParamType,
      'isVoidReturn': returnType == 'void',
      'returnType': mappedReturnType,
      'statePattern': 'standard', // Defaulting to standard for auto-generated
    });
  }

  context.vars['handlers'] = handlers;
  context.vars['imports'] = imports.toList();

  await bloc_post_gen.run(context);
}
