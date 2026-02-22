import 'package:sqflite/sqflite.dart';

abstract class IDatabaseService {
  Future<bool> isTableExist(String table);

  Future<void> deleteTable(String table);

  Future<void> deleteAllTable();

  Future<void> execute(String sql, [List<Object?>? arguments]);

  Future<int> insert(
    String table,
    Map<String, Object?> values, {
    ConflictAlgorithm? conflictAlgorithm,
  });

  Future<void> insertBatch(String table, List<Map<String, Object?>> list);
  Future<void> updateBatch(
    String table,
    List<Map<String, Object?>> items,
    String where,
    List<Object?> Function(Map<String, Object?> item) whereArgsBuilder,
  );
  Future<void> upsertBatch(String table, List<Map<String, Object?>> list);

  Future<void> deleteBatch(String table, String idFieldName, List<String> ids);

  Future<void> update(
    String table,
    Map<String, Object?> values, {
    List<String>? where,
    List<Object?>? whereArgs,
  });

  Future<void> delete(
    String table, {
    List<String>? where,
    List<Object?>? whereArgs,
  });

  Future<List<Map<String, Object?>>> query(
    String sql, [
    List<Object?>? arguments,
  ]);

  Future<void> truncate(String table);
}
