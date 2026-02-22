class FieldDefinition {
  final String name;
  final String originalName;
  final String type;
  final String innerType;
  final bool isList;
  final bool isCustom;
  final bool isRequired;
  final bool isDateTime;

  const FieldDefinition({
    required this.name,
    required this.originalName,
    required this.type,
    required this.innerType,
    required this.isList,
    required this.isCustom,
    required this.isRequired,
    required this.isDateTime,
  });

  factory FieldDefinition.fromMap(Map map) {
    return FieldDefinition(
      name: map['name'] as String,
      originalName: (map['originalName'] ?? map['name']) as String,
      type: map['type'] as String,
      innerType: map['innerType'] as String? ?? '',
      isList: map['isList'] as bool? ?? false,
      isCustom: map['isCustom'] as bool? ?? false,
      isRequired: map['isRequired'] as bool? ?? false,
      isDateTime: map['isDateTime'] as bool? ?? false,
    );
  }
}
