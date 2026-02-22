import 'package:moncube_mobile/core/config/constants/database_constants.dart';
import 'package:sqflite/sqflite.dart';

import 'access_permission_table.dart';

Future<Database> provideDatabase() async {
  final String path = await getDatabasesPath();
  const String dbName = DatabaseConstants.name;

  return await openDatabase(
    '$path/$dbName',
    version: DatabaseConstants.version,
    onCreate: _onCreate,
    onConfigure: (Database db) async {
      await db.execute('PRAGMA foreign_keys = ON');
    },
  );
}

Future<void> _onCreate(Database db, int version) async {
  await _onCreateV1(db);
}

Future<void> _onCreateV1(Database db) async {
  await db.execute(AccessPermissionTable().createTableQuery);
}
