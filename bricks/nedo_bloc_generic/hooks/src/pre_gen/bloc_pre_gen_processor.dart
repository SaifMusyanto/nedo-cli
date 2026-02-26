import 'package:mason/mason.dart';
import '../../../../../shared/helper/snake_case_with_acronyms.dart';

class BlocPreGenProcessor {
  final Logger logger;

  BlocPreGenProcessor({required this.logger});

  Future<void> process(HookContext context) async {
    if (!context.vars.containsKey('feature_name')) {
      if (context.vars.containsKey('name')) {
        context.vars['feature_name'] = context.vars['name'];
      } else {
        context.vars['feature_name'] = logger.prompt(
          'What is the feature name? (e.g. Auth, Order)',
        );
      }
    }
    final featureName = context.vars['feature_name'] as String;
    final acronyms = (context.vars['acronyms'] as List?)?.cast<String>() ?? [];

    if (!context.vars.containsKey('type')) {
      if (context.vars.containsKey('stateManagement')) {
        final stateMgmt =
            context.vars['stateManagement'] as Map<String, dynamic>;
        context.vars['type'] = stateMgmt['type'];
        if (stateMgmt.containsKey('properties')) {
          context.vars['state_props'] = stateMgmt['properties'];
        }
      } else {
        context.vars['type'] = logger.chooseOne(
          'Select state management type:',
          choices: ['bloc', 'cubit'],
          defaultValue: 'bloc',
        );
      }
    }
    final isBloc = (context.vars['type'] as String).toLowerCase() == 'bloc';

    final hasStateMgmt = context.vars.containsKey('stateManagement');

    if (!isBloc) {
      final props = <Map<String, dynamic>>[];
      if (!hasStateMgmt) {
        logger.info('\n--- Define State Properties ---');

        if (logger.confirm('Add a "status" field (enum)?',
            defaultValue: true)) {
          props.add({
            'name': 'status',
            'type': 'ScreenStatus',
          });
        }

        bool addingProps = true;
        while (addingProps) {
          if (!logger.confirm('Add a property to the state?',
              defaultValue: true)) {
            addingProps = false;
            break;
          }

          final propName = logger.prompt('Property name (e.g. user, items):');
          final propType =
              logger.prompt('Property type (e.g. User?, List<Item>):');
          final propDefault = logger.prompt(
            'Default value (optional, e.g. "User.empty()", "[]"):',
          );

          props.add({
            'name': propName,
            'type': propType,
            'default': propDefault.isEmpty ? null : propDefault,
          });
        }
        context.vars['state_props'] = props;
      }
    } else {
      if (!context.vars.containsKey('main_data_type') && !hasStateMgmt) {
        if (logger.confirm('Define a main data type for Success state?',
            defaultValue: false)) {
          context.vars['main_data_type'] =
              logger.prompt('Enter type (e.g. List<User>):');
        } else {
          context.vars['main_data_type'] = '';
        }
      }
    }

    if (!context.vars.containsKey('methods')) {
      logger.info('No methods configuration found from previous steps.');
      context.vars['methods'] = [];
    }

    final methods = context.vars['methods'] as List<dynamic>;

    final dependencies = <String, dynamic>{
      'hasSecureStorage': hasStateMgmt
          ? false
          : logger.confirm(
              'Does this Bloc need SecureStorageService?',
              defaultValue: false,
            ),
      'hasStreamSubscription': false,
    };

    final handlers = <Map<String, dynamic>>[];
    final imports = <String>{};

    for (final method in methods) {
      final rawName = method['name'] as String;
      final returnType = method['returnType'] as String;
      final paramType = method['paramType'] as String;

      final pascalName = rawName.pascalCase;
      final camelName = rawName.camelCase;

      String? transformerFunction;

      if (isBloc) {
        String concurrency = 'concurrent (default)';
        if (!hasStateMgmt) {
          concurrency = logger.chooseOne(
            'Concurrency mode for "$rawName"? (default: concurrent)',
            choices: [
              'concurrent (default)',
              'droppable',
              'restartable',
              'sequential'
            ],
            defaultValue: 'concurrent (default)',
          );
        }

        if (concurrency != 'concurrent (default)') {
          transformerFunction = concurrency;
          imports
              .add("import 'package:bloc_concurrency/bloc_concurrency.dart';");
        }
      }

      String statePattern = 'standard (triad: loading, success, failure)';
      if (!hasStateMgmt) {
        statePattern = logger.chooseOne(
          'State Pattern for "$rawName"? (default: standard)',
          choices: [
            'standard (triad: loading, success, failure)',
            'optimistic (success, failure)',
            'simple (success only)',
          ],
          defaultValue: 'standard (triad: loading, success, failure)',
        );
      }
      final useCaseName = '${pascalName}UseCase';
      final useCaseVar = '_${camelName}UseCase';

      imports.add(
          "import '../../domain/usecases/${toSnakeCaseWithAcronyms(rawName, acronyms)}_usecase.dart';");

      final pathParams = method['pathParams'] as List? ?? [];
      final isPaginated = method['isPaginated'] as bool? ?? false;
      final queryParamType = method['queryParamType'] as String? ?? 'void';

      bool isWrapperParam = false;
      int extraParams =
          (paramType != 'void' ? 1 : 0) + (queryParamType != 'void' ? 1 : 0);
      if (pathParams.isNotEmpty &&
          (extraParams > 0 || isPaginated || pathParams.length > 1)) {
        isWrapperParam = true;
      } else if (extraParams > 1 || (isPaginated && queryParamType != 'void')) {
        isWrapperParam = true;
      }

      String resolvedParamType = 'void';
      if (!isWrapperParam) {
        if (isPaginated) {
          resolvedParamType = 'BasePaginationRequest';
        } else if (extraParams == 0 && pathParams.length == 1) {
          resolvedParamType = pathParams.first['type'] as String;
        } else if (extraParams == 1 && pathParams.isEmpty) {
          resolvedParamType = paramType != 'void' ? paramType : queryParamType;
        }
      } else {
        resolvedParamType = '${pascalName}Params';
      }

      bool hasParams = isWrapperParam || resolvedParamType != 'void';

      if (paramType != 'void' &&
          !isWrapperParam &&
          !['String', 'int', 'bool'].contains(paramType)) {
        final innerParam = _getInnerType(paramType);
        if (innerParam == 'BasePaginationRequest') {
          imports.add(
              "import '../../../../../../core/services/network_service/models/request/base_pagination_request.dart';");
        } else if (innerParam.endsWith('Params') ||
            innerParam.endsWith('Entity')) {
          imports.add(
              "import '../../domain/entities/${toSnakeCaseWithAcronyms(innerParam, acronyms)}.dart';");
        }
      }

      if (queryParamType != 'void' && !isWrapperParam) {
        final innerQueryParam = _getInnerType(queryParamType);
        if (innerQueryParam.endsWith('Params') ||
            innerQueryParam.endsWith('Entity') ||
            innerQueryParam.endsWith('QueryParams')) {
          imports.add(
              "import '../../domain/entities/${toSnakeCaseWithAcronyms(innerQueryParam.endsWith('QueryParams') ? '${innerQueryParam}Entity' : innerQueryParam, acronyms)}.dart';");
        }
      }
      if (returnType != 'void' &&
          !['String', 'int', 'bool', 'double'].contains(returnType)) {
        final innerReturn = _getInnerType(returnType);

        bool isReturnUsed = false;
        if (isBloc) {
          isReturnUsed = true;
        } else {
          final props = context.vars['state_props'] as List<dynamic>? ?? [];
          isReturnUsed = props.any((p) {
            final type = p['type'] as String;
            return type == returnType || type == '$returnType?';
          });
        }

        if (isReturnUsed && innerReturn.endsWith('Entity')) {
          imports.add(
              "import '../../domain/entities/${toSnakeCaseWithAcronyms(innerReturn, acronyms)}.dart';");
        }
      }

      handlers.add({
        'name': rawName,
        'pascalName': pascalName,
        'eventName': '${pascalName}Requested',
        'stateSuccess': '${pascalName}Success',
        'stateFailure': '${featureName.pascalCase}Error',
        'useCaseName': useCaseName,
        'useCaseVar': useCaseVar,
        'hasParams': hasParams,
        'resolvedParamType': resolvedParamType,
        'paramType': paramType,
        'queryParamType': queryParamType,
        'isVoidReturn': returnType == 'void',
        'returnType': returnType,
        'transformer': transformerFunction,
        'statePattern': statePattern.split(' ').first,
        'isWrapperParam': isWrapperParam,
      });
    }

    context.vars['handlers'] = handlers;
    context.vars['imports'] = imports.toList();
    context.vars['dependencies'] = dependencies;
    context.vars['is_bloc'] = isBloc;
    context.vars['is_cubit'] = !isBloc;

    context.vars['use_fpdart'] = true;
    context.vars['use_equatable'] = true;

    logger.success(
      'Wiring complete! Ready to generate ${isBloc ? 'Bloc' : 'Cubit'} for $featureName.',
    );
  }

  String _getInnerType(String type) {
    if (type.startsWith('List<') && type.endsWith('>')) {
      return type.substring(5, type.length - 1);
    }
    return type;
  }
}
