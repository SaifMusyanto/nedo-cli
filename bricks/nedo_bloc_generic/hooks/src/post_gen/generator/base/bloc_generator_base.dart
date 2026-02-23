import 'dart:io';
import 'package:mason/mason.dart';

abstract class BlocGeneratorBase {
  Future<void> generate({
    required HookContext context,
    required String featureName,
    required List<dynamic> handlers,
    required Directory dir,
    required List<String> acronyms,
  }) async {
    final content = buildContent(context, featureName, handlers, dir, acronyms);
    final fileName = getFileName(featureName, acronyms);

    final file = File('${dir.path}/$fileName.dart');
    if (!file.parent.existsSync()) {
      await file.parent.create(recursive: true);
    }
    await file.writeAsString(content);
  }

  String buildContent(
    HookContext context,
    String featureName,
    List<dynamic> handlers,
    Directory dir,
    List<String> acronyms,
  );

  String getFileName(String featureName, List<String> acronyms);

  String getInnerType(String type) {
    if (type.startsWith('List<') && type.endsWith('>')) {
      return type.substring(5, type.length - 1);
    }
    return type;
  }
}
