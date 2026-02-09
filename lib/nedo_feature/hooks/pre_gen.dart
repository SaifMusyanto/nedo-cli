import 'package:mason/mason.dart';
import '../../nedo_model/hooks/pre_gen.dart' as model_pre_gen;

Future<void> run(HookContext context) async {
  if (!context.vars.containsKey('name')) {
    context.vars['name'] = context.logger.prompt(
      'What is the feature name? (e.g. Auth, Order)',
    );
  }

  context.vars['feature_name'] = context.vars['name'];

  if (!context.vars.containsKey('schema_url')) {
    context.vars['schema_url'] = context.logger.prompt(
      'Enter URL Swagger Schema? (or path to local json)',
    );
  }

  if (!context.vars.containsKey('target_component')) {
    final target = context.logger.prompt(
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
    context.logger.err('Error running nedo_model pre_gen: $e');
    return;
  }

  final models = context.vars['models'] as List<dynamic>?;

  if (models == null || models.isEmpty) {
    context.logger.warn(
      'No models found. You may not be able to select return types/params from generated models.',
    );
  }

  if (context.vars.containsKey('methods')) {
    final methodsFromConfig = context.vars['methods'];
    if (methodsFromConfig is List && methodsFromConfig.isNotEmpty) {
      context.logger
          .info('✅ Methods configuration found. Skipping interactive prompts.');
      return;
    }
  }

  String getEntityName(String original) {
    if (original.endsWith('DTO')) {
      return original.replaceAll('DTO', 'Entity');
    } else if (original.endsWith('Data')) {
      return original.replaceAll('Data', 'Entity');
    } else if (original.endsWith('Request')) {
      return original.replaceAll('Request', 'Params');
    }
    return '${original}Entity';
  }

  final entityOptions = models?.map((m) {
        final originalName = m['name'] as String;
        return getEntityName(originalName);
      }).toList() ??
      [];

  final methods = <Map<String, dynamic>>[];

  context.logger.info('\n--- Define Feature Capabilities (UseCases) ---');

  bool addingMethods = true;
  while (addingMethods) {
    if (!context.logger.confirm(
      'Add a capability/method? (or press enter to continue)',
      defaultValue: true,
    )) {
      addingMethods = false;
      break;
    }

    final methodName = context.logger.prompt(
      'Method name (e.g. login, getProfile):',
    );

    final returnTypeChoices = [
      'void',
      'String',
      'int',
      'bool',
      ...entityOptions,
    ];
    final returnType = context.logger.chooseOne(
      'Return type (Entity): (default void)',
      choices: returnTypeChoices,
      defaultValue: 'void',
    );

    final paramChoices = ['none (void)', 'String', 'int', ...entityOptions];
    final paramType = context.logger.chooseOne(
      'Parameter type (Params): (default void)',
      choices: paramChoices,
      defaultValue: 'none (void)',
    );

    methods.add({
      'name': methodName,
      'returnType': returnType,
      'paramType': paramType,
      'isFuture': true,
    });
  }

  context.vars['methods'] = methods;
  context.logger.success('Configuration complete! Generating feature...');
}
