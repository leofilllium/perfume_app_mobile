import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object> get props => [];
}

class GetProfileDataEvent extends ProfileEvent {}

class LoginAnonymouslyEvent extends ProfileEvent {
  final String token;
  const LoginAnonymouslyEvent({required this.token});

  @override
  List<Object> get props => [token];
}

class LogoutEvent extends ProfileEvent {}