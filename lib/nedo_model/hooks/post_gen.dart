// post_gen.dart
import 'dart:io';
import 'package:mason/mason.dart';

Future<void> run(HookContext context) async {
  final models = context.vars['models'] as List;
  final progress =
      context.logger.progress('Generating clean architecture layers...');

  final nameProvider = _NameProvider(models);

  for (final model in models) {
    final modelMap = model as Map<String, dynamic>;

    await _generateDataModel(modelMap, nameProvider);

    await _generateDomainEntity(modelMap, nameProvider);

    await _generateMapper(modelMap, nameProvider);

    // GENERATOR BARU: Validation Schema
    await _generateValidator(modelMap, nameProvider);
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
    Map<String, dynamic> model, _NameProvider names) async {
  final originalName = model['name'] as String;
  final className = names.getModelName(originalName);
  final fileName = className.snakeCase;
  final content = _generateModelContent(model, className, names);

  final file = File('data/models/$fileName.dart');
  await file.create(recursive: true);
  await file.writeAsString(content);
}

Future<void> _generateDomainEntity(
    Map<String, dynamic> model, _NameProvider names) async {
  final originalName = model['name'] as String;
  final className = names.getEntityName(originalName);
  final fileName = className.snakeCase;
  final content = _generateEntityContent(model, className, names);

  final file = File('domain/entities/$fileName.dart');
  await file.create(recursive: true);
  await file.writeAsString(content);
}

Future<void> _generateMapper(
    Map<String, dynamic> model, _NameProvider names) async {
  final originalName = model['name'] as String;
  final modelName = names.getModelName(originalName);
  final entityName = names.getEntityName(originalName);
  final fileName = '${modelName.snakeCase}_mapper';
  final content = _generateMapperContent(model, modelName, entityName, names);

  final file = File('data/mappers/$fileName.dart');
  await file.create(recursive: true);
  await file.writeAsString(content);
}

// ------------------------------------------------------------------
// NEW: VALIDATOR GENERATOR
// ------------------------------------------------------------------

Future<void> _generateValidator(
    Map<String, dynamic> model, _NameProvider names) async {
  final originalName = model['name'] as String;
  final entityName = names.getEntityName(originalName);
  // Naming convention: UserEntity -> UserSchemaValidator
  final validatorName = '${entityName.replaceAll('Entity', '')}SchemaValidator';
  final fileName = validatorName.snakeCase;

  final content =
      _generateValidatorContent(model, validatorName, entityName, names);

  // Menyimpan di folder domain/validators/
  final file = File('domain/validators/$fileName.dart');
  await file.create(recursive: true);
  await file.writeAsString(content);
}

String _generateValidatorContent(Map<String, dynamic> model,
    String validatorName, String entityName, _NameProvider names) {
  final fields = model['fields'] as List;
  final buffer = StringBuffer();

  // 1. Imports
  buffer.writeln("import '../../../../core/utils/validators.dart';");
  buffer.writeln("import '../entities/${entityName.snakeCase}.dart';");

  // Import nested validators
  final customFields = fields.where((f) => f['isCustom'] == true).toList();
  for (final field in customFields) {
    final originalInner = field['innerType'] as String;
    final innerEntityName = names.getEntityName(originalInner);
    final innerValidatorName =
        '${innerEntityName.replaceAll('Entity', '')}SchemaValidator';
    buffer.writeln("import '${innerValidatorName.snakeCase}.dart';");
  }
  buffer.writeln();

  // 2. Class Declaration
  buffer.writeln('class $validatorName {');
  buffer.writeln('  Map<String, String> validate($entityName data) {');
  buffer.writeln('    final errors = <String, String>{};');
  buffer.writeln();

  // 3. Validation Logic
  for (final f in fields) {
    final fname = f['name'];
    final originalName = f['originalName'] as String;
    final lowerName = originalName.toLowerCase(); // Untuk deteksi heuristic
    final isReq = f['isRequired'] as bool;
    final isList = f['isList'] as bool;
    final isCustom = f['isCustom'] as bool;
    final type = f['type'] as String;

    // --- CASE A: CUSTOM OBJECTS (Nested Validation) ---
    // (Logic ini tetap sama seperti sebelumnya karena sudah benar)
    if (isCustom) {
      final originalInner = f['innerType'] as String;
      final innerEntityName = names.getEntityName(originalInner);
      final innerValidator =
          '${innerEntityName.replaceAll('Entity', '')}SchemaValidator';

      if (isList) {
        buffer.writeln('    // Validate List of $innerEntityName');
        if (!isReq) buffer.writeln('    if (data.$fname != null) {');

        buffer.writeln(
            '    for (var i = 0; i < (data.$fname${isReq ? '' : '?'} ?? []).length; i++) {');
        buffer.writeln('      final item = data.$fname${isReq ? '' : '!'}[i];');
        buffer.writeln(
            '      final itemErrors = $innerValidator().validate(item);');
        buffer.writeln('      itemErrors.forEach((key, value) {');
        buffer.writeln("        errors['$originalName.\$i.\$key'] = value;");
        buffer.writeln('      });');
        buffer.writeln('    }');

        if (!isReq) buffer.writeln('    }');
      } else {
        buffer.writeln('    // Validate Nested $innerEntityName');
        if (!isReq) buffer.writeln('    if (data.$fname != null) {');

        buffer.writeln(
            '      final ${fname}Errors = $innerValidator().validate(data.$fname${isReq ? '' : '!'});');
        buffer.writeln('      ${fname}Errors.forEach((key, value) {');
        buffer.writeln("        errors['$originalName.\$key'] = value;");
        buffer.writeln('      });');

        if (!isReq) buffer.writeln('    }');
      }
      buffer.writeln();
      continue;
    }

    // --- CASE B: STRING VALIDATION HEURISTICS ---
    if (type.contains('String')) {
      final valueAccess = isReq ? "data.$fname" : "data.$fname!";
      final nullCheck = isReq ? "" : "data.$fname != null && ";

      // 1. Cek Wajib Diisi (Empty Check)
      if (isReq) {
        buffer.writeln("    if ($valueAccess.trim().isEmpty) {");
        buffer.writeln(
            "      errors['$originalName'] = 'Field ini wajib diisi';");
        buffer.writeln("    }");
      } else {
        // Jika optional tapi diisi string kosong, anggap error (tergantung rule enterprise, biasanya ya)
        buffer.writeln("    if ($nullCheck$valueAccess.trim().isEmpty) {");
        buffer.writeln(
            "      errors['$originalName'] = 'Field tidak boleh kosong jika diisi';");
        buffer.writeln("    }");
      }

      // Pembuka blok validasi lanjutan (hanya jalan jika tidak empty)
      buffer.writeln("    else if ($nullCheck$valueAccess.isNotEmpty) {");

      // 2. EMAIL CHECK
      if (lowerName.contains('email')) {
        buffer.writeln("      if (!Validators.isValidEmail($valueAccess)) {");
        buffer.writeln(
            "        errors['$originalName'] = 'Format email tidak valid';");
        buffer.writeln("      }");
      }

      // 3. PASSWORD CHECK
      else if (lowerName.contains('password') || lowerName.contains('pass')) {
        buffer.writeln(
            "      if (!Validators.isValidPassword($valueAccess, requireSpecialChar: false)) {");
        buffer.writeln(
            "        errors['$originalName'] = 'Password minimal 8 karakter, mengandung huruf besar, kecil, dan angka';");
        buffer.writeln("      }");
      }

      // 4. PHONE/MOBILE CHECK
      else if (lowerName.contains('phone') ||
          lowerName.contains('mobile') ||
          lowerName.contains('tel') ||
          lowerName.contains('wa')) {
        buffer.writeln("      if (!Validators.isValidPhone($valueAccess)) {");
        buffer.writeln(
            "        errors['$originalName'] = 'Nomor telepon tidak valid';");
        buffer.writeln("      }");
      }

      // 5. URL/LINK CHECK
      else if (lowerName.contains('url') ||
          lowerName.contains('link') ||
          lowerName.contains('image') ||
          lowerName.contains('photo') ||
          lowerName.contains('avatar')) {
        buffer.writeln("      if (!Validators.isValidUrl($valueAccess)) {");
        buffer.writeln(
            "        errors['$originalName'] = 'Format URL tidak valid';");
        buffer.writeln("      }");
      }

      buffer.writeln("    }"); // Penutup blok else if
    }

    // --- CASE C: NUMERIC VALIDATION HEURISTICS ---
    if (type == 'int' || type == 'double' || type == 'num') {
      final valueAccess = isReq ? "data.$fname" : "data.$fname!";
      final nullCheck = isReq ? "" : "if (data.$fname != null) ";

      // Validasi angka negatif untuk harga/stok/jumlah
      if (lowerName.contains('price') ||
          lowerName.contains('amount') ||
          lowerName.contains('stock') ||
          lowerName.contains('qty') ||
          lowerName.contains('quantity')) {
        buffer.write("    $nullCheck");
        buffer.writeln("{");
        buffer.writeln("      if ($valueAccess < 0) {");
        buffer.writeln(
            "        errors['$originalName'] = 'Nilai tidak boleh negatif';");
        buffer.writeln("      }");
        buffer.writeln("    }");
      }
    }

    // --- CASE D: LIST CHECK ---
    if (isList) {
      if (isReq) {
        buffer.writeln("    if (data.$fname.isEmpty) {");
        buffer.writeln(
            "      errors['$originalName'] = 'List tidak boleh kosong';");
        buffer.writeln("    }");
      }
    }
  }

  buffer.writeln();
  buffer.writeln('    return errors;');
  buffer.writeln('  }');
  buffer.writeln('}');

  return buffer.toString();
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
