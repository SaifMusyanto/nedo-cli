import 'package:mason/mason.dart';
import '../../../../../../../shared/helper/snake_case_with_acronyms.dart';
import 'dart:io';
import '../base/bloc_generator_base.dart';

class StateGenerator extends BlocGeneratorBase {
  @override
  String getFileName(String featureName, List<String> acronyms) {
    return '${toSnakeCaseWithAcronyms(featureName, acronyms)}_state';
  }

  @override
  String buildContent(HookContext context, String featureName,
      List<dynamic> handlers, Directory dir, List<String> acronyms) {
    final buffer = StringBuffer();
    final pascalName = featureName.pascalCase;
    final isBloc = context.vars['is_bloc'] as bool;
    final parentFile = isBloc
        ? '${toSnakeCaseWithAcronyms(featureName, acronyms)}_bloc.dart'
        : '${toSnakeCaseWithAcronyms(featureName, acronyms)}_cubit.dart';

    final stateProps = context.vars['state_props'] as List<dynamic>? ?? [];

    buffer.writeln("part of '$parentFile';");
    buffer.writeln();

    if (!isBloc) {
      buffer
          .writeln("enum ScreenStatus { initial, loading, success, failure }");
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

        final customDefault = prop['default'] as String?;

        if (customDefault != null && customDefault.isNotEmpty) {
          def = " = $customDefault";
        } else if (type == 'String') {
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

      buffer
          .writeln("class ${pascalName}Initial extends ${pascalName}State {}");
      buffer.writeln();

      buffer.writeln("class ${pascalName}Error extends ${pascalName}State {");
      buffer.writeln("  final Failure failure;");
      buffer.writeln();
      buffer.writeln("  const ${pascalName}Error(this.failure);");
      buffer.writeln();
      buffer.writeln("  @override");
      buffer.writeln("  List<Object?> get props => [failure];");
      buffer.writeln("}");
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
      }
    }
    return buffer.toString();
  }
}
