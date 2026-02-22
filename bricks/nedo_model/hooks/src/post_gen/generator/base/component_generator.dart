import 'dart:io';

import '../../definition/model_definition.dart';
import '../../helper/type_name_resolver.dart';

abstract class ComponentGenerator {
  Future<void> generate({
    required ModelDefinition model,
    required TypeNameResolver nameResolver,
    required String featureName,
    required List<String> acronyms,
  }) async {
    final content = buildContent(model, nameResolver, acronyms);
    final fileName = getFileName(model, nameResolver, acronyms);
    final directory = getDirectory(featureName);

    final file = File('$directory/$fileName.dart');
    if (!file.parent.existsSync()) {
      await file.parent.create(recursive: true);
    }
    await file.writeAsString(content);
  }

  String buildContent(ModelDefinition model, TypeNameResolver nameResolver,
      List<String> acronyms);
  String getFileName(ModelDefinition model, TypeNameResolver nameResolver,
      List<String> acronyms);
  String getDirectory(String featureName);
}
