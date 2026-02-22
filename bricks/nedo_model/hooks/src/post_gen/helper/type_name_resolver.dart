import '../definition/field_definition.dart';
import '../definition/model_definition.dart';

class TypeNameResolver {
  final Map<String, String> _originalToModel = {};
  final Map<String, String> _originalToEntity = {};

  TypeNameResolver(List<ModelDefinition> models) {
    for (final m in models) {
      _originalToModel[m.originalName] = _generateModelName(m.originalName);
      _originalToEntity[m.originalName] = _generateEntityName(m.originalName);
    }
  }

  String getModelName(String original) =>
      _originalToModel[original] ?? original;
  String getEntityName(String original) =>
      _originalToEntity[original] ?? original;

  String _generateModelName(String original) {
    if (original.endsWith('DTO')) return original.replaceAll('DTO', 'Model');
    if (original.endsWith('Data')) return original.replaceAll('Data', 'Model');
    if (original.endsWith('Request')) return '${original}Model';
    return '${original}Model';
  }

  String _generateEntityName(String original) {
    if (original.endsWith('DTO')) return original.replaceAll('DTO', 'Entity');
    if (original.endsWith('Data')) return original.replaceAll('Data', 'Entity');
    if (original.endsWith('Request')) {
      return '${original}Params';
    }
    return '${original}Entity';
  }

  String resolveModelType(FieldDefinition field) {
    final baseType =
        field.isCustom ? getModelName(field.innerType) : field.innerType;
    return _applyModifiers(baseType, field);
  }

  String resolveEntityType(FieldDefinition field) {
    final baseType =
        field.isCustom ? getEntityName(field.innerType) : field.innerType;
    return _applyModifiers(baseType, field);
  }

  String _applyModifiers(String baseType, FieldDefinition field) {
    final typeWithList = field.isList ? 'List<$baseType>' : baseType;
    if (field.isRequired) return typeWithList;
    return typeWithList.endsWith('?') ? typeWithList : '$typeWithList?';
  }
}
