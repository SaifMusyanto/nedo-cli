import 'package:mason/mason.dart';
import '../../../../../../../shared/helper/snake_case_with_acronyms.dart';
import 'dart:io';
import '../base/bloc_generator_base.dart';

class EventGenerator extends BlocGeneratorBase {
  @override
  String getFileName(String featureName, List<String> acronyms) {
    return '${toSnakeCaseWithAcronyms(featureName, acronyms)}_event';
  }

  @override
  String buildContent(HookContext context, String featureName,
      List<dynamic> handlers, Directory dir, List<String> acronyms) {
    final buffer = StringBuffer();
    final pascalName = featureName.pascalCase;

    buffer.writeln(
        "part of '${toSnakeCaseWithAcronyms(featureName, acronyms)}_bloc.dart';");
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

    return buffer.toString();
  }
}
