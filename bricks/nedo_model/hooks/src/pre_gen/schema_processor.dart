import 'dart:convert';
import 'package:mason/mason.dart';
import 'parse/parse_model.dart';
import 'parse/parse_target_input.dart';
import 'schema_fetcher.dart';

class SchemaProcessor {
  final SchemaSource _schemaSource;
  final Logger _logger;

  SchemaProcessor({
    SchemaSource? source,
    required Logger logger,
  })  : _schemaSource = source ?? HttpSchemaSource(),
        _logger = logger;

  Future<void> process(HookContext context) async {
    final schemaUrl = context.vars['schema_url'] as String;
    final targetInput =
        parseTargetInput(context.vars['target_component'], _logger);
    final acronyms = (context.vars['acronyms'] as List?)?.cast<String>() ?? [];

    try {
      final json = await _schemaSource.fetch(schemaUrl, _logger);
      var schemas = _extractSchemas(json) ?? <String, dynamic>{};

      final additionalComponentsRaw = context.vars['additional_components'];
      Map<String, dynamic> additionalSchemas = {};

      if (additionalComponentsRaw is String &&
          additionalComponentsRaw.isNotEmpty) {
        try {
          additionalSchemas =
              jsonDecode(additionalComponentsRaw) as Map<String, dynamic>;
        } catch (e) {
          _logger.warn('Failed to parse additional_components JSON string: $e');
        }
      } else if (additionalComponentsRaw is List) {
        try {
          for (final component in additionalComponentsRaw) {
            if (component is Map) {
              final name = component['name'] as String?;
              final fields = component['fields'] as List?;

              if (name != null) {
                final properties = <String, dynamic>{};
                final required = <String>[];

                if (fields != null) {
                  for (final field in fields) {
                    if (field is Map) {
                      final fName = field['name'] as String;
                      final fType = field['type'] as String;
                      final fNullable = field['nullable'] as bool? ?? false;

                      properties[fName] = {
                        'type': fType,
                        'nullable': fNullable,
                      };
                      if (!fNullable) required.add(fName);
                    }
                  }
                }

                additionalSchemas[name] = {
                  'type': 'object',
                  'properties': properties,
                  'required': required,
                };
              }
            }
          }
        } catch (e) {
          _logger.warn('Failed to parse additional_components List: $e');
        }
      }

      if (additionalSchemas.isNotEmpty) {
        schemas.addAll(additionalSchemas);

        // If targets are specified, ensure manually added components are included
        if (targetInput.isNotEmpty) {
          targetInput.addAll(additionalSchemas.keys);
        }
      }

      if (schemas.isEmpty) {
        _logger.warn('No components/schemas found in schema.');
        context.vars['models'] = [];
        return;
      }

      final models = _processDependencies(targetInput, schemas, acronyms);
      context.vars['models'] = models;
      _logger.success(
          'Successfully parsed ${models.length} models using iterative logic.');
    } catch (e) {
      _logger.err('Component processing failed: $e');
      context.vars['models'] ??= [];
    }
  }

  Map<String, dynamic>? _extractSchemas(Map<String, dynamic> json) {
    final components = json['components'] as Map<String, dynamic>?;
    return components?['schemas'] as Map<String, dynamic>?;
  }

  List<Map<String, dynamic>> _processDependencies(
    List<String> targets,
    Map<String, dynamic> schemas,
    List<String> acronyms,
  ) {
    final models = <Map<String, dynamic>>[];
    final processed = <String>{};
    final queue = <String>[];

    if (targets.isNotEmpty) {
      for (final target in targets) {
        if (schemas.containsKey(target)) {
          queue.add(target);
        } else {
          _logger.warn('Target component "$target" not found in schemas.');
        }
      }
      if (queue.isEmpty) {
        _logger.err('No valid target components found.');
        return [];
      }
    } else {
      queue.addAll(schemas.keys);
    }

    _logger.info('Starting dependency analysis...');

    while (queue.isNotEmpty) {
      final modelName = queue.removeAt(0);

      if (processed.contains(modelName)) continue;
      processed.add(modelName);

      if (!schemas.containsKey(modelName)) continue;

      final schemaBody = schemas[modelName] as Map<String, dynamic>;
      final modelData = parseModel(
          modelName, schemaBody, processed, queue, acronyms, _logger);
      models.add(modelData);
    }

    return models;
  }
}
