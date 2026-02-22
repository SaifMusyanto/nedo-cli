import 'field_definition.dart';

class ModelDefinition {
  final String originalName;
  final List<FieldDefinition> fields;

  const ModelDefinition({
    required this.originalName,
    required this.fields,
  });

  factory ModelDefinition.fromMap(Map map) {
    return ModelDefinition(
      originalName: map['name'] as String,
      fields: (map['fields'] as List)
          .map((f) => FieldDefinition.fromMap(f as Map))
          .toList(),
    );
  }

  List<FieldDefinition> get customFields =>
      fields.where((f) => f.isCustom).toList();
}
