import 'package:dartz/dartz.dart';
import 'package:perfume_app_mobile/core/error/exceptions.dart';
import 'package:perfume_app_mobile/core/error/failures.dart';
import 'package:perfume_app_mobile/core/network/network_info.dart';
import 'package:perfume_app_mobile/features/profile/domain/entities/order.dart';
import 'package:perfume_app_mobile/features/profile/domain/entities/preferences.dart';
import 'package:perfume_app_mobile/features/profile/domain/entities/user.dart';
import 'package:perfume_app_mobile/features/profile/domain/repositories/profile_repository.dart';
import '../datasources/profile_local_data_source.dart';
import '../datasources/profile_remote_data_source.dart';


class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;
  final ProfileLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  ProfileRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  Future<Either<Failure, T>> _performNetworkCall<T>(
      Future<T> Function() call,
      ) async {
    if (await networkInfo.isConnected) {
      try {
        return Right(await call());
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } on UnauthenticatedException catch (e) {
        return Left(UnauthenticatedFailure(message: e.message));
      } catch (e) {
        return Left(ServerFailure(message: 'An unexpected error occurred: $e'));
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, UserEntity>> getUserProfile(String token) {
    return _performNetworkCall(() => remoteDataSource.getUserProfile(token));
  }

  @override
  Future<Either<Failure, List<OrderEntity>>> getUserOrders(String token) {
    return _performNetworkCall(() => remoteDataSource.getUserOrders(token));
  }

  @override
  Future<Either<Failure, PreferencesEntity>> getUserPreferences(String token) {
    return _performNetworkCall(() => remoteDataSource.getUserPreferences(token));
  }

  @override
  Future<Either<Failure, void>> setAuthToken(String token) async {
    try {
      await localDataSource.cacheAuthToken(token);
      return const Right(null);
    } on CacheException {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, String?>> getAuthToken() async {
    try {
      final token = await localDataSource.getAuthToken();
      return Right(token);
    } on CacheException {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, void>> clearAuthToken() async {
    try {
      await localDataSource.clearAuthToken();
      return const Right(null);
    } on CacheException {
      return Left(CacheFailure());
    }
  }
}