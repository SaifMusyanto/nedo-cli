import 'package:mason/mason.dart';
import '../../../../../../../shared/helper/snake_case_with_acronyms.dart';
import 'dart:io';
import '../base/bloc_generator_base.dart';

class BlocClassGenerator extends BlocGeneratorBase {
  @override
  String getFileName(String featureName, List<String> acronyms) {
    return '${toSnakeCaseWithAcronyms(featureName, acronyms)}_bloc';
  }

  @override
  String buildContent(HookContext context, String featureName,
      List<dynamic> handlers, Directory dir, List<String> acronyms) {
    final buffer = StringBuffer();
    final pascalName = featureName.pascalCase;
    final snakeName = toSnakeCaseWithAcronyms(featureName, acronyms);

    // Imports
    buffer.writeln("import 'package:flutter_bloc/flutter_bloc.dart';");
    buffer.writeln("import 'package:equatable/equatable.dart';");
    buffer.writeln("import 'package:injectable/injectable.dart';");
    buffer.writeln("import '../../../../core/errors/failures.dart';");

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
        final innerParam = getInnerType(paramType);
        if (innerParam != 'void' &&
            !['String', 'int', 'bool', 'double'].contains(innerParam)) {
          importParams =
              "import '../../domain/entities/${toSnakeCaseWithAcronyms(innerParam, acronyms)}.dart';";
        }
      } else {
        // path fix
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
        buffer.writeln("        emit(${pascalName}Error(failure));");
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

    return buffer.toString();
  }
}
