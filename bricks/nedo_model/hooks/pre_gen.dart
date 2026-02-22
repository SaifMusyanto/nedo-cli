import 'package:mason/mason.dart';
import 'src/pre_gen/schema_processor.dart';
import 'src/pre_gen/schema_fetcher.dart';

Future<void> run(HookContext context) async {
  final processor = SchemaProcessor(
    logger: context.logger,
    source: HttpSchemaSource(),
  );

  await processor.process(context);
}
