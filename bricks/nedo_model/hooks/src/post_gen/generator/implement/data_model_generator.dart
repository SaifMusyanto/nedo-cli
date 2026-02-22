import 'package:mason/mason.dart';
import '../../../../../../../shared/helper/snake_case_with_acronyms.dart';
import '../../definition/field_definition.dart';
import '../../definition/model_definition.dart';
import '../../helper/type_name_resolver.dart';
import '../base/component_generator.dart';

class DataModelGenerator extends ComponentGenerator {
  @override
  String getDirectory(String featureName) =>
      'lib/features/${featureName.snakeCase}/data/models';

  @override
  String getFileName(ModelDefinition model, TypeNameResolver nameResolver,
          List<String> acronyms) =>
      toSnakeCaseWithAcronyms(
          nameResolver.getModelName(model.originalName), acronyms);

  @override
  String buildContent(ModelDefinition model, TypeNameResolver nameResolver,
      List<String> acronyms) {
    final className = nameResolver.getModelName(model.originalName);
    final buffer = StringBuffer();

    // Imports
    buffer.writeln("import 'dart:convert';");
    final imports = <String>{};
    for (final field in model.customFields) {
      final innerModel = nameResolver.getModelName(field.innerType);
      final filename = toSnakeCaseWithAcronyms(innerModel, acronyms);
      imports.add("import '$filename.dart';");
    }
    for (final import in imports) {
      buffer.writeln(import);
    }
    buffer.writeln();

    // Class Declaration
    buffer.writeln('class $className {');

    // Fields
    for (final field in model.fields) {
      buffer.writeln(
          '  final ${nameResolver.resolveModelType(field)} ${field.name};');
    }
    buffer.writeln();

    // Constructor
    buffer.writeln('  const $className({');
    for (final field in model.fields) {
      buffer.writeln(
          '    ${field.isRequired ? 'required ' : ''}this.${field.name},');
    }
    buffer.writeln('  });');
    buffer.writeln();

    // FromMap
    _writeFromMap(buffer, className, model.fields, nameResolver);

    // ToMap
    _writeToMap(buffer, model.fields);

    // Json support
    buffer.writeln(
        '  factory $className.fromJson(String source) => $className.fromMap(json.decode(source) as Map<String, dynamic>);');
    buffer.writeln();
    buffer.writeln('  String toJson() => json.encode(toMap());');

    buffer.writeln('}');
    return buffer.toString();
  }

  void _writeFromMap(StringBuffer buffer, String className,
      List<FieldDefinition> fields, TypeNameResolver nameResolver) {
    buffer.writeln('  factory $className.fromMap(Map<String, dynamic> map) {');
    buffer.writeln('    return $className(');

    for (final field in fields) {
      buffer.write('      ${field.name}: ');

      if (field.isCustom) {
        final innerModelName = nameResolver.getModelName(field.innerType);
        _writeCustomFieldDeserialization(
            buffer, field, innerModelName, field.originalName);
      } else if (field.isDateTime) {
        _writeDateTimeFieldDeserialization(buffer, field, field.originalName);
      } else {
        _writePrimitiveFieldDeserialization(buffer, field, field.originalName);
      }
      buffer.writeln();
    }
    buffer.writeln('    );');
    buffer.writeln('  }');
    buffer.writeln();
  }

  void _writeCustomFieldDeserialization(StringBuffer buffer,
      FieldDefinition field, String innerClass, String key) {
    final mapAccess = "map['$key']";
    if (field.isList) {
      final transform =
          "List<$innerClass>.from(($mapAccess as List<dynamic>).map((x) => $innerClass.fromMap(x as Map<String, dynamic>)))";
      final fallback = field.isRequired ? '[]' : 'null';
      buffer.write("$mapAccess != null ? $transform : $fallback,");
    } else {
      final transform =
          "$innerClass.fromMap($mapAccess as Map<String, dynamic>)";
      final fallback =
          field.isRequired ? "throw Exception('$key is required')" : 'null';
      buffer.write("$mapAccess != null ? $transform : $fallback,");
    }
  }

  void _writeDateTimeFieldDeserialization(
      StringBuffer buffer, FieldDefinition field, String key) {
    final mapAccess = "map['$key']";
    if (field.isList) {
      final transform =
          "($mapAccess as List<dynamic>).map((e) => DateTime.tryParse(e as String)).whereType<DateTime>().toList()";
      final fallback = field.isRequired ? '[]' : 'null';
      buffer.write("$mapAccess != null ? $transform : $fallback,");
    } else {
      if (field.isRequired) {
        buffer.write(
            "$mapAccess != null ? DateTime.tryParse($mapAccess as String) ?? DateTime.now() : DateTime.now(),");
      } else {
        buffer.write(
            "$mapAccess != null ? DateTime.tryParse($mapAccess as String) : null,");
      }
    }
  }

  void _writePrimitiveFieldDeserialization(
      StringBuffer buffer, FieldDefinition field, String key) {
    final mapAccess = "map['$key']";
    if (field.isList) {
      final fallback = field.isRequired ? '[]' : 'null';
      if (field.innerType == 'double') {
        buffer.write(
            "$mapAccess != null ? ($mapAccess as List<dynamic>).map((e) => (e as num).toDouble()).toList() : $fallback,");
      } else {
        buffer.write(
            "$mapAccess != null ? List<${field.innerType}>.from($mapAccess as List<dynamic>) : $fallback,");
      }
    } else {
      if (field.type == 'double') {
        buffer.write("($mapAccess as num).toDouble(),");
      } else if (field.type == 'double?') {
        buffer.write("($mapAccess as num?)?.toDouble(),");
      } else {
        buffer.write("$mapAccess as ${field.type},");
      }
    }
  }

  void _writeToMap(StringBuffer buffer, List<FieldDefinition> fields) {
    buffer.writeln('  Map<String, dynamic> toMap() {');
    buffer.writeln('    return <String, dynamic>{');
    for (final field in fields) {
      buffer.write("      '${field.originalName}': ");
      final access = field.name;
      final safeAccess = field.isRequired ? access : '$access?';

      if (field.isCustom) {
        if (field.isList) {
          buffer.write("$safeAccess.map((x) => x.toMap()).toList(),");
        } else {
          buffer.write("$safeAccess.toMap(),");
        }
      } else if (field.isDateTime) {
        if (field.isList) {
          buffer.write("$safeAccess.map((x) => x.toIso8601String()).toList(),");
        } else {
          buffer.write("$safeAccess.toIso8601String(),");
        }
      } else {
        buffer.write("$access,");
      }
      buffer.writeln();
    }
    buffer.writeln('    };');
    buffer.writeln('  }');
    buffer.writeln();
  }
}
