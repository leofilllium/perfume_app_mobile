import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:perfume_app_mobile/core/error/failures.dart';
import 'package:perfume_app_mobile/core/usecases/usecase.dart';
import '../entities/auth_response.dart';
import '../repositories/auth_repository.dart';

class Login extends UseCase<AuthResponse, LoginParams> {
  final AuthRepository repository;

  Login(this.repository);

  @override
  Future<Either<Failure, AuthResponse>> call(LoginParams params) async {
    return await repository.login(params.name, params.password);
  }
}

class LoginParams extends Equatable {
  final String name;
  final String password;

  const LoginParams({required this.name, required this.password});

  @override
  List<Object> get props => [name, password];
}