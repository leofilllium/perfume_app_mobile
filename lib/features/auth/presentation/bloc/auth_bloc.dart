import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:perfume_app_mobile/core/error/failures.dart';
import 'package:perfume_app_mobile/features/auth/domain/usecases/login.dart';
import 'package:perfume_app_mobile/features/auth/domain/usecases/register.dart';
import 'auth_event.dart';
import 'auth_state.dart';

const String SERVER_FAILURE_MESSAGE = 'Server Failure';
const String NETWORK_FAILURE_MESSAGE = 'Network Failure';
const String CACHE_FAILURE_MESSAGE = 'Cache Failure';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final Login login;
  final Register register;

  AuthBloc({
    required this.login,
    required this.register,
  }) : super(AuthInitial()) {
    on<LoginEvent>(_onLogin);
    on<RegisterEvent>(_onRegister);
  }

  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await login(LoginParams(name: event.name, password: event.password));
    result.fold(
          (failure) => emit(AuthError(message: _mapFailureToMessage(failure))),
          (_) => emit(AuthSuccess()),
    );
  }

  Future<void> _onRegister(RegisterEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await register(RegisterParams(
      name: event.name,
      email: event.email,
      password: event.password,
    ));
    result.fold(
          (failure) => emit(AuthError(message: _mapFailureToMessage(failure))),
          (_) => emit(AuthSuccess()),
    );
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        final serverFailure = failure as ServerFailure;
        return serverFailure.message ?? SERVER_FAILURE_MESSAGE;
      case NetworkFailure:
        return NETWORK_FAILURE_MESSAGE;
      case CacheFailure:
        return CACHE_FAILURE_MESSAGE;
      default:
        return 'Unexpected error';
    }
  }
}