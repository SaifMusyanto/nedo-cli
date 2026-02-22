import 'package:mason/mason.dart';

import '../helper/type_mapper.dart';

Map<String, dynamic> parseField(
  String propName,
  Map<String, dynamic> propData,
  bool isHardRequired,
  Set<String> processed,
  List<String> queue,
  Logger logger,
) {
  bool isCustom = false;
  bool isList = false;
  String dartType = 'dynamic';
  String innerType = 'dynamic';

  if (propData.containsKey(r'$ref')) {
    final refName = TypeMapper.getRefName(propData[r'$ref']);
    dartType = refName;
    isCustom = true;
    innerType = refName;
    _addToQueue(refName, processed, queue, logger);
  } else if (propData['type'] == 'array') {
    isList = true;
    final items = propData['items'] as Map<String, dynamic>?;

    if (items != null) {
      if (items.containsKey(r'$ref')) {
        final refName = TypeMapper.getRefName(items[r'$ref']);
        innerType = refName;
        isCustom = true;
        _addToQueue(refName, processed, queue, logger);
      } else {
        innerType = TypeMapper.mapPrimitiveType(
            items['type'] as String?, items['format'] as String?);
      }
    }
    dartType = 'List<$innerType>';
  } else {
    dartType = TypeMapper.mapPrimitiveType(
        propData['type'] as String?, propData['format'] as String?);
    innerType = dartType;
  }

  // Nullability logic
  bool isNullable = !isHardRequired;
  if (isNullable) {
    isNullable = (propData['nullable'] == true);
  }
  if (propData.containsKey(r'$ref')) {
    isNullable = true;
  }
  if (isNullable && dartType != 'dynamic') {
    dartType += '?';
  }

  final isDateTime = (innerType == 'DateTime');

  return {
    'originalName': propName,
    'name': propName.camelCase,
    'type': dartType,
    'innerType': innerType,
    'isRequired': !isNullable,
    'isCustom': isCustom,
    'isList': isList,
    'isDateTime': isDateTime,
  };
}

void _addToQueue(
    String name, Set<String> processed, List<String> queue, Logger logger) {
  const blackList = ['Value', 'Any', 'ListValue', 'NullValue'];
  if (blackList.contains(name)) {
    logger.info('Skipping $name because it is a protobuf type');
    return;
  }

  if (!processed.contains(name) && !queue.contains(name)) {
    queue.add(name);
  }
}
