// post_gen.dart
import 'dart:io';
import 'package:mason/mason.dart';

Future<void> run(HookContext context) async {
  final models = context.vars['models'] as List;
  final progress =
      context.logger.progress('Generating clean architecture layers...');

  final nameProvider = _NameProvider(models);
  final featureName = context.vars['feature_name'] as String;

  for (final model in models) {
    final modelMap = model as Map<String, dynamic>;

    await _generateDataModel(modelMap, nameProvider, featureName);

    await _generateDomainEntity(modelMap, nameProvider, featureName);

    await _generateMapper(modelMap, nameProvider, featureName);
  }

  progress.complete(
      'Generated ${models.length} components (Model, Entity, Mapper, Validator).');
}

class _NameProvider {
  final Map<String, String> _originalToModel = {};
  final Map<String, String> _originalToEntity = {};

  _NameProvider(List models) {
    for (final m in models) {
      final originalName = m['name'] as String;
      _originalToModel[originalName] = _getModelName(originalName);
      _originalToEntity[originalName] = _getEntityName(originalName);
    }
  }

  String getModelName(String original) =>
      _originalToModel[original] ?? original;
  String getEntityName(String original) =>
      _originalToEntity[original] ?? original;

  String _getModelName(String original) {
    if (original.endsWith('DTO')) {
      return original.replaceAll('DTO', 'Model');
    } else if (original.endsWith('Data')) {
      return original.replaceAll('Data', 'Model');
    } else if (original.endsWith('Request')) {
      return '${original}Model';
    }
    return '${original}Model';
  }

  String _getEntityName(String original) {
    if (original.endsWith('DTO')) {
      return original.replaceAll('DTO', 'Entity');
    } else if (original.endsWith('Data')) {
      return original.replaceAll('Data', 'Entity');
    } else if (original.endsWith('Request')) {
      return original.replaceAll('Request', 'Params');
    }
    return '${original}Entity';
  }
}

// ... (Functions _generateDataModel, _generateDomainEntity, _generateMapper tetap sama, tidak perlu diubah) ...
// Saya sertakan ulang wrapper function-nya agar copy-paste mudah, tapi logic intinya sama.

Future<void> _generateDataModel(
    Map<String, dynamic> model, _NameProvider names, String featureName) async {
  final originalName = model['name'] as String;
  final className = names.getModelName(originalName);
  final fileName = className.snakeCase;
  final content = _generateModelContent(model, className, names);

  final file = File('lib/features/$featureName/data/models/$fileName.dart');
  await file.create(recursive: true);
  await file.writeAsString(content);
}

Future<void> _generateDomainEntity(
    Map<String, dynamic> model, _NameProvider names, String featureName) async {
  final originalName = model['name'] as String;
  final className = names.getEntityName(originalName);
  final fileName = className.snakeCase;
  final content = _generateEntityContent(model, className, names);

  final file = File('lib/features/$featureName/domain/entities/$fileName.dart');
  await file.create(recursive: true);
  await file.writeAsString(content);
}

Future<void> _generateMapper(
    Map<String, dynamic> model, _NameProvider names, String featureName) async {
  final originalName = model['name'] as String;
  final modelName = names.getModelName(originalName);
  final entityName = names.getEntityName(originalName);
  final fileName = '${modelName.snakeCase}_mapper';
  final content = _generateMapperContent(model, modelName, entityName, names);

  final file = File('lib/features/$featureName/data/mappers/$fileName.dart');
  await file.create(recursive: true);
  await file.writeAsString(content);
}

