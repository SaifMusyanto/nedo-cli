abstract class BaseDatabaseTable<TModel> {
  String get rowId;
  String get tableName;
  String get createTableQuery;
  TModel buildModel(Map<String, dynamic> map);
  List<TModel> buildModels(List<Map<String, dynamic>> list) =>
      List<TModel>.generate(
        list.length,
        (int index) => buildModel(list[index]),
      );
  Map<String, dynamic> buildMap(TModel model);

  List<Map<String, dynamic>> buildMaps(List<TModel> list) =>
      List<Map<String, dynamic>>.generate(
        list.length,
        (int index) => buildMap(list[index]),
      );
}
