import 'package:mason/mason.dart';
import '../../../../nedo_model/hooks/pre_gen.dart' as model_pre_gen;
import '../../../../nedo_bloc_generic/hooks/pre_gen.dart' as bloc_pre_gen;
import '../post_gen/helper/name_provider.dart';

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

    if (context.vars.containsKey('methods')) {
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
