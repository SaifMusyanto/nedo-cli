class NameProvider {
  final Map<String, String> _originalToModel = {};
  final Map<String, String> _originalToEntity = {};

  NameProvider(List models) {
    for (final m in models) {
      final originalName = m['name'] as String;
      _originalToModel[originalName] = _getModelName(originalName);
      _originalToEntity[originalName] = _getEntityName(originalName);
    }
  }

  String getModelName(String original) =>
      _originalToModel[original] ?? original;
  String getEntityName(String original) {
    if (original == 'BasePaginationRequest') return original;
    return _originalToEntity[original] ?? original;
  }

  String getInnerType(String type) {
    if (type.startsWith('List<') && type.endsWith('>')) {
      return type.substring(5, type.length - 1);
    }
    return type;
  }

  String _getModelName(String original) {
    if (original.endsWith('DTO')) {
      return '${original.substring(0, original.length - 3)}Model';
    } else if (original.endsWith('Data')) {
      return '${original.substring(0, original.length - 4)}Model';
    } else if (original.endsWith('BaseRequest')) {
      return '${original.substring(0, original.length - 11)}Model';
    } else if (original.endsWith('Request')) {
      return '${original}Model';
    }
    return '${original}Model';
  }

  String _getEntityName(String original) {
    if (original.endsWith('DTO')) {
      return '${original.substring(0, original.length - 3)}Entity';
    } else if (original.endsWith('Data')) {
      return '${original.substring(0, original.length - 4)}Entity';
    } else if (original.endsWith('BaseRequest')) {
      return '${original.substring(0, original.length - 11)}Params';
    } else if (original.endsWith('Request')) {
      return '${original.substring(0, original.length - 7)}Params';
    }
    return '${original}Entity';
  }
}
