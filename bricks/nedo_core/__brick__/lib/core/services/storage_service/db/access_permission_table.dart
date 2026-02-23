import '../../../config/constants/database_constants.dart';
import '../../../domain/access/entities/access_permission_entity.dart';
import 'base_database_table.dart';

class AccessPermissionTable extends BaseDatabaseTable<AccessPermissionEntity> {
  @override
  String get tableName => DatabaseConstants.accessPermissionTable;

  @override
  String get rowId => 'id';

  String get moduleName => 'module_name';
  String get canView => 'can_view';
  String get canInsert => 'can_insert';
  String get canUpdate => 'can_update';
  String get canUpsert => 'can_upsert';
  String get canDelete => 'can_delete';
  String get canHistory => 'can_history';
  String get canMenu => 'can_menu';

  @override
  String get createTableQuery =>
      '''
    CREATE TABLE $tableName (
      $rowId INTEGER PRIMARY KEY AUTOINCREMENT,
      $moduleName TEXT,
      $canView INTEGER,
      $canInsert INTEGER,
      $canUpdate INTEGER,
      $canUpsert INTEGER,
      $canDelete INTEGER,
      $canHistory INTEGER,
      $canMenu INTEGER
    )
  ''';

  @override
  Map<String, dynamic> buildMap(AccessPermissionEntity model) =>
      <String, dynamic>{
        rowId: null,
        moduleName: model.moduleName,
        canView: model.canView ? 1 : 0,
        canInsert: model.canInsert ? 1 : 0,
        canUpdate: model.canUpdate ? 1 : 0,
        canUpsert: model.canUpsert ? 1 : 0,
        canDelete: model.canDelete ? 1 : 0,
        canHistory: model.canHistory ? 1 : 0,
        canMenu: model.canMenu ? 1 : 0,
      };

  @override
  AccessPermissionEntity buildModel(Map<String, dynamic> map) =>
      AccessPermissionEntity(
        moduleName: map[moduleName] as String? ?? '',
        canView: map[canView] == 1,
        canInsert: map[canInsert] == 1,
        canUpdate: map[canUpdate] == 1,
        canUpsert: map[canUpsert] == 1,
        canDelete: map[canDelete] == 1,
        canHistory: map[canHistory] == 1,
        canMenu: map[canMenu] == 1,
      );
}
