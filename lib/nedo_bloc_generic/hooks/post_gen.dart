import 'dart:io';
import 'package:mason/mason.dart';

Future<void> run(HookContext context) async {
  final featureName = context.vars['feature_name'] as String;
  final isBloc = context.vars['is_bloc'] as bool;
  final handlers = context.vars['handlers'] as List<dynamic>;

  final featureSnake = featureName.snakeCase;
  final blocDir = Directory(
    'lib/features/$featureSnake/presentation/bloc',
  );
  if (!blocDir.existsSync()) {
    await blocDir.create(recursive: true);
  }

  await _generateStates(context, featureName, handlers, blocDir, isBloc);

  if (isBloc) {
    await _generateEvents(context, featureName, handlers, blocDir);
  }

  if (isBloc) {
    await _generateBloc(context, featureName, handlers, blocDir);
  } else {
    await _generateCubit(context, featureName, handlers, blocDir);
  }
}

// --- Generators ---

Future<void> _generateStates(
  HookContext context,
  String featureName,
  List<dynamic> handlers,
  Directory dir,
  bool isBloc,
) async {
  final buffer = StringBuffer();
  final pascalName = featureName.pascalCase;
  final fileName = '${featureName.snakeCase}_state';
  final parentFile = isBloc
      ? '${featureName.snakeCase}_bloc.dart'
      : '${featureName.snakeCase}_cubit.dart';

  final stateStyle = context.vars['state_style'] as String;
  final stateProps = context.vars['state_props'] as List<dynamic>? ?? [];

  buffer.writeln("part of '$parentFile';");
  buffer.writeln();

  if (stateStyle == 'single') {
    buffer.writeln("enum ScreenStatus { initial, loading, success, failure }");
    buffer.writeln();

    buffer.writeln("class ${pascalName}State extends Equatable {");

    // Fields
    buffer.writeln("  final ScreenStatus status;");
    buffer.writeln("  final Failure? failure;");
    for (final prop in stateProps) {
      final type = prop['type'];
      final name = prop['name'];
      if (name == 'status' || name == 'failure') continue;
      buffer.writeln("  final $type $name;");
    }
    buffer.writeln();

    // Constructor
    buffer.writeln("  const ${pascalName}State({");
    buffer.writeln("    this.status = ScreenStatus.initial,");
    buffer.writeln("    this.failure,");

    for (final prop in stateProps) {
      final name = prop['name'];
      final type = prop['type'] as String;
      String def = '';

      if (name == 'status' || name == 'failure') continue;

      if (type == 'String') {
        def = " = ''";
      } else if (type == 'int' || type == 'double') {
        def = " = 0";
      } else if (type == 'bool') {
        def = " = false";
      } else if (type.startsWith('List')) {
        def = " = const []";
      }

      // If nullable, default to null implicitly or explicitly?
      // If not nullable and no default, distinct required.
      // For simplicity, let's make non-enum/non-basic types required or nullable?
      // Let's assume user inputs types correctly (e.g. User?).
      // We will just add `required` if no default is provided for safety,
      // unless it's nullable.

      if (def.isNotEmpty) {
        buffer.writeln("    this.$name$def,");
      } else if (type.endsWith('?')) {
        buffer.writeln("    this.$name,");
      } else {
        buffer.writeln("    required this.$name,");
      }
    }
    buffer.writeln("  });");
    buffer.writeln();

    // CopyWith
    buffer.writeln("  ${pascalName}State copyWith({");
    buffer.writeln("    ScreenStatus? status,");
    buffer.writeln("    Failure? failure,");

    for (final prop in stateProps) {
      final type = prop['type'] as String;
      final name = prop['name'];

      if (name == 'status' || name == 'failure') continue;

      String finalType;
      if (type.endsWith('?')) {
        finalType = type;
      } else {
        finalType = '$type?';
      }
      buffer.writeln("    $finalType $name,");
    }
    buffer.writeln("  }) {");
    buffer.writeln("    return ${pascalName}State(");
    buffer.writeln("      status: status ?? this.status,");
    buffer.writeln("      failure: failure ?? this.failure,");

    for (final prop in stateProps) {
      final name = prop['name'];
      if (name == 'status' || name == 'failure') continue;
      buffer.writeln("      $name: $name ?? this.$name,");
    }
    buffer.writeln("    );");
    buffer.writeln("  }");
    buffer.writeln();

    // Props
    buffer.writeln("  @override");
    buffer.writeln("  List<Object?> get props => [");
    buffer.writeln("        status,");
    buffer.writeln("        failure,");
    for (final prop in stateProps) {
      if (prop['name'] == 'status' || prop['name'] == 'failure') continue;
      buffer.writeln("        ${prop['name']},");
    }
    buffer.writeln("      ];");
    buffer.writeln("}");
  } else {
    // --- Multi State Generation (Existing Logic) & MainType support ---
    final mainDataType = context.vars['main_data_type'] as String? ?? '';

    buffer.writeln("abstract class ${pascalName}State extends Equatable {");
    buffer.writeln("  const ${pascalName}State();");
    buffer.writeln();
    buffer.writeln("  @override");
    buffer.writeln("  List<Object?> get props => [];");
    buffer.writeln("}");
    buffer.writeln();

    buffer.writeln("class ${pascalName}Initial extends ${pascalName}State {}");
    buffer.writeln();

    // Track unique states to avoid duplicates
    final uniqueStates = <String>{};

    for (final h in handlers) {
      final name = h['pascalName'] as String;
      final statePattern =
          h['statePattern'] as String; // standard, optimistic, simple
      final returnType = h['returnType'] as String;
      final isVoid = h['isVoidReturn'] as bool;

      // Loading State (Standard only)
      if (statePattern == 'standard') {
        final loadingState = "${name}Loading";
        if (!uniqueStates.contains(loadingState)) {
          uniqueStates.add(loadingState);
          buffer.writeln("class $loadingState extends ${pascalName}State {}");
          buffer.writeln();
        }
      }

      // Success State (All patterns)
      final successState = "${name}Success";
      if (!uniqueStates.contains(successState)) {
        uniqueStates.add(successState);
        buffer.writeln("class $successState extends ${pascalName}State {");

        // Logic: If mainDataType is set, use IT. Else use specific method return type.
        // Actually, mainDataType is likely for "General" success.
        // If we have specific methods returning specific things, do we merge them?
        // The user said: "ganti data type ini untuk yang multi state aja jadi dia bakalan ditempatkan di bagian sukses."
        // So if mainDataType exists, we might want a GenericSuccess or specific Success uses it?
        // Let's assume if mainDataType is present, it OVERRIDES the specific return type for the success state
        // OR we add it as an EXTRA field?
        // Let's stick to the method's return type generally, BUT if mainDataType is provided,
        // maybe the User intended a "MainSuccess" state?
        // *Re-reading*: "Main data type for standard Success state".
        // Since we generate unique success states per method (e.g. GetUserSuccess),
        // maybe we should just apply it there if the method return type is void?
        // OR better: The user might want a shared Success state?
        // Current logic generates `MethodNameSuccess`.
        // Let's apply mainDataType to any Success state if it matches?
        // Actually, the simplest interpretation: If `main_data_type` is set,
        // we might want a `class ${pascalName}Success` (Generic) instead of method specific?
        // BUT the existing logic iterates handlers.
        // Let's keep existing logic but if `main_data_type` is set, and the method return type is void, maybe use it?
        // Valid use case: `v type` => List<User>. Method `unstar` returns void.
        // On success, we might want to return the List<User> updated?
        // Let's just USE the method's return type as before, but if `main_data_type` is set,
        // maybe we shouldn't force it unless requested.
        // WAIT, the prompt says "The main data type for the standard Success state".
        // If the user sets it, they probably want it used.
        // Let's stick to existing logic for now as it's safer per method.
        // *Self-Correction*: I will use `mainDataType` if provided specifically for a `GeneralSuccess` or
        // if we want to enforce it.
        // Let's strictly follow the existing logic which uses `returnType`.
        // `main_data_type` currently doesn't seem to hook into `handlers` loop well unless we force a handler?
        // Maybe the user meant for the Single "Success" state in a simpler pattern?
        // Let's iterate:
        if (mainDataType.isNotEmpty && (isVoid || returnType == 'void')) {
          buffer.writeln("  final $mainDataType data;");
          buffer.writeln();
          buffer.writeln("  const $successState(this.data);");
          buffer.writeln();
          buffer.writeln("  @override");
          buffer.writeln("  List<Object?> get props => [data];");
        } else if (!isVoid) {
          buffer.writeln("  final $returnType data;");
          buffer.writeln();
          buffer.writeln("  const $successState(this.data);");
          buffer.writeln();
          buffer.writeln("  @override");
          buffer.writeln("  List<Object?> get props => [data];");
        } else {
          buffer.writeln("  const $successState();");
        }
        buffer.writeln("}");
        buffer.writeln();
      }

      // Failure State (Standard & Optimistic)
      if (statePattern != 'simple') {
        final failureState = "${name}Failure";
        if (!uniqueStates.contains(failureState)) {
          uniqueStates.add(failureState);
          buffer.writeln("class $failureState extends ${pascalName}State {");
          buffer.writeln("  final Failure failure;");
          buffer.writeln();
          buffer.writeln("  const $failureState(this.failure);");
          buffer.writeln();
          buffer.writeln("  @override");
          buffer.writeln("  List<Object?> get props => [failure];");
          buffer.writeln("}");
          buffer.writeln();
        }
      }
    }
  }

  File('${dir.path}/$fileName.dart').writeAsStringSync(buffer.toString());
}

