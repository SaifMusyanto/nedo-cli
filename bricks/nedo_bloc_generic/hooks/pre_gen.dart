import 'package:mason/mason.dart';
import 'src/pre_gen/bloc_pre_gen_processor.dart';

Future<void> run(HookContext context) async {
  final processor = BlocPreGenProcessor(logger: context.logger);
  await processor.process(context);
}
