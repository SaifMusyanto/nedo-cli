import 'dart:io';
import 'package:mason/mason.dart';

Future<void> run(HookContext context) async {
  final progress = context.logger.progress('Running dart format...');
  try {
    await Process.run('dart', ['format', '.']);
    progress.complete('Formatted code');
  } catch (e) {
    progress.fail('Failed to format code: $e');
  }
}