Future<void> _generateEvents(
  HookContext context,
  String featureName,
  List<dynamic> handlers,
  Directory dir,
) async {
  final buffer = StringBuffer();
  final pascalName = featureName.pascalCase;
  final fileName = '${featureName.snakeCase}_event';

  buffer.writeln("part of '${featureName.snakeCase}_bloc.dart';");
  buffer.writeln();
  buffer.writeln("abstract class ${pascalName}Event extends Equatable {");
  buffer.writeln("  const ${pascalName}Event();");
  buffer.writeln();
  buffer.writeln("  @override");
  buffer.writeln("  List<Object?> get props => [];");
  buffer.writeln("}");
  buffer.writeln();

  for (final h in handlers) {
    final eventName = h['eventName'] as String;
    final paramType = h['paramType'] as String;
    final hasParams = h['hasParams'] as bool;

    buffer.writeln("class $eventName extends ${pascalName}Event {");
    if (hasParams) {
      buffer.writeln("  final $paramType params;");
      buffer.writeln();
      buffer.writeln("  const $eventName(this.params);");
      buffer.writeln();
      buffer.writeln("  @override");
      buffer.writeln("  List<Object?> get props => [params];");
    } else {
      buffer.writeln("  const $eventName();");
    }
    buffer.writeln("}");
    buffer.writeln();
  }

  File('${dir.path}/$fileName.dart').writeAsStringSync(buffer.toString());
}

Future<void> _generateBloc(
  HookContext context,
  String featureName,
  List<dynamic> handlers,
  Directory dir,
) async {
  final buffer = StringBuffer();
  final pascalName = featureName.pascalCase;
  final snakeName = featureName.snakeCase;
  final fileName = '${snakeName}_bloc';

  // Imports
  buffer.writeln("import 'package:flutter_bloc/flutter_bloc.dart';");
  buffer.writeln("import 'package:equatable/equatable.dart';");
  buffer.writeln("import 'package:injectable/injectable.dart';");
  buffer.writeln("import '../../../../core/error/failures.dart';");

  // Custom Imports from pre_gen
  final imports = context.vars['imports'] as List<dynamic>;
  for (final import in imports) {
    buffer.writeln(import);
  }
  for (final handler in handlers) {
    final paramType = handler['paramType'];
    final hasParams = handler['hasParams'] as bool;
    String? importParams;
    if (hasParams) {
      final innerParam = _getInnerType(paramType);
      if (innerParam != 'none (void)' &&
          !['String', 'int', 'bool', 'double'].contains(innerParam)) {
        importParams =
            "import '../../domain/entities/${innerParam.snakeCase}.dart';";
      }
    } else {
      importParams = "import '../../../../core/usecase/usecase.dart';";
    }
    if (importParams != null && !imports.toString().contains(importParams)) {
      buffer.writeln(importParams);
    }
  }

  buffer.writeln();
  buffer.writeln("part '${snakeName}_event.dart';");
  buffer.writeln("part '${snakeName}_state.dart';");
  buffer.writeln();

  buffer.writeln("@injectable");
  buffer.writeln(
      "class ${pascalName}Bloc extends Bloc<${pascalName}Event, ${pascalName}State> {");

  // Dependencies
  for (final h in handlers) {
    final useCaseType = h['useCaseName'];
    final useCaseVar = h['useCaseVar'];
    buffer.writeln("  final $useCaseType $useCaseVar;");
  }

  // Constructor
  buffer.writeln();
  buffer.write("  ${pascalName}Bloc(");
  for (final h in handlers) {
    buffer.write("this.${h['useCaseVar']}, ");
  }
  buffer.writeln(") : super(${pascalName}Initial()) {");

  // Handlers Registration
  for (final h in handlers) {
    final eventName = h['eventName'];
    final handlerName = '_on$eventName';
    final transformer = h['transformer'];

    buffer.write("    on<$eventName>($handlerName");
    if (transformer != null) {
      buffer.write(", transformer: $transformer()");
    }
    buffer.writeln(");");
  }
  buffer.writeln("  }");
  buffer.writeln();

  // Handler Implementations
  for (final h in handlers) {
    final eventName = h['eventName'];
    final handlerName = '_on$eventName';
    final useCaseVar = h['useCaseVar'];
    final statePattern = h['statePattern'];
    final successState = h['stateSuccess'];
    final failureState = h['stateFailure'];
    final hasParams = h['hasParams'] as bool;
    final isVoid = h['isVoidReturn'] as bool;

    buffer.writeln(
        "  Future<void> $handlerName($eventName event, Emitter<${pascalName}State> emit) async {");

    if (statePattern == 'standard') {
      buffer.writeln("    emit(${h['pascalName']}Loading());");
    }

    final callParams = hasParams ? 'event.params' : 'NoParams()';
    buffer.writeln("    final result = await $useCaseVar($callParams);");

    // Fpdart Fold Logic
    buffer.writeln("    result.fold(");

    // Failure Callback
    buffer.writeln("      (failure) {");
    if (statePattern != 'simple') {
      buffer.writeln("        emit($failureState(failure));");
    }
    buffer.writeln("      },");

    // Success Callback
    buffer.writeln("      (data) {");
    if (!isVoid) {
      buffer.writeln("        emit($successState(data));");
    } else {
      buffer.writeln("        emit(const $successState());");
    }
    buffer.writeln("      },");

    buffer.writeln("    );"); // End fold
    buffer.writeln("  }");
    buffer.writeln();
  }

  buffer.writeln("}");

  File('${dir.path}/$fileName.dart').writeAsStringSync(buffer.toString());
}

Future<void> _generateCubit(
  HookContext context,
  String featureName,
  List<dynamic> handlers,
  Directory dir,
) async {
  final buffer = StringBuffer();
  final pascalName = featureName.pascalCase;
  final snakeName = featureName.snakeCase;
  final fileName = '${snakeName}_cubit';
  final stateStyle = context.vars['state_style'] as String? ?? 'multi';
  final mainDataType = context.vars['main_data_type'] as String? ?? '';

  // Imports
  buffer.writeln("import 'package:flutter_bloc/flutter_bloc.dart';");
  buffer.writeln("import 'package:equatable/equatable.dart';");
  buffer.writeln("import 'package:injectable/injectable.dart';");
  buffer.writeln("import '../../../../core/error/failures.dart';");

  final imports = context.vars['imports'] as List<dynamic>;
  for (final import in imports) {
    if (!import.toString().contains('bloc_concurrency')) {
      buffer.writeln(import);
    }
  }

  for (final handler in handlers) {
    final paramType = handler['paramType'];
    final hasParams = handler['hasParams'] as bool;
    String? importParams;
    if (hasParams) {
      final innerParam = _getInnerType(paramType);
      if (innerParam != 'none (void)' &&
          !['String', 'int', 'bool', 'double'].contains(innerParam)) {
        importParams =
            "import '../../domain/entities/${innerParam.snakeCase}.dart';";
      }
    } else {
      importParams = "import '../../../../core/usecase/usecase.dart';";
    }
    if (importParams != null && !imports.toString().contains(importParams)) {
      imports.add(importParams);
      buffer.writeln(importParams);
    }
  }

  // If mainDataType is used and it's a model/entity, we hope it's imported via methods.
  // If not, we might miss an import.
  // Assuming strict architecture where methods cover the data types.

  buffer.writeln();
  buffer.writeln("part '${snakeName}_state.dart';");
  buffer.writeln();

  buffer.writeln("@injectable");
  buffer
      .writeln("class ${pascalName}Cubit extends Cubit<${pascalName}State> {");

  for (final h in handlers) {
    final useCaseType = h['useCaseName'];
    final useCaseVar = h['useCaseVar'];
    buffer.writeln("  final $useCaseType $useCaseVar;");
  }

  buffer.writeln();
  buffer.write("  ${pascalName}Cubit(");
  for (final h in handlers) {
    buffer.write("this.${h['useCaseVar']}, ");
  }

  // Initial State logic
  if (stateStyle == 'single') {
    buffer.writeln(") : super(const ${pascalName}State());");
  } else {
    buffer.writeln(") : super(${pascalName}Initial());");
  }

  buffer.writeln();

  // Methods
  for (final h in handlers) {
    final methodName = h['name']; // camelCase
    final useCaseVar = h['useCaseVar'];
    final statePattern = h['statePattern'];
    final successState = h['stateSuccess'];
    final failureState = h['stateFailure'];
    final paramType = h['paramType'];
    final hasParams = h['hasParams'] as bool;
    final isVoid = h['isVoidReturn'] as bool;

    final methodParams = hasParams ? '$paramType params' : '';

    buffer.writeln("  Future<void> $methodName($methodParams) async {");

    if (stateStyle == 'single') {
      // --- Single State Emit Logic ---
      // Assuming 'status' field exists if we want to set loading.
      // We'll try to set status=loading if possible.
      buffer.writeln("    emit(state.copyWith(status: ScreenStatus.loading));");
    } else {
      // --- Multi State Emit Logic ---
      if (statePattern == 'standard') {
        buffer.writeln("    emit(${h['pascalName']}Loading());");
      }
    }

    final callParams = hasParams ? 'params' : 'NoParams()';
    buffer.writeln("    final result = await $useCaseVar($callParams);");

    buffer.writeln("    result.fold(");
    buffer.writeln("      (failure) {");

    if (stateStyle == 'single') {
      // Single State Failure
      buffer.writeln(
          "        emit(state.copyWith(status: ScreenStatus.failure, failure: failure));");
    } else {
      // Multi State Failure
      if (statePattern != 'simple') {
        buffer.writeln("        emit($failureState(failure));");
      }
    }

    buffer.writeln("      },");
    buffer.writeln("      (data) {");

    if (stateStyle == 'single') {
      // Single State Success
      // emit(state.copyWith(status: ScreenStatus.success, someField: data));
      // Logic: try to match 'data' type to a field in props?
      // Or just status.
      if (!isVoid) {
        // Try to find a property with matching type
        // Implementation constraint: This is hard without reflection on context.vars['state_props'].
        // Let's iterate context.vars['state_props'] to find a match!
        final props = context.vars['state_props'] as List<dynamic>;
        // We need to match `returnType` (data's type) with a prop type.
        // Note: returnType might be `List<UserEntity>` and prop might be `List<UserEntity>`.
        // Simple string match.
        var dataField = '';
        for (final p in props) {
          if (p['type'] == h['returnType']) {
            dataField = p['name'];
            break;
          }
        }

        if (dataField.isNotEmpty) {
          buffer.writeln(
              "        emit(state.copyWith(status: ScreenStatus.success, $dataField: data));");
        } else {
          buffer.writeln(
              "        emit(state.copyWith(status: ScreenStatus.success)); // TODO: Assign data to field");
        }
      } else {
        buffer.writeln(
            "        emit(state.copyWith(status: ScreenStatus.success));");
      }
    } else {
      // Multi State Success
      if (mainDataType.isNotEmpty && (isVoid || h['returnType'] == 'void')) {
        // Assuming data matches mainDataType logic?
        // Actually, if it's void return, we can't pass 'data'.
        // We can only pass data if the usecase returns it.
        // So mainDataType here is decorative if usecase returns void.
        // But if usecase returns `T`, and mainDataType is `T`.
        buffer.writeln("        emit(const $successState());");
      } else if (!isVoid) {
        buffer.writeln("        emit($successState(data));");
      } else {
        buffer.writeln("        emit(const $successState());");
      }
    }

    buffer.writeln("      },");
    buffer.writeln("    );");

    buffer.writeln("  }");
    buffer.writeln();
  }

  buffer.writeln("}");

  File('${dir.path}/$fileName.dart').writeAsStringSync(buffer.toString());
}

String _getInnerType(String type) {
  if (type.startsWith('List<') && type.endsWith('>')) {
    return type.substring(5, type.length - 1);
  }
  return type;
}
