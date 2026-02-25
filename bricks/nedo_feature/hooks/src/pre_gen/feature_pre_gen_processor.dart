import 'package:mason/mason.dart';
import '../../../../nedo_model/hooks/pre_gen.dart' as model_pre_gen;
import '../../../../nedo_bloc_generic/hooks/pre_gen.dart' as bloc_pre_gen;
import '../post_gen/helper/name_provider.dart';
import '../../../../nedo_model/hooks/src/pre_gen/schema_fetcher.dart';
import 'endpoint_parser.dart';

class FeaturePreGenProcessor {
  final Logger logger;

  FeaturePreGenProcessor({required this.logger});

  Future<void> process(HookContext context) async {
    if (!context.vars.containsKey('name')) {
      context.vars['name'] = logger.prompt(
        'What is the feature name? (e.g. Auth, Order)',
      );
    }

    context.vars['feature_name'] = context.vars['name'];

    if (!context.vars.containsKey('schema_url')) {
      context.vars['schema_url'] = logger.prompt(
        'Enter URL Swagger Schema? (or path to local json)',
      );
    }

    if (!context.vars.containsKey('target_component')) {
      final target = logger.prompt(
        'Name of schemas to generate (comma separated). Leave empty for all:',
      );
      if (target.isNotEmpty) {
        context.vars['target_component'] =
            target.split(',').map((e) => e.trim()).toList();
      } else {
        context.vars['target_component'] = [];
      }
    }

    // NEW: Check for endpoints string
    List<String> endpointsList = [];
    if (context.vars.containsKey('endpoints')) {
      final endpointsVar = context.vars['endpoints'];
      if (endpointsVar is String) {
        if (endpointsVar.isNotEmpty) {
          endpointsList = endpointsVar.split(',').map((e) => e.trim()).toList();
        }
      } else if (endpointsVar is List) {
        endpointsList = endpointsVar.map((e) => e.toString().trim()).toList();
      }
    } else {
      final endpointsInput = logger.prompt(
        'Endpoints to parse (comma separated). Leave empty to define methods manually:',
      );
      if (endpointsInput.isNotEmpty) {
        endpointsList = endpointsInput.split(',').map((e) => e.trim()).toList();
      }
    }

    if (endpointsList.isNotEmpty) {
      final schemaUrl = context.vars['schema_url'] as String;

      try {
        final fetcher = HttpSchemaSource();
        final json = await fetcher.fetch(schemaUrl, logger);
        final parser = EndpointParser(logger: logger);
        parser.parseEndpoints(endpointsList, json, context);
      } catch (e) {
        logger.err('Failed to parse endpoints from schema: $e');
      }
    }

    try {
      await model_pre_gen.run(context);
    } catch (e) {
      logger.err('Error running nedo_model pre_gen: $e');
      return;
    }

    final models = context.vars['models'] as List<dynamic>?;

    if (models == null || models.isEmpty) {
      logger.warn(
        'No models found. You may not be able to select return types/params from generated models.',
      );
    }

    if (context.vars.containsKey('methods') &&
        context.vars['generated_by_endpoints'] != true) {
      final methodsFromConfig = context.vars['methods'];
      if (methodsFromConfig is List && methodsFromConfig.isNotEmpty) {
        logger.info(
            '✅ Methods configuration found. Skipping interactive prompts.');
        return;
      }
    }

    // Using NameProvider instance for entity names
    final nameProvider = NameProvider(models ?? []);

    final entityOptions = models?.map((m) {
          final originalName = m['name'] as String;
          return nameProvider.getEntityName(originalName);
        }).toList() ??
        [];

    final methods = <Map<String, dynamic>>[];

    logger.info('\n--- Define Feature Capabilities (UseCases) ---');

    bool addingMethods = true;
    if (context.vars.containsKey('methods') &&
        (context.vars['methods'] as List).isNotEmpty) {
      addingMethods = false;
      final parsedMethods =
          (context.vars['methods'] as List).cast<Map<String, dynamic>>();
      for (var m in parsedMethods) {
        final rType = m['returnType'] as String;
        if (rType != 'void' &&
            !['String', 'int', 'bool', 'double'].contains(rType)) {
          if (rType.startsWith('List<')) {
            final inner = nameProvider.getInnerType(rType);
            m['returnType'] = 'List<${nameProvider.getEntityName(inner)}>';
          } else {
            m['returnType'] = nameProvider.getEntityName(rType);
          }
        }

        final pType = m['paramType'] as String;
        if (pType != 'void' &&
            !['String', 'int', 'bool', 'double'].contains(pType)) {
          m['paramType'] = nameProvider.getEntityName(pType);
        }
      }
      methods.addAll(parsedMethods);
    }
    while (addingMethods) {
      if (!logger.confirm(
        'Add a capability/method? (or press enter to continue)',
        defaultValue: true,
      )) {
        addingMethods = false;
        break;
      }

      final methodName = logger.prompt(
        'Method name (e.g. login, getProfile):',
      );

      final returnTypeChoices = [
        'void',
        'String',
        'int',
        'bool',
        ...entityOptions,
      ];
      final returnType = logger.chooseOne(
        'Return type (Entity): (default void)',
        choices: returnTypeChoices,
        defaultValue: 'void',
      );

      final paramChoices = ['void', 'String', 'int', ...entityOptions];
      final paramType = logger.chooseOne(
        'Parameter type (Params): (default void)',
        choices: paramChoices,
        defaultValue: 'void',
      );

      final isPaginated = logger.confirm(
        'Is this a paginated/list request?',
        defaultValue: false,
      );

      methods.add({
        'name': methodName,
        'returnType': returnType,
        'paramType': paramType,
        'isPaginated': isPaginated,
        'isFuture': true,
      });
    }

    context.vars['methods'] = methods;

    try {
      logger.info('\n--- Presentation Layer Config ---');
      await bloc_pre_gen.run(context);
    } catch (e) {
      logger.err('Error running nedo_bloc_generic pre_gen: $e');
      return;
    }

    logger.success('Configuration complete! Generating feature...');
  }
}
