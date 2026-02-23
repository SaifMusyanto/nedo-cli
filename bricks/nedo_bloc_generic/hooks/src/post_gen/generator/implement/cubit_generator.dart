import 'package:mason/mason.dart';
import '../../../../../../../shared/helper/snake_case_with_acronyms.dart';
import 'dart:io';
import '../base/bloc_generator_base.dart';

class CubitGenerator extends BlocGeneratorBase {
  @override
  String getFileName(String featureName, List<String> acronyms) {
    return '${toSnakeCaseWithAcronyms(featureName, acronyms)}_cubit';
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
    // path fix
    buffer.writeln("import '../../../../core/errors/failures.dart';");

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
        imports.add(importParams);
        buffer.writeln(importParams);
      }
    }

    buffer.writeln();
    buffer.writeln("part '${snakeName}_state.dart';");
    buffer.writeln();

    buffer.writeln("@injectable");
    buffer.writeln(
        "class ${pascalName}Cubit extends Cubit<${pascalName}State> {");

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

    return buffer.toString();
  }
}