String _generateModelContent(
    Map<String, dynamic> model, String className, _NameProvider names) {
  // ... (Gunakan kode dari pertanyaan awalmu) ...
  final fields = model['fields'] as List;
  final buffer = StringBuffer();

  buffer.writeln("import 'dart:convert';");

  final customFields = fields.where((f) => f['isCustom'] == true).toList();
  for (final field in customFields) {
    final originalInner = field['innerType'] as String;
    final modelInner = names.getModelName(originalInner);
    buffer.writeln("import '${modelInner.snakeCase}.dart';");
  }
  buffer.writeln();

  buffer.writeln('class $className {');

  // fields
  for (final f in fields) {
    var type = f['type'] as String;
    final fname = f['name'];
    if (f['isCustom'] == true) {
      final originalInner = f['innerType'] as String;
      final modelInner = names.getModelName(originalInner);
      final isList = f['isList'] as bool;
      final isReq = f['isRequired'] as bool;
      type = '${isList ? 'List<$modelInner>' : modelInner}${isReq ? '' : '?'}';
    }
    buffer.writeln('  final $type $fname;');
  }
  buffer.writeln();

  // constructor
  buffer.writeln('  const $className({');
  for (final f in fields) {
    final fname = f['name'];
    final isReq = f['isRequired'] as bool;
    buffer.writeln('    ${isReq ? 'required ' : ''}this.$fname,');
  }
  buffer.writeln('  });');
  buffer.writeln();

  // copyWith
  buffer.writeln('  $className copyWith({');
  for (final f in fields) {
    var type = f['type'] as String;
    if (f['isCustom'] == true) {
      final originalInner = f['innerType'] as String;
      final modelInner = names.getModelName(originalInner);
      final isList = f['isList'] as bool;
      final isReq = f['isRequired'] as bool;
      type = '${isList ? 'List<$modelInner>' : modelInner}${isReq ? '' : '?'}';
    }
    final fname = f['name'];
    final isReq = f['isRequired'] as bool;
    buffer.writeln('    ${!isReq ? type : '$type?'} $fname,');
  }
  buffer.writeln('  }) {');
  buffer.writeln('    return $className(');
  for (final f in fields) {
    final fname = f['name'];
    buffer.writeln('      $fname: $fname ?? this.$fname,');
  }
  buffer.writeln('    );');
  buffer.writeln('  }');
  buffer.writeln();

  // fromMap
  buffer.writeln('  factory $className.fromMap(Map<String, dynamic> map) {');
  buffer.writeln('    return $className(');
  for (final f in fields) {
    final fname = f['name'];
    final originalName = f['originalName'];
    var type = f['type'] as String;
    final innerType = f['innerType'] as String;
    final isList = f['isList'] as bool;
    final isCustom = f['isCustom'] as bool;
    final isRequired = f['isRequired'] as bool;

    final targetInnerType =
        isCustom ? names.getModelName(innerType) : innerType;
    if (isCustom) {
      // Update type for custom
      if (isList) {
        type = 'List<$targetInnerType>';
        if (!isRequired) type += '?';
      } else {
        type = targetInnerType;
        if (!isRequired) type += '?';
      }
    }

    buffer.write('      $fname: ');

    if (isCustom) {
      if (isList) {
        buffer.write(
            "map['$originalName'] != null ? List<$targetInnerType>.from((map['$originalName'] as List<dynamic>).map((x) => $targetInnerType.fromMap(x as Map<String, dynamic>))) : ${isRequired ? '[]' : 'null'},");
      } else {
        buffer.write(
            "map['$originalName'] != null ? $targetInnerType.fromMap(map['$originalName'] as Map<String, dynamic>) : ${isRequired ? "throw Exception('$originalName is required')" : 'null'},");
      }
    } else {
      if (isList) {
        buffer.write(
            "map['$originalName'] != null ? List<$targetInnerType>.from(map['$originalName'] as List<dynamic>) : ${isRequired ? '[]' : 'null'},");
      } else {
        buffer.write("map['$originalName'] as $type,");
      }
    }
    buffer.writeln();
  }
  buffer.writeln('    );');
  buffer.writeln('  }');
  buffer.writeln();

  // toMap
  buffer.writeln('  Map<String, dynamic> toMap() {');
  buffer.writeln('    return <String, dynamic>{');
  for (final f in fields) {
    final fname = f['name'];
    final originalName = f['originalName'];
    final isList = f['isList'] as bool;
    final isCustom = f['isCustom'] as bool;
    final isReq = f['isRequired'] as bool;

    buffer.write("      '$originalName': ");
    if (isCustom) {
      if (isList) {
        buffer
            .write("$fname${isReq ? '' : '?'}.map((x) => x.toMap()).toList(),");
      } else {
        buffer.write("$fname${isReq ? '' : '?'}.toMap(),");
      }
    } else {
      buffer.write("$fname,");
    }
    buffer.writeln();
  }
  buffer.writeln('    };');
  buffer.writeln('  }');
  buffer.writeln();

  // toJson/fromJson
  buffer.writeln(
      '  factory $className.fromJson(String source) => $className.fromMap(json.decode(source) as Map<String, dynamic>);');
  buffer.writeln();
  buffer.writeln('  String toJson() => json.encode(toMap());');
  buffer.writeln('}');
  return buffer.toString();
}

