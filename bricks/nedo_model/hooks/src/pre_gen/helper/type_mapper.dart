class TypeMapper {
  static String mapPrimitiveType(String? type, String? format) {
    if (type == null) return 'dynamic';
    switch (type) {
      case 'integer':
        return (format == 'int64') ? 'int' : 'int';
      case 'number':
        return (format == 'float' || format == 'double') ? 'double' : 'num';
      case 'string':
        if (format == 'date-time' || format == 'date') return 'DateTime';
        return 'String';
      case 'boolean':
        return 'bool';
      default:
        return type;
    }
  }

  static String getRefName(dynamic ref) {
    if (ref is! String) return 'dynamic';
    return ref.split('/').last;
  }
}
