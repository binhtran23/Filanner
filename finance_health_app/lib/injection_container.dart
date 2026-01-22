import 'package:get_it/get_it.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/network/dio_client.dart';
import 'core/network/network_info.dart';

// Data Sources
import 'data/datasources/remote/auth_remote_datasource.dart';
import 'data/datasources/remote/auth_remote_datasource_mock.dart';
import 'data/datasources/remote/profile_remote_datasource.dart';
import 'data/datasources/remote/profile_remote_datasource_mock.dart';
import 'data/datasources/remote/planner_remote_datasource.dart';
import 'data/datasources/remote/chat_remote_datasource.dart';
import 'data/datasources/remote/export_remote_datasource.dart';
import 'data/datasources/local/auth_local_datasource.dart';
import 'data/datasources/local/personal_finance_local_datasource.dart';

// Services
import 'core/utils/plan_generator_service.dart';
import 'core/utils/csv_parser_service.dart';
import 'core/utils/personal_finance_csv_service.dart';

// Repositories
import 'domain/repositories/auth_repository.dart';
import 'domain/repositories/profile_repository.dart';
import 'domain/repositories/planner_repository.dart';
import 'domain/repositories/chat_repository.dart';
import 'domain/repositories/export_repository.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'data/repositories/profile_repository_impl.dart';
import 'data/repositories/planner_repository_impl.dart';
import 'data/repositories/chat_repository_impl.dart';
import 'data/repositories/export_repository_impl.dart';

// Blocs
import 'presentation/blocs/auth/auth_bloc.dart';
import 'presentation/blocs/profile/profile_bloc.dart';
import 'presentation/blocs/planner/planner_bloc.dart';
import 'presentation/blocs/chat/chat_bloc.dart';
import 'presentation/blocs/export/export_bloc.dart';
import 'presentation/blocs/progress/progress_bloc.dart';

final sl = GetIt.instance;

/// Khởi tạo tất cả dependencies
Future<void> initDependencies() async {
  //============================================================
  // External
  //============================================================
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => const FlutterSecureStorage());

  //============================================================
  // Core
  //============================================================
  sl.registerLazySingleton(() => DioClient());
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl());
  sl.registerLazySingleton(() => PlanGeneratorService());
  sl.registerLazySingleton(() => CsvParserService());
  sl.registerLazySingleton(() => PersonalFinanceCsvService());

  //============================================================
  // Data Sources
  //============================================================
  // Remote
  // TODO: Thay đổi về AuthRemoteDataSourceImpl khi backend đã sẵn sàng
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceMock(), // Sử dụng mock để test UI
    // () => AuthRemoteDataSourceImpl(dioClient: sl()), // Uncomment khi backend ready
  );
  // TODO: Thay đổi về ProfileRemoteDataSourceImpl khi backend đã sẵn sàng
  sl.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceMock(), // Sử dụng mock để test UI
    // () => ProfileRemoteDataSourceImpl(dioClient: sl()), // Uncomment khi backend ready
  );
  sl.registerLazySingleton<PlannerRemoteDataSource>(
    () => PlannerRemoteDataSourceImpl(dioClient: sl()),
  );
  sl.registerLazySingleton<ChatRemoteDataSource>(
    () => ChatRemoteDataSourceImpl(dioClient: sl()),
  );
  sl.registerLazySingleton<ExportRemoteDataSource>(
    () => ExportRemoteDataSourceImpl(dioClient: sl()),
  );

  // Local
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(secureStorage: sl(), sharedPreferences: sl()),
  );
  sl.registerLazySingleton<PersonalFinanceLocalDataSource>(
    () => PersonalFinanceLocalDataSourceImpl(prefs: sl()),
  );

  //============================================================
  // Repositories
  //============================================================
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()),
  );
  sl.registerLazySingleton<PlannerRepository>(
    () => PlannerRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()),
  );
  sl.registerLazySingleton<ChatRepository>(
    () => ChatRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()),
  );
  sl.registerLazySingleton<ExportRepository>(
    () => ExportRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()),
  );

  //============================================================
  // Blocs
  //============================================================
  sl.registerFactory(() => AuthBloc(authRepository: sl()));
  sl.registerFactory(() => ProfileBloc(profileRepository: sl()));
  sl.registerFactory(() => PlannerBloc(plannerRepository: sl()));
  sl.registerFactory(() => ChatBloc(chatRepository: sl()));
  sl.registerFactory(() => ExportBloc(exportRepository: sl()));
  sl.registerFactory(() => ProgressBloc());
}
