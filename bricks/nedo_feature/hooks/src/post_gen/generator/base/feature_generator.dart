import 'dart:io';
import '../../helper/name_provider.dart';

abstract class FeatureGenerator {
  Future<void> generate({
    required String featureName,
    required List<dynamic> methods,
    required NameProvider names,
    required List<String> acronyms,
  }) async {
    final content = buildContent(featureName, methods, names, acronyms);
    final fileName = getFileName(featureName, methods, names, acronyms);
    final directory = getDirectory(featureName, acronyms);

    final file = File('$directory/$fileName.dart');
    if (!file.parent.existsSync()) {
      await file.parent.create(recursive: true);
    }
    await file.writeAsString(content);
  }

  String buildContent(String featureName, List<dynamic> methods,
      NameProvider names, List<String> acronyms);
  String getFileName(String featureName, List<dynamic> methods,
      NameProvider names, List<String> acronyms);
  String getDirectory(String featureName, List<String> acronyms);
}
