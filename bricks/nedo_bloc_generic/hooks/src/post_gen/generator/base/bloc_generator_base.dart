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

  String nameProvider(String paramType) {
    final innerParam = getInnerType(paramType);

    String mappedInnerParam = innerParam;
    if (innerParam == 'BasePaginationRequest') {
      return innerParam;
    }

    if (innerParam.endsWith('BaseRequest')) {
      mappedInnerParam =
          '${innerParam.substring(0, innerParam.length - 11)}Params';
    } else if (innerParam.endsWith('Request')) {
      mappedInnerParam =
          '${innerParam.substring(0, innerParam.length - 7)}Params';
    } else if (innerParam.endsWith('Model')) {
      mappedInnerParam =
          '${innerParam.substring(0, innerParam.length - 5)}Params';
    } else if (innerParam.endsWith('QueryParams')) {
      mappedInnerParam = '${innerParam}Entity';
    }

    return mappedInnerParam;
  }
}
