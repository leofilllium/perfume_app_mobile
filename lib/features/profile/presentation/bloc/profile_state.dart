import 'package:equatable/equatable.dart';
import '../../domain/usecases/get_user_profile_data.dart'; // Import UserProfileData

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final UserProfileData profileData;

  const ProfileLoaded({required this.profileData});

  @override
  List<Object> get props => [profileData];
}

class ProfileError extends ProfileState {
  final String message;

  const ProfileError({required this.message});

  @override
  List<Object> get props => [message];
}

class ProfileUnauthenticated extends ProfileState {}

class LoginSuccess extends ProfileState {}

class LogoutSuccess extends ProfileState {}