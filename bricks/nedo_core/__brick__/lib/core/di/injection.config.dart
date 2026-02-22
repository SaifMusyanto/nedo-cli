// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i361;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:sqflite/sqflite.dart' as _i779;

import '../../features/auth/data/providers/remote/implementations/local_access_permission_provider.dart'
    as _i228;
import '../../features/auth/data/providers/remote/implementations/remote_auth_provider.dart'
    as _i532;
import '../../features/auth/data/providers/remote/interfaces/i_local_access_permission_provider.dart'
    as _i772;
import '../../features/auth/data/providers/remote/interfaces/i_remote_auth_provider.dart'
    as _i1014;
import '../../features/auth/data/repositories/auth_repository_impl.dart'
    as _i153;
import '../../features/auth/domain/repositories/auth_repository.dart' as _i787;
import '../../features/auth/domain/usecases/auth_get_token_usecase.dart'
    as _i457;
import '../../features/auth/domain/usecases/auth_get_user_usecase.dart'
    as _i120;
import '../../features/auth/domain/usecases/auth_login_usecase.dart' as _i786;
import '../../features/auth/domain/usecases/auth_set_page_access_permissions_usecase.dart'
    as _i789;
import '../../features/auth/presentation/bloc/login/login_bloc.dart' as _i208;
import '../../features/auth/presentation/bloc/splash/splash_bloc.dart' as _i175;
import '../../features/cubicle/data/providers/remote/cubicle_remote_provider_impl.dart'
    as _i1054;
import '../../features/cubicle/data/providers/remote/interfaces/i_cubicle_remote_provider.dart'
    as _i461;
import '../../features/cubicle/data/repositories/cubicle_repository_impl.dart'
    as _i17;
import '../../features/cubicle/domain/repositories/i_cubicle_repository.dart'
    as _i525;
import '../../features/cubicle/domain/usecases/get_alarm_category_list_items_usecase.dart'
    as _i1002;
import '../../features/cubicle/domain/usecases/get_alarm_category_threshold_pagination_usecase.dart'
    as _i549;
import '../../features/cubicle/domain/usecases/get_chart_data_usecase.dart'
    as _i574;
import '../../features/cubicle/domain/usecases/get_cubicle_by_id_usecase.dart'
    as _i896;
import '../../features/cubicle/domain/usecases/get_cubicle_data_pagination_usecase.dart'
    as _i898;
import '../../features/cubicle/domain/usecases/get_cubicle_info_usecase.dart'
    as _i592;
import '../../features/cubicle/domain/usecases/get_cubicles_usecase.dart'
    as _i613;
import '../../features/cubicle/presentation/bloc/cubicle_bloc.dart' as _i25;
import '../../features/cubicle/presentation/bloc/detail/cubicle_detail_bloc.dart'
    as _i777;
import '../../features/dashboard/data/providers/remote/implementations/remote_dashboard_provider.dart'
    as _i706;
import '../../features/dashboard/data/providers/remote/interfaces/i_remote_dashboard_provider.dart'
    as _i1026;
import '../../features/dashboard/data/repositories/dashboard_repository_impl.dart'
    as _i509;
import '../../features/dashboard/domain/repositories/dashboard_repository.dart'
    as _i665;
import '../../features/dashboard/domain/usecases/get_alarm_log_pagination_usecase.dart'
    as _i479;
import '../../features/dashboard/domain/usecases/get_realtime_updates_usecase.dart'
    as _i131;
import '../../features/dashboard/domain/usecases/get_ulp_dashboard_alert_panel_cubicle_usecase.dart'
    as _i392;
import '../../features/dashboard/domain/usecases/get_ulp_dashboard_usecase.dart'
    as _i833;
import '../../features/dashboard/domain/usecases/get_up3_info_pagination_usecase.dart'
    as _i652;
import '../../features/dashboard/domain/usecases/get_up3_pagination_usecase.dart'
    as _i609;
import '../../features/dashboard/domain/usecases/get_user_usecase.dart'
    as _i250;
import '../../features/dashboard/domain/usecases/logout_usecase.dart' as _i490;
import '../../features/dashboard/domain/usecases/update_role_usecase.dart'
    as _i689;
import '../../features/dashboard/presentation/bloc/dashboard_cubit.dart'
    as _i58;
import '../../features/substation/data/providers/remote/implementations/substation_remote_provider.dart'
    as _i245;
