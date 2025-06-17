import 'package:dartz/dartz.dart';
import 'package:perfume_app_mobile/core/error/failures.dart';
import '../entities/order.dart';
import '../entities/preferences.dart';
import '../entities/user.dart';

abstract class ProfileRepository {
  Future<Either<Failure, UserEntity>> getUserProfile(String token);
  Future<Either<Failure, List<OrderEntity>>> getUserOrders(String token);
  Future<Either<Failure, PreferencesEntity>> getUserPreferences(String token);
  Future<Either<Failure, void>> setAuthToken(String token);
  Future<Either<Failure, String?>> getAuthToken();
  Future<Either<Failure, void>> clearAuthToken();
}