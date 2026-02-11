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

  final stateProps = context.vars['state_props'] as List<dynamic>? ?? [];

  buffer.writeln("part of '$parentFile';");
  buffer.writeln();

  if (!isBloc) {
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

    final uniqueStates = <String>{};

    for (final h in handlers) {
      final name = h['pascalName'] as String;
      final statePattern = h['statePattern'] as String;
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
      if (innerParam != 'void' &&
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
      if (innerParam != 'void' &&
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
  buffer.writeln(") : super(const ${pascalName}State());");
  buffer.writeln();

  // Methods
  for (final h in handlers) {
    final methodName = h['name']; // camelCase
    final useCaseVar = h['useCaseVar'];
    final paramType = h['paramType'];
    final hasParams = h['hasParams'] as bool;
    final isVoid = h['isVoidReturn'] as bool;

    final methodParams = hasParams ? '$paramType params' : '';

    buffer.writeln("  Future<void> $methodName($methodParams) async {");
    buffer.writeln("    emit(state.copyWith(status: ScreenStatus.loading));");

    final callParams = hasParams ? 'params' : 'NoParams()';
    buffer.writeln("    final result = await $useCaseVar($callParams);");

    buffer.writeln("    result.fold(");
    buffer.writeln("      (failure) {");

    buffer.writeln(
        "        emit(state.copyWith(status: ScreenStatus.failure, failure: failure));");

    buffer.writeln("      },");
    buffer.writeln("      (data) {");

    if (!isVoid) {
      final props = context.vars['state_props'] as List<dynamic>;
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
