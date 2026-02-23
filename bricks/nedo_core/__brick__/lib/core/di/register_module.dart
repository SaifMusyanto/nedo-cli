import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../services/storage_service/secure/secure_storage_service.dart';
import 'package:sqflite/sqflite.dart';
import '../services/network_service/config/api_config.dart';
import '../services/storage_service/db/database_module.dart';

@module
abstract class RegisterModule {
  @lazySingleton
  ApiConfig get apiConfig => ApiConfig.defaultConfig();

  @lazySingleton
  Dio get dio => Dio();

  @preResolve
  @singleton
  Future<Database> get database => provideDatabase();

  @preResolve
  @singleton
  Future<SecureStorageService> get secureStorageService =>
      SecureStorageService.create();
}
