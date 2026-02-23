import 'dart:io';
import 'package:mason/mason.dart';
import '../../../shared/helper/snake_case_with_acronyms.dart';

import 'src/post_gen/generator/implement/state_generator.dart';
import 'src/post_gen/generator/implement/event_generator.dart';
import 'src/post_gen/generator/implement/bloc_class_generator.dart';
import 'src/post_gen/generator/implement/cubit_generator.dart';

Future<void> run(HookContext context) async {
  final featureName = context.vars['feature_name'] as String;
  final isBloc = context.vars['is_bloc'] as bool;
  final handlers = context.vars['handlers'] as List<dynamic>;
  final acronyms = (context.vars['acronyms'] as List?)?.cast<String>() ?? [];

  final featureSnake = toSnakeCaseWithAcronyms(featureName, acronyms);
  final blocDir = Directory(
    'lib/features/$featureSnake/presentation/bloc',
  );
  if (!blocDir.existsSync()) {
    await blocDir.create(recursive: true);
  }

  final stateGen = StateGenerator();
  await stateGen.generate(
    context: context,
    featureName: featureName,
    handlers: handlers,
    dir: blocDir,
    acronyms: acronyms,
  );

  if (isBloc) {
    final eventGen = EventGenerator();
    await eventGen.generate(
      context: context,
      featureName: featureName,
      handlers: handlers,
      dir: blocDir,
      acronyms: acronyms,
    );

    final blocClassGen = BlocClassGenerator();
    await blocClassGen.generate(
      context: context,
      featureName: featureName,
      handlers: handlers,
      dir: blocDir,
      acronyms: acronyms,
    );
  } else {
    final cubitGen = CubitGenerator();
    await cubitGen.generate(
      context: context,
      featureName: featureName,
      handlers: handlers,
      dir: blocDir,
      acronyms: acronyms,
    );
  }
}
