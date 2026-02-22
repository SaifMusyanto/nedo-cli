import 'package:injectable/injectable.dart';
import 'package:sqflite/sqflite.dart';
import 'i_database_service.dart';

@LazySingleton(as: IDatabaseService)
class DatabaseService implements IDatabaseService {
  final Database _database;

  DatabaseService(this._database);

  @override
  Future<void> deleteAllTable() async {
    const String sql = """
      SELECT name FROM sqlite_master 
      WHERE type = 'table' 
      AND name NOT LIKE 'sqlite_%' 
      AND name NOT LIKE 'android_metadata'
    """;
    final List<Map<String, dynamic>> data = await query(sql);

    if (data.isNotEmpty) {
      for (int i = 0; i < data.length; i++) {
        await deleteTable(data[i]['name'].toString());
      }
    }
  }

  @override
  Future<void> deleteTable(String table) =>
      _database.execute('DROP TABLE $table;');

  @override
  Future<void> execute(String sql, [List<Object?>? arguments]) =>
      _database.execute(sql, arguments);

  @override
  Future<int> insert(
    String table,
    Map<String, Object?> values, {
    ConflictAlgorithm? conflictAlgorithm,
  }) => _database.insert(table, values, conflictAlgorithm: conflictAlgorithm);

  @override
  Future<void> insertBatch(
    String table,
    List<Map<String, Object?>> list,
  ) async {
    final Batch batch = _database.batch();

    for (Map<String, Object?> item in list) {
      batch.insert(table, item);
    }

    await batch.commit(noResult: true);
  }

  @override
  Future<void> updateBatch(
    String table,
    List<Map<String, Object?>> items,
    String where,
    List<Object?> Function(Map<String, Object?> item) whereArgsBuilder,
  ) async {
    final Batch batch = _database.batch();

    for (final Map<String, Object?> item in items) {
      batch.update(
        table,
        item,
        where: where,
        whereArgs: whereArgsBuilder(item),
      );
    }

    await batch.commit(noResult: true);
  }

  @override
  Future<void> upsertBatch(
    String table,
    List<Map<String, Object?>> list,
  ) async {
    final Batch batch = _database.batch();
    for (final Map<String, Object?> item in list) {
      batch.insert(table, item, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  @override
  Future<void> deleteBatch(
    String table,
    String idFieldName,
    List<String> ids,
  ) async {
    const int batchSize = 900;

    for (var i = 0; i < ids.length; i += batchSize) {
      final end = (i + batchSize < ids.length) ? i + batchSize : ids.length;
      final chunk = ids.sublist(i, end);

      final String placeholders = List.filled(chunk.length, '?').join(', ');
      await _database.delete(
        table,
        where: '$idFieldName IN ($placeholders)',
        whereArgs: chunk,
      );
    }
  }

  @override
  Future<bool> isTableExist(String table) async {
    const String sql = """
      SELECT COUNT(*) AS result_count 
      FROM sqlite_master 
      WHERE type = 'table' AND name = ?
    """;

    final List<Map<String, dynamic>> result = await query(sql, <String>[table]);

    if (result.isNotEmpty && result[0]['result_count'] != 0) {
      return true;
    } else {
      return false;
    }
  }

  @override
  Future<void> delete(
    String table, {
    List<String>? where,
    List<Object?>? whereArgs,
  }) {
    final whereClause = where?.join(' AND ').trim();

    return _database.delete(
      table,
      where: (whereClause != null && whereClause.isNotEmpty)
          ? whereClause
          : null,
      whereArgs: whereArgs,
    );
  }

  @override
  Future<List<Map<String, Object?>>> query(
    String sql, [
    List<Object?>? arguments,
  ]) => _database.rawQuery(sql, arguments);

  @override
  Future<void> update(
    String table,
    Map<String, Object?> values, {
    List<String>? where,
    List<Object?>? whereArgs,
  }) {
    final whereClause = where?.join(' AND ').trim();

    return _database.update(
      table,
      values,
      where: (whereClause != null && whereClause.isNotEmpty)
          ? whereClause
          : null,
      whereArgs: whereArgs,
    );
  }

  @override
  Future<void> truncate(String table) =>
      _database.execute('DELETE FROM $table; VACUUM;');
}