import '../../features/substation/data/providers/remote/interfaces/i_substation_remote_provider.dart'
    as _i404;
import '../../features/substation/data/repositories/substation_repository_impl.dart'
    as _i746;
import '../../features/substation/domain/repositories/i_substation_repository.dart'
    as _i536;
import '../../features/substation/domain/usecases/get_substation_realtime_updates_usecase.dart'
    as _i691;
import '../../features/substation/domain/usecases/get_substations_usecase.dart'
    as _i824;
import '../../features/substation/domain/usecases/get_ulp_pagination_usecase.dart'
    as _i264;
import '../../features/substation/presentation/bloc/substation_bloc.dart'
    as _i519;
import '../../features/ulp/data/providers/remote/implementations/remote_ulp_provider.dart'
    as _i262;
import '../../features/ulp/data/providers/remote/interfaces/i_remote_ulp_provider.dart'
    as _i936;
import '../../features/ulp/data/repositories/ulp_repository_impl.dart' as _i603;
import '../../features/ulp/domain/repositories/ulp_repository.dart' as _i95;
import '../../features/ulp/domain/usecases/fetch_ulp_by_id_usecase.dart'
    as _i148;
import '../../features/ulp/domain/usecases/get_ulp_pagination_usecase.dart'
    as _i155;
import '../../features/ulp/presentation/bloc/ulp_cubit.dart' as _i495;
import '../services/network_service/config/api_config.dart' as _i511;
import '../services/network_service/dio_client.dart' as _i747;
import '../services/storage_service/db/database_service.dart' as _i317;
import '../services/storage_service/db/i_database_service.dart' as _i1072;
import '../services/storage_service/secure/secure_storage_service.dart'
    as _i175;
