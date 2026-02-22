import 'package:mason/mason.dart';
import 'src/post_gen/definition/model_definition.dart';
import 'src/post_gen/generator/base/component_generator.dart';
import 'src/post_gen/generator/base_models_generator.dart';
import 'src/post_gen/generator/implement/data_mapper_generator.dart';
import 'src/post_gen/generator/implement/data_model_generator.dart';
import 'src/post_gen/generator/implement/domain_entity_generator.dart';
import 'src/post_gen/helper/type_name_resolver.dart';

Future<void> run(HookContext context) async {
  final progress =
      context.logger.progress('Generating clean architecture layers...');

  try {
    final featureName = context.vars['feature_name'] as String;
    final acronyms = (context.vars['acronyms'] as List?)?.cast<String>() ?? [];
    final rawModels = context.vars['models'] as List;
    final models =
        rawModels.map((m) => ModelDefinition.fromMap(m as Map)).toList();

    final nameResolver = TypeNameResolver(models);
    final generators = <ComponentGenerator>[
      DataModelGenerator(),
      DomainEntityGenerator(),
      MapperGenerator(),
    ];
    for (final model in models) {
      for (final generator in generators) {
        await generator.generate(
          model: model,
          nameResolver: nameResolver,
          featureName: featureName,
          acronyms: acronyms,
        );
      }
    }

    await BaseModelsGenerator.generate();

    progress.complete(
        'Generated ${models.length} components (Model, Entity, Mapper).');
  } catch (e, stackTrace) {
    progress.fail('Failed to generate components: $e');
    context.logger.err(stackTrace.toString());
  }
}
