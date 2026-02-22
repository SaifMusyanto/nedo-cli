import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mason/mason.dart';

abstract class SchemaSource {
  Future<Map<String, dynamic>> fetch(String path, Logger logger);
}

class HttpSchemaSource implements SchemaSource {
  @override
  Future<Map<String, dynamic>> fetch(String path, Logger logger) async {
    var uriString = path;
    if (!uriString.startsWith('http')) {
      uriString = 'https://$uriString';
    }

    final uri = Uri.parse(uriString);
    final progress = logger.progress('Fetching schema from $uri...');

    try {
      final response = await http.get(uri);
      if (response.statusCode != 200) {
        progress.fail('Failed to fetch schema. Status: ${response.statusCode}');
        throw Exception('HTTP Error: ${response.statusCode}');
      }
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      progress.complete('Schema downloaded!');
      return json;
    } catch (e) {
      progress.fail('Error fetching schema: $e');
      rethrow;
    }
  }
}