import '../services/websocket_service/websocket_service.dart' as _i419;
import '../utils/events/auth_event_bus.dart' as _i321;
import 'register_module.dart' as _i291;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final registerModule = _$RegisterModule();
    await gh.singletonAsync<_i779.Database>(
      () => registerModule.database,
      preResolve: true,
    );
    await gh.singletonAsync<_i175.SecureStorageService>(
      () => registerModule.secureStorageService,
      preResolve: true,
    );
    gh.singleton<_i419.WebSocketService>(() => _i419.WebSocketService());
    gh.lazySingleton<_i511.ApiConfig>(() => registerModule.apiConfig);
    gh.lazySingleton<_i361.Dio>(() => registerModule.dio);
    gh.lazySingleton<_i321.AuthEventBus>(() => _i321.AuthEventBus());
    gh.lazySingleton<_i747.DioClient>(
      () => _i747.DioClient(
        dio: gh<_i361.Dio>(),
        config: gh<_i511.ApiConfig>(),
        secureStorageService: gh<_i175.SecureStorageService>(),
        authEventBus: gh<_i321.AuthEventBus>(),
      ),
    );
    gh.factory<_i1014.IRemoteAuthProvider>(
      () => _i532.RemoteAuthProvider(
        dioClient: gh<_i747.DioClient>(),
        secureStorageService: gh<_i175.SecureStorageService>(),
      ),
    );
    gh.factory<_i936.IRemoteUlpProvider>(
      () => _i262.RemoteUlpProvider(
        dioClient: gh<_i747.DioClient>(),
        secureStorageService: gh<_i175.SecureStorageService>(),
      ),
    );
    gh.lazySingleton<_i461.ICubicleRemoteProvider>(
      () => _i1054.CubicleRemoteProviderImpl(
        gh<_i747.DioClient>(),
        gh<_i419.WebSocketService>(),
      ),
    );
    gh.lazySingleton<_i1072.IDatabaseService>(
      () => _i317.DatabaseService(gh<_i779.Database>()),
    );
    gh.factory<_i772.ILocalAccessPermissionProvider>(
      () => _i228.LocalAccessPermissionProvider(
        databaseService: gh<_i1072.IDatabaseService>(),
      ),
    );
    gh.factory<_i1026.IRemoteDashboardProvider>(
      () => _i706.RemoteDashboardProvider(
        dioClient: gh<_i747.DioClient>(),
        secureStorageService: gh<_i175.SecureStorageService>(),
        webSocketService: gh<_i419.WebSocketService>(),
      ),
    );
    gh.factory<_i95.UlpRepository>(
      () => _i603.UlpRepositoryImpl(gh<_i936.IRemoteUlpProvider>()),
    );
    gh.factory<_i787.AuthRepository>(
      () => _i153.AuthRepositoryImpl(
        gh<_i1014.IRemoteAuthProvider>(),
        gh<_i772.ILocalAccessPermissionProvider>(),
      ),
    );
    gh.factory<_i404.ISubstationRemoteProvider>(
      () => _i245.SubstationRemoteProvider(
        gh<_i747.DioClient>(),
        gh<_i419.WebSocketService>(),
      ),
    );
    gh.lazySingleton<_i536.ISubstationRepository>(
      () =>
          _i746.SubstationRepositoryImpl(gh<_i404.ISubstationRemoteProvider>()),
    );
    gh.factory<_i691.GetSubstationRealtimeUpdatesUseCase>(
      () => _i691.GetSubstationRealtimeUpdatesUseCase(
        gh<_i536.ISubstationRepository>(),
      ),
    );
    gh.factory<_i148.FetchULPByIdUseCase>(
      () => _i148.FetchULPByIdUseCase(gh<_i95.UlpRepository>()),
    );
    gh.factory<_i155.GetULPPaginationUseCase>(
      () => _i155.GetULPPaginationUseCase(gh<_i95.UlpRepository>()),
    );
    gh.factory<_i665.DashboardRepository>(
      () => _i509.DashboardRepositoryImpl(
        gh<_i1026.IRemoteDashboardProvider>(),
        gh<_i175.SecureStorageService>(),
      ),
    );
    gh.lazySingleton<_i525.ICubicleRepository>(
      () => _i17.CubicleRepositoryImpl(gh<_i461.ICubicleRemoteProvider>()),
    );
    gh.factory<_i250.GetUserUseCase>(
      () => _i250.GetUserUseCase(gh<_i665.DashboardRepository>()),
    );
    gh.factory<_i457.AuthGetTokenUseCase>(
      () =>
          _i457.AuthGetTokenUseCase(authRepository: gh<_i787.AuthRepository>()),
    );
    gh.factory<_i786.AuthLoginUseCase>(
      () => _i786.AuthLoginUseCase(authRepository: gh<_i787.AuthRepository>()),
    );
    gh.factory<_i789.AuthSetPageAccessPermissionsUseCase>(
      () =>
          _i789.AuthSetPageAccessPermissionsUseCase(gh<_i787.AuthRepository>()),
    );
    gh.factory<_i479.GetAlarmLogPaginationUseCase>(
      () => _i479.GetAlarmLogPaginationUseCase(gh<_i665.DashboardRepository>()),
    );
    gh.factory<_i131.GetRealtimeUpdatesUseCase>(
      () => _i131.GetRealtimeUpdatesUseCase(gh<_i665.DashboardRepository>()),
    );
    gh.factory<_i392.GetULPDashboardAlertPanelCubicleUseCase>(
      () => _i392.GetULPDashboardAlertPanelCubicleUseCase(
        gh<_i665.DashboardRepository>(),
      ),
    );
    gh.factory<_i833.GetULPDashboardUseCase>(
      () => _i833.GetULPDashboardUseCase(gh<_i665.DashboardRepository>()),
    );
    gh.factory<_i652.GetUp3InfoPaginationUseCase>(
      () => _i652.GetUp3InfoPaginationUseCase(gh<_i665.DashboardRepository>()),
    );
    gh.factory<_i609.GetUP3PaginationUseCase>(
      () => _i609.GetUP3PaginationUseCase(gh<_i665.DashboardRepository>()),
    );
    gh.factory<_i120.AuthGetUserUseCase>(
      () => _i120.AuthGetUserUseCase(repository: gh<_i787.AuthRepository>()),
    );
    gh.factory<_i824.GetSubstationsUseCase>(
      () => _i824.GetSubstationsUseCase(gh<_i536.ISubstationRepository>()),
    );
    gh.factory<_i264.GetULPPaginationUseCase>(
      () => _i264.GetULPPaginationUseCase(gh<_i536.ISubstationRepository>()),
    );
    gh.factory<_i1002.GetAlarmCategoryListItemsUseCase>(
      () => _i1002.GetAlarmCategoryListItemsUseCase(
        gh<_i525.ICubicleRepository>(),
      ),
    );
    gh.factory<_i549.GetAlarmCategoryThresholdPaginationUseCase>(
      () => _i549.GetAlarmCategoryThresholdPaginationUseCase(
        gh<_i525.ICubicleRepository>(),
      ),
    );
    gh.factory<_i574.GetChartDataUseCase>(
      () => _i574.GetChartDataUseCase(gh<_i525.ICubicleRepository>()),
    );
    gh.factory<_i896.GetCubicleByIdUseCase>(
      () => _i896.GetCubicleByIdUseCase(gh<_i525.ICubicleRepository>()),
    );
    gh.factory<_i898.GetCubicleDataPaginationUseCase>(
      () =>
          _i898.GetCubicleDataPaginationUseCase(gh<_i525.ICubicleRepository>()),
    );
    gh.factory<_i592.GetCubicleInfoUseCase>(
      () => _i592.GetCubicleInfoUseCase(gh<_i525.ICubicleRepository>()),
    );
    gh.factory<_i613.GetCubiclesUseCase>(
      () => _i613.GetCubiclesUseCase(gh<_i525.ICubicleRepository>()),
    );
    gh.factory<_i490.LogoutUseCase>(
      () => _i490.LogoutUseCase(gh<_i665.DashboardRepository>()),
    );
    gh.factory<_i689.UpdateRoleUseCase>(
      () => _i689.UpdateRoleUseCase(gh<_i665.DashboardRepository>()),
    );
    gh.factory<_i777.CubicleDetailBloc>(
      () => _i777.CubicleDetailBloc(
        gh<_i896.GetCubicleByIdUseCase>(),
        gh<_i574.GetChartDataUseCase>(),
        gh<_i592.GetCubicleInfoUseCase>(),
        gh<_i1002.GetAlarmCategoryListItemsUseCase>(),
        gh<_i479.GetAlarmLogPaginationUseCase>(),
        gh<_i898.GetCubicleDataPaginationUseCase>(),
      ),
    );
    gh.factory<_i25.CubicleBloc>(
      () => _i25.CubicleBloc(
        gh<_i613.GetCubiclesUseCase>(),
        gh<_i264.GetULPPaginationUseCase>(),
        gh<_i824.GetSubstationsUseCase>(),
      ),
    );
    gh.factory<_i58.DashboardCubit>(
      () => _i58.DashboardCubit(
        gh<_i609.GetUP3PaginationUseCase>(),
        gh<_i833.GetULPDashboardUseCase>(),
        gh<_i392.GetULPDashboardAlertPanelCubicleUseCase>(),
        gh<_i131.GetRealtimeUpdatesUseCase>(),
        gh<_i250.GetUserUseCase>(),
        gh<_i689.UpdateRoleUseCase>(),
        gh<_i490.LogoutUseCase>(),
        gh<_i155.GetULPPaginationUseCase>(),
        gh<_i479.GetAlarmLogPaginationUseCase>(),
        gh<_i175.SecureStorageService>(),
      ),
    );
    gh.factory<_i208.LoginBloc>(
      () => _i208.LoginBloc(
        gh<_i786.AuthLoginUseCase>(),
        gh<_i457.AuthGetTokenUseCase>(),
        gh<_i120.AuthGetUserUseCase>(),
        gh<_i789.AuthSetPageAccessPermissionsUseCase>(),
        gh<_i175.SecureStorageService>(),
      ),
    );
    gh.factory<_i519.SubstationBloc>(
      () => _i519.SubstationBloc(
        gh<_i536.ISubstationRepository>(),
        gh<_i264.GetULPPaginationUseCase>(),
        gh<_i691.GetSubstationRealtimeUpdatesUseCase>(),
      ),
    );
    gh.factory<_i495.UlpCubit>(
      () => _i495.UlpCubit(
        gh<_i155.GetULPPaginationUseCase>(),
        gh<_i392.GetULPDashboardAlertPanelCubicleUseCase>(),
        gh<_i609.GetUP3PaginationUseCase>(),
      ),
    );
    gh.factory<_i175.SplashBloc>(
      () => _i175.SplashBloc(
        gh<_i175.SecureStorageService>(),
        gh<_i120.AuthGetUserUseCase>(),
        gh<_i789.AuthSetPageAccessPermissionsUseCase>(),
      ),
    );
    return this;
  }
}

class _$RegisterModule extends _i291.RegisterModule {}
