import 'package:equatable/equatable.dart';

class AuthResponse extends Equatable {
  final String token;
  // You might include user info here if the API returns it directly on login/register
  // final UserEntity user;

  const AuthResponse({
    required this.token,
    // required this.user,
  });

  @override
  List<Object> get props => [token];
}