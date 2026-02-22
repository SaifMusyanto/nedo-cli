String toSnakeCaseWithAcronyms(String input, List<String> acronyms) {
  if (acronyms.isEmpty) {
    return _toSnakeCase(input);
  }

  final sortedAcronyms = acronyms.toList()
    ..sort((a, b) => b.length.compareTo(a.length));

  String result = input;

  for (final acronym in sortedAcronyms) {
    final regex = RegExp('(?<![A-Z])${RegExp.escape(acronym)}');
    result = result.replaceAllMapped(regex, (match) {
      final replacement = acronym.toLowerCase();
      if (match.start > 0) {
        return '_$replacement';
      }
      return replacement;
    });
  }

  return _toSnakeCase(result);
}

String _toSnakeCase(String input) {
  if (input.isEmpty) return input;

  final buffer = StringBuffer();
  for (int i = 0; i < input.length; i++) {
    final char = input[i];
    if (_isUpperCase(char) && i > 0 && !_isUpperCase(input[i - 1])) {
      buffer.write('_');
    }
    buffer.write(char.toLowerCase());
  }
  return buffer.toString();
}

bool _isUpperCase(String char) {
  return char.toUpperCase() == char && char.toLowerCase() != char;
}
