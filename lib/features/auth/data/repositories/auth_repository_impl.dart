import 'package:dartz/dartz.dart';
import 'package:perfume_app_mobile/core/error/exceptions.dart';
import 'package:perfume_app_mobile/core/error/failures.dart';
import 'package:perfume_app_mobile/core/network/network_info.dart';
import 'package:perfume_app_mobile/features/auth/domain/entities/auth_response.dart';
import 'package:perfume_app_mobile/features/auth/domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  Future<Either<Failure, AuthResponse>> _authenticate(
      Future<AuthResponse> Function() call,
      ) async {
    if (await networkInfo.isConnected) {
      try {
        final authResponse = await call();
        await localDataSource.cacheAuthToken(authResponse.token); // Cache token on success
        return Right(authResponse);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        return Left(ServerFailure(message: 'An unexpected error occurred: $e'));
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, AuthResponse>> login(String name, String password) {
    return _authenticate(() => remoteDataSource.login(name, password));
  }

  @override
  Future<Either<Failure, AuthResponse>> register(String name, String email, String password) {
    return _authenticate(() => remoteDataSource.register(name, email, password));
  }

  @override
  Future<Either<Failure, void>> saveAuthToken(String token) async {
    try {
      await localDataSource.cacheAuthToken(token);
      return const Right(null);
    } on CacheException {
      return Left(CacheFailure());
    }
  }
}