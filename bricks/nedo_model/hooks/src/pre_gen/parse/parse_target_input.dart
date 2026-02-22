import 'package:mason/mason.dart';

List<String> parseTargetInput(dynamic rawTarget, Logger logger) {
  if (rawTarget == null) return [];
  final inputs = rawTarget is List
      ? rawTarget.map((e) => e.toString())
      : [rawTarget.toString()];

  final normalized = <String>[];
  for (final raw in inputs) {
    if (raw.endsWith('BaseRequest')) {
      final baseName = raw.substring(0, raw.length - 'BaseRequest'.length);
      logger.info(
          "Found 'BaseRequest' suffix in '$raw'; resolving to '$baseName'.");
      normalized.add(baseName);
    } else {
      normalized.add(raw);
    }
  }
  return normalized;
}
