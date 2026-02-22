import 'package:mason/mason.dart';
import '../../../../../../../shared/helper/snake_case_with_acronyms.dart';
import '../../definition/field_definition.dart';
import '../../definition/model_definition.dart';
import '../../helper/type_name_resolver.dart';
import '../base/component_generator.dart';

class MapperGenerator extends ComponentGenerator {
  @override
  String getDirectory(String featureName) =>
      'lib/features/${featureName.snakeCase}/data/mappers';

  @override
  String getFileName(ModelDefinition model, TypeNameResolver nameResolver,
          List<String> acronyms) =>
      '${toSnakeCaseWithAcronyms(nameResolver.getModelName(model.originalName), acronyms)}_mapper';

  @override
  String buildContent(ModelDefinition model, TypeNameResolver nameResolver,
      List<String> acronyms) {
    final modelName = nameResolver.getModelName(model.originalName);
    final entityName = nameResolver.getEntityName(model.originalName);
    final buffer = StringBuffer();

    // Imports
    buffer.writeln(
        "import '../../domain/entities/${toSnakeCaseWithAcronyms(entityName, acronyms)}.dart';");
    buffer.writeln(
        "import '../models/${toSnakeCaseWithAcronyms(modelName, acronyms)}.dart';");

    // Import nested mappers
    final imports = <String>{};
    for (final field in model.customFields) {
      final innerModel = nameResolver.getModelName(field.innerType);
      final mapperName = '${innerModel}Mapper';
      final fileName = toSnakeCaseWithAcronyms(mapperName, acronyms);
      imports.add("import '$fileName.dart';");
    }
    for (final import in imports) {
      buffer.writeln(import);
    }
    buffer.writeln();

    // Model -> Entity
    _writeMapExtension(
        buffer: buffer,
        sourceType: modelName,
        targetType: entityName,
        methodName: 'toEntity',
        isToEntity: true,
        fields: model.fields);

    buffer.writeln();

    // Entity -> Model
    _writeMapExtension(
        buffer: buffer,
        sourceType: entityName,
        targetType: modelName,
        methodName: 'toModel',
        isToEntity: false,
        fields: model.fields);

    return buffer.toString();
  }

  void _writeMapExtension({
    required StringBuffer buffer,
    required String sourceType,
    required String targetType,
    required String methodName,
    required bool isToEntity,
    required List<FieldDefinition> fields,
  }) {
    buffer.writeln(
        'extension ${sourceType}To${isToEntity ? "Entity" : "Model"} on $sourceType {');
    buffer.writeln('  $targetType $methodName() {');
    buffer.writeln('    return $targetType(');

    for (final field in fields) {
      buffer.write('      ${field.name}: ');
      if (field.isCustom) {
        final access = field.name;
        final call = isToEntity ? 'toEntity()' : 'toModel()';

        // Handle Null safety and Lists logic
        if (field.isList) {
          String mapCall = "x.$call"; // simplification
          // We need full map syntax
          mapCall =
              "$access${!field.isRequired ? '?' : ''}.map((e) => e.$call).toList()";
          buffer.write("$mapCall,");
        } else {
          // single object
          if (field.isRequired) {
            buffer.write("$access.$call,");
          } else {
            buffer.write("$access?.$call,");
          }
        }
      } else {
        buffer.write('${field.name},');
      }
      buffer.writeln();
    }

    buffer.writeln('    );');
    buffer.writeln('  }');
    buffer.writeln('}');
  }
}
