import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'core/network/network_info.dart';

// Perfume Feature Imports
import 'features/perfume/data/datasources/perfume_local_data_source.dart';
import 'features/perfume/data/datasources/perfume_remote_data_source.dart';
import 'features/perfume/data/repositories/perfume_repository_impl.dart';
import 'features/perfume/domain/repositories/perfume_repository.dart';
import 'features/perfume/domain/usecases/get_perfumes.dart';
import 'features/perfume/domain/usecases/place_order.dart';
import 'features/perfume/presentation/bloc/perfume_bloc.dart';

// Profile Feature Imports
import 'features/profile/data/datasources/profile_local_data_source.dart'; // Reuse for AuthLocalDataSource
import 'features/profile/data/datasources/profile_remote_data_source.dart';
import 'features/profile/data/repositories/profile_repository_impl.dart';
import 'features/profile/domain/repositories/profile_repository.dart';
import 'features/profile/domain/usecases/get_user_profile_data.dart';
import 'features/profile/presentation/bloc/profile_bloc.dart';

// AUTH Feature Imports
import 'features/auth/data/datasources/auth_local_data_source.dart'; // This will be the concrete implementation for auth token storage
import 'features/auth/data/datasources/auth_remote_data_source.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/login.dart';
import 'features/auth/domain/usecases/register.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';


final sl = GetIt.instance;

Future<void> init() async {
  //! Features - Auth
  // Bloc
  sl.registerFactory(
        () => AuthBloc(
      login: sl(),
      register: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => Login(sl()));
  sl.registerLazySingleton(() => Register(sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(
        () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(), // Using the AuthLocalDataSource here
      networkInfo: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
        () => AuthRemoteDataSourceImpl(client: sl()),
  );
  sl.registerLazySingleton<AuthLocalDataSource>( // Register the specific AuthLocalDataSource
        () => AuthLocalDataSourceImpl(sharedPreferences: sl()),
  );

  //! Features - Perfume
  // Bloc (existing)
  sl.registerFactory(
        () => PerfumeBloc(
      getPerfumes: sl(),
      placeOrder: sl(),
      perfumeRepository: sl(),
    ),
  );
  // Use cases (existing)
  sl.registerLazySingleton(() => GetPerfumes(sl()));
  sl.registerLazySingleton(() => PlaceOrder(sl()));
  // Repository (existing)
  sl.registerLazySingleton<PerfumeRepository>(
        () => PerfumeRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(), // PerfumeLocalDataSource (may be same as AuthLocalDataSource but separate for clarity)
      networkInfo: sl(),
    ),
  );
  // Data sources (existing)
  sl.registerLazySingleton<PerfumeRemoteDataSource>(
        () => PerfumeRemoteDataSourceImpl(client: sl()),
  );
  // Re-using PerfumeLocalDataSource for perfume-related caching if needed (if it's distinct from auth token storage)
  // If CACHED_AUTH_TOKEN is only for auth, then AuthLocalDataSourceImpl might be enough and PerfumeLocalDataSourceImpl could be removed/simplified.
  // For now, keeping separate as per previous structure.
  sl.registerLazySingleton<PerfumeLocalDataSource>(
        () => PerfumeLocalDataSourceImpl(sharedPreferences: sl()),
  );


  //! Features - Profile
  // Bloc (existing)
  sl.registerFactory(
        () => ProfileBloc(
      getUserProfileData: sl(),
      profileRepository: sl(),
    ),
  );
  // Use cases (existing)
  sl.registerLazySingleton(() => GetUserProfileData(sl()));
  // Repository (existing)
  sl.registerLazySingleton<ProfileRepository>(
        () => ProfileRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );
  // Data sources (existing)
  sl.registerLazySingleton<ProfileRemoteDataSource>(
        () => ProfileRemoteDataSourceImpl(client: sl()),
  );
  sl.registerLazySingleton<ProfileLocalDataSource>(
        () => ProfileLocalDataSourceImpl(sharedPreferences: sl()),
  );


  //! Core (existing)
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));

  //! External (existing)
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => http.Client());
  sl.registerLazySingleton(() => Connectivity());
}