import 'package:mason/mason.dart';

import '../../../../../../shared/helper/snake_case_with_acronyms.dart';
import 'parse_field.dart';

Map<String, dynamic> parseModel(
  String modelName,
  Map<String, dynamic> schemaBody,
  Set<String> processed,
  List<String> queue,
  List<String> acronyms,
  Logger logger,
) {
  final properties = schemaBody['properties'] as Map<String, dynamic>? ?? {};
  final requiredFields =
      (schemaBody['required'] as List?)?.map((e) => e.toString()).toSet() ?? {};

  final fields = <Map<String, dynamic>>[];
  bool usesCollection = false;

  for (final entry in properties.entries) {
    final propName = entry.key;
    final propData = entry.value as Map<String, dynamic>;

    final fieldData = parseField(propName, propData,
        requiredFields.contains(propName), processed, queue, logger);

    if (fieldData['isList'] == true) usesCollection = true;
    fields.add(fieldData);
  }

  return {
    'name': modelName,
    'fileName': toSnakeCaseWithAcronyms(modelName, acronyms),
    'fields': fields,
    'usesCollection': usesCollection,
  };
}
