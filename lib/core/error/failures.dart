import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  const Failure();

  @override
  List<Object> get props => [];
}

class ServerFailure extends Failure {
  final String? message;

  const ServerFailure({this.message});

  @override
  List<Object> get props => [message ?? ''];
}

class CacheFailure extends Failure {}

class NetworkFailure extends Failure {}

class UnauthenticatedFailure extends Failure {
  final String? message;
  const UnauthenticatedFailure({this.message});
  @override
  List<Object> get props => [message ?? ''];
}