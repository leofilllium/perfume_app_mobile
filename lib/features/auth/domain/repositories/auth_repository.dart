import 'package:dartz/dartz.dart';
import 'package:perfume_app_mobile/core/error/failures.dart';
import '../entities/auth_response.dart';

abstract class AuthRepository {
  Future<Either<Failure, AuthResponse>> login(String name, String password);
  Future<Either<Failure, AuthResponse>> register(String name, String email, String password);
  Future<Either<Failure, void>> saveAuthToken(String token);
}