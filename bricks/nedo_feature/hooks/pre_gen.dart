import 'package:mason/mason.dart';
import 'src/pre_gen/feature_pre_gen_processor.dart';

Future<void> run(HookContext context) async {
  final processor = FeaturePreGenProcessor(logger: context.logger);
  await processor.process(context);
}
