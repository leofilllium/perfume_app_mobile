import 'package:dartz/dartz.dart';
import 'package:perfume_app_mobile/features/profile/data/models/order_model.dart';
import 'package:perfume_app_mobile/features/profile/domain/entities/order.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/perfume.dart';
import '../../domain/repositories/perfume_repository.dart';
import '../datasources/perfume_local_data_source.dart';
import '../datasources/perfume_remote_data_source.dart';

class PerfumeRepositoryImpl implements PerfumeRepository {
  final PerfumeRemoteDataSource remoteDataSource;
  final PerfumeLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  PerfumeRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, PerfumeList>> getPerfumes({
    String? gender,
    String? searchQuery,
    double? minPrice,
    double? maxPrice,
    int? page,
    int? pageSize,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final remotePerfumes = await remoteDataSource.getPerfumes(
          gender: gender,
          searchQuery: searchQuery,
          minPrice: minPrice,
          maxPrice: maxPrice,
          page: page,
          pageSize: pageSize,
        );
        return Right(remotePerfumes);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      // For offline caching, you might try to fetch from local data source here.
      // For this example, we'll just return a network failure if offline.
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, RecommendedPerfumeList>> getRecommendedPerfumes({
    int? page,
    int? pageSize,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final tokenEither = await getAuthToken();
        String? token = tokenEither.fold((failure) => null, (t) => t);

        if (token == null || token.isEmpty) {
          return Left(ServerFailure(message: 'Authentication token is missing. Please log in.'));
        }

        final remoteRecommendations = await remoteDataSource.getRecommendedPerfumes(
          page: page,
          pageSize: pageSize,
          token: token, // Pass token to data source
        );
        return Right(remoteRecommendations);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, OrderEntity>> placeOrder({
    required int perfumeId,
    required int quantity,
    String? orderMessage,
    required String token,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final Map<String, dynamic> orderData = await remoteDataSource.placeOrder(
          perfumeId: perfumeId,
          quantity: quantity,
          orderMessage: orderMessage,
          token: token,
        );

        final OrderModel orderModel = OrderModel.fromJson(orderData);
        return Right(orderModel);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      return Left(NetworkFailure());
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
}