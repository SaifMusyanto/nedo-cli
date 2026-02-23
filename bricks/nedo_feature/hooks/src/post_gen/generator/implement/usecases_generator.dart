import 'dart:io';
import 'package:mason/mason.dart';
import '../../../../../../../shared/helper/snake_case_with_acronyms.dart';
import '../../helper/name_provider.dart';
import '../base/feature_generator.dart';

class UsecasesGenerator extends FeatureGenerator {
  @override
  String getDirectory(String featureName, List<String> acronyms) {
    return 'lib/features/${toSnakeCaseWithAcronyms(featureName, acronyms)}/domain/usecases';
  }

  @override
  String getFileName(String featureName, List<dynamic> methods,
      NameProvider names, List<String> acronyms) {
    return ''; // Overridden by custom generate implementation
  }

  @override
  String buildContent(String featureName, List<dynamic> methods,
      NameProvider names, List<String> acronyms) {
    return ''; // Overridden by custom generate implementation
  }

  @override
  Future<void> generate({
    required String featureName,
    required List<dynamic> methods,
    required NameProvider names,
    required List<String> acronyms,
  }) async {
    final directory = getDirectory(featureName, acronyms);

    for (final m in methods) {
      final methodName = m['name'] as String;
      final returnType = m['returnType'] as String;
      final innerReturn = names.getInnerType(returnType);
      final paramType = m['paramType'] as String;
      final isPaginated = m['isPaginated'] as bool? ?? false;

      final useCaseName = '${methodName.pascalCase}UseCase';
      final fileName =
          '${toSnakeCaseWithAcronyms(methodName, acronyms)}_usecase';

      final content = StringBuffer();

      content.writeln("import 'package:fpdart/fpdart.dart';");
      content.writeln("import 'package:injectable/injectable.dart';");
      content.writeln("import '../../../../core/errors/failures.dart';");
      content.writeln(
        "import '../../../../core/usecase/usecase.dart';",
      );
      content.writeln(
        "import '../repositories/${toSnakeCaseWithAcronyms(featureName, acronyms)}_repository.dart';",
      );
      // Base Models Import
      if (isPaginated) {
        content.writeln(
            "import '../../../../core/services/network_service/models/base_list_request_model.dart';");
        content.writeln(
            "import '../../../../core/services/network_service/models/pagination_response_model.dart';");
      }

      if (innerReturn.endsWith('Entity')) {
        content.writeln(
          "import '../entities/${toSnakeCaseWithAcronyms(innerReturn, acronyms)}.dart';",
        );
      }

      final innerParam = names.getInnerType(paramType);
      if (innerParam.endsWith('Entity') || innerParam.endsWith('Params')) {
        content.writeln(
          "import '../entities/${toSnakeCaseWithAcronyms(innerParam, acronyms)}.dart';",
        );
      }

      content.writeln();
      content.writeln('@injectable');

      String ret = returnType == 'void' ? 'void' : returnType;
      if (isPaginated && innerReturn.endsWith('Entity')) {
        ret = 'PaginationResponseModel<$innerReturn>';
      }

      String param = paramType == 'void' ? 'NoParams' : paramType;
      if (isPaginated) {
        param = 'BaseListRequestModel';
      }

      content.writeln('class $useCaseName implements UseCase<$ret, $param> {');
      content
          .writeln('  final ${featureName.pascalCase}Repository repository;');
      content.writeln();
      content.writeln('  $useCaseName(this.repository);');
      content.writeln();
      content.writeln('  @override');
      content.writeln(
        '  Future<Either<Failure, $ret>> call($param params) async {',
      );
      if (paramType == 'void' && !isPaginated) {
        content.writeln('    return repository.$methodName();');
      } else {
        content.writeln('    return repository.$methodName(params);');
      }
      content.writeln('  }');
      content.writeln('}');

      final file = File('$directory/$fileName.dart');
      if (!file.parent.existsSync()) {
        await file.parent.create(recursive: true);
      }
      await file.writeAsString(content.toString());
    }
  }
}