String _generateEntityContent(
    Map<String, dynamic> model, String className, _NameProvider names) {
  // ... (Gunakan kode dari pertanyaan awalmu) ...
  final fields = model['fields'] as List;
  final buffer = StringBuffer();

  // Imports
  buffer.writeln("import 'package:equatable/equatable.dart';");

  final customFields = fields.where((f) => f['isCustom'] == true).toList();
  for (final field in customFields) {
    final originalInner = field['innerType'] as String;
    final entityInner = names.getEntityName(originalInner);
    buffer.writeln("import '${entityInner.snakeCase}.dart';");
  }
  buffer.writeln();

  buffer.writeln('class $className extends Equatable {');

  // Fields
  for (final f in fields) {
    var type = f['type'] as String;
    final fname = f['name'];
    if (f['isCustom'] == true) {
      final originalInner = f['innerType'] as String;
      final entityInner = names.getEntityName(originalInner);
      final isList = f['isList'] as bool;
      final isReq = f['isRequired'] as bool;
      type =
          '${isList ? 'List<$entityInner>' : entityInner}${isReq ? '' : '?'}';
    }
    buffer.writeln('  final $type $fname;');
  }
  buffer.writeln();

  // Constructor
  buffer.writeln('  const $className({');
  for (final f in fields) {
    final fname = f['name'];
    final isReq = f['isRequired'] as bool;
    buffer.writeln('    ${isReq ? 'required ' : ''}this.$fname,');
  }
  buffer.writeln('  });');
  buffer.writeln();

  // copyWith
  buffer.writeln('  $className copyWith({');
  for (final f in fields) {
    var type = f['type'] as String;
    if (f['isCustom'] == true) {
      final originalInner = f['innerType'] as String;
      final entityInner = names.getEntityName(originalInner);
      final isList = f['isList'] as bool;
      final isReq = f['isRequired'] as bool;
      type =
          '${isList ? 'List<$entityInner>' : entityInner}${isReq ? '' : '?'}';
    }
    final fname = f['name'];
    final isReq = f['isRequired'] as bool;
    buffer.writeln('    ${!isReq ? type : '$type?'} $fname,');
  }
  buffer.writeln('  }) {');
  buffer.writeln('    return $className(');
  for (final f in fields) {
    final fname = f['name'];
    buffer.writeln('      $fname: $fname ?? this.$fname,');
  }
  buffer.writeln('    );');
  buffer.writeln('  }');
  buffer.writeln();

  // Props
  buffer.writeln('  @override');
  buffer.writeln('  List<Object?> get props => [');
  for (final f in fields) {
    final fname = f['name'];
    buffer.writeln('    $fname,');
  }
  buffer.writeln('  ];');
  buffer.writeln();
  buffer.writeln('  @override');
  buffer.writeln('  bool get stringify => true;');
  buffer.writeln('}');
  return buffer.toString();
}

String _generateMapperContent(Map<String, dynamic> model, String modelName,
    String entityName, _NameProvider names) {
  // ... (Gunakan kode dari pertanyaan awalmu) ...
  final fields = model['fields'] as List;
  final buffer = StringBuffer();

  // Imports
  buffer
      .writeln("import '../../domain/entities/${entityName.snakeCase}.dart';");
  buffer.writeln("import '../models/${modelName.snakeCase}.dart';");

  // Helper for imports of nested mappers
  final customFields = fields.where((f) => f['isCustom'] == true).toList();
  for (final field in customFields) {
    final originalInner = field['innerType'] as String;
    final innerModel = names.getModelName(originalInner);
    final innerMapper = '${innerModel}Mapper';
    buffer.writeln("import '${innerMapper.snakeCase}.dart';");
  }

  buffer.writeln();

  // Model to Entity
  buffer.writeln('extension ${modelName}ToEntity on $modelName {');
  buffer.writeln('  $entityName toEntity() {');
  buffer.writeln('    return $entityName(');
  for (final f in fields) {
    final fname = f['name'];
    final isCustom = f['isCustom'] as bool;
    final isList = f['isList'] as bool;
    final isReq = f['isRequired'] as bool;

    buffer.write('      $fname: ');
    if (isCustom) {
      if (isList) {
        if (isReq) {
          buffer.write('$fname.map((e) => e.toEntity()).toList(),');
        } else {
          buffer.write('$fname?.map((e) => e.toEntity()).toList(),');
        }
      } else {
        if (isReq) {
          buffer.write('$fname.toEntity(),');
        } else {
          buffer.write('$fname?.toEntity(),');
        }
      }
    } else {
      buffer.write('$fname,');
    }
    buffer.writeln();
  }
  buffer.writeln('    );');
  buffer.writeln('  }');
  buffer.writeln('}');
  buffer.writeln();

  // Entity to Model
  buffer.writeln('extension ${entityName}ToModel on $entityName {');
  buffer.writeln('  $modelName toModel() {');
  buffer.writeln('    return $modelName(');
  for (final f in fields) {
    final fname = f['name'];
    final isCustom = f['isCustom'] as bool;
    final isList = f['isList'] as bool;
    final isReq = f['isRequired'] as bool;

    buffer.write('      $fname: ');
    if (isCustom) {
      if (isList) {
        if (isReq) {
          buffer.write('$fname.map((e) => e.toModel()).toList(),');
        } else {
          buffer.write('$fname?.map((e) => e.toModel()).toList(),');
        }
      } else {
        if (isReq) {
          buffer.write('$fname.toModel(),');
        } else {
          buffer.write('$fname?.toModel(),');
        }
      }
    } else {
      buffer.write('$fname,');
    }
    buffer.writeln();
  }
  buffer.writeln('    );');
  buffer.writeln('  }');
  buffer.writeln('}');

  return buffer.toString();
}
