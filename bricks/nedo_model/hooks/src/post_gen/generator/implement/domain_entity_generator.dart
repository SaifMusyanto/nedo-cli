import 'package:mason/mason.dart';

import '../../definition/field_definition.dart';
import '../../definition/model_definition.dart';
import '../../helper/type_name_resolver.dart';
import '../base/component_generator.dart';
import '../../../../../../../shared/helper/snake_case_with_acronyms.dart';

class DomainEntityGenerator extends ComponentGenerator {
  @override
  String getDirectory(String featureName) =>
      'lib/features/${featureName.snakeCase}/domain/entities';

  @override
  String getFileName(ModelDefinition model, TypeNameResolver nameResolver,
          List<String> acronyms) =>
      toSnakeCaseWithAcronyms(
          nameResolver.getEntityName(model.originalName), acronyms);

  @override
  String buildContent(ModelDefinition model, TypeNameResolver nameResolver,
      List<String> acronyms) {
    final className = nameResolver.getEntityName(model.originalName);
    final buffer = StringBuffer();

    // Imports
    buffer.writeln("import 'package:equatable/equatable.dart';");
    final imports = <String>{};
    for (final field in model.customFields) {
      final innerEntity = nameResolver.getEntityName(field.innerType);
      final filename = toSnakeCaseWithAcronyms(innerEntity, acronyms);
      imports.add("import '$filename.dart';");
    }
    for (final import in imports) {
      buffer.writeln(import);
    }
    buffer.writeln();

    // Class Declaration
    buffer.writeln('class $className extends Equatable {');

    // Fields
    for (final field in model.fields) {
      buffer.writeln(
          '  final ${nameResolver.resolveEntityType(field)} ${field.name};');
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

    // CopyWith
    _writeCopyWith(buffer, className, model.fields, nameResolver);

    // Equatable Props
    buffer.writeln('  @override');
    buffer.writeln('  List<Object?> get props => [');
    for (final field in model.fields) {
      buffer.writeln('    ${field.name},');
    }
    buffer.writeln('  ];');

    buffer.writeln();
    buffer.writeln('  @override');
    buffer.writeln('  bool get stringify => true;');
    buffer.writeln('}');

    return buffer.toString();
  }

  void _writeCopyWith(StringBuffer buffer, String className,
      List<FieldDefinition> fields, TypeNameResolver nameResolver) {
    buffer.writeln('  $className copyWith({');
    for (final field in fields) {
      final type = nameResolver.resolveEntityType(field);
      final nullableType = type.endsWith('?') ? type : '$type?';
      buffer.writeln('    $nullableType ${field.name},');
    }
    buffer.writeln('  }) {');
    buffer.writeln('    return $className(');
    for (final field in fields) {
      buffer
          .writeln('      ${field.name}: ${field.name} ?? this.${field.name},');
    }
    buffer.writeln('    );');
    buffer.writeln('  }');
    buffer.writeln();
  }
}
