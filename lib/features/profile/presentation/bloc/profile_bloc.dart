import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:perfume_app_mobile/core/error/failures.dart';
import 'package:perfume_app_mobile/features/profile/domain/repositories/profile_repository.dart';
import 'package:perfume_app_mobile/features/profile/domain/usecases/get_user_profile_data.dart';
import 'profile_event.dart';
import 'profile_state.dart';

const String SERVER_FAILURE_MESSAGE = 'Server Failure';
const String NETWORK_FAILURE_MESSAGE = 'Network Failure';
const String UNATUHENTICATED_MESSAGE = 'You need to be logged in to view your profile.';
const String SESSION_EXPIRED_MESSAGE = 'Your session has expired. Please log in again.';
const String CACHE_FAILURE_MESSAGE = 'Cache Failure';


class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetUserProfileData getUserProfileData;
  final ProfileRepository profileRepository; // For auth token management

  ProfileBloc({
    required this.getUserProfileData,
    required this.profileRepository,
  }) : super(ProfileInitial()) {
    on<GetProfileDataEvent>(_onGetProfileData);
    on<LoginAnonymouslyEvent>(_onLoginAnonymously);
    on<LogoutEvent>(_onLogout);
  }

  Future<void> _onGetProfileData(
      GetProfileDataEvent event,
      Emitter<ProfileState> emit,
      ) async {
    emit(ProfileLoading());

    final tokenResult = await profileRepository.getAuthToken();

    await tokenResult.fold(
          (failure) async {
        emit(ProfileUnauthenticated());
      },
          (token) async {
        if (token == null || token.isEmpty) {
          emit(ProfileUnauthenticated());
          return;
        }

        final profileDataResult = await getUserProfileData(GetUserProfileDataParams(token: token));

        profileDataResult.fold(
              (failure) {
            if (failure is UnauthenticatedFailure) {
              profileRepository.clearAuthToken();
              emit(ProfileUnauthenticated());
            } else {
              emit(ProfileError(message: _mapFailureToMessage(failure)));
            }
          },
              (profileData) => emit(ProfileLoaded(profileData: profileData)),
        );
      },
    );
  }

  Future<void> _onLoginAnonymously(LoginAnonymouslyEvent event, Emitter<ProfileState> emit) async {
    await profileRepository.setAuthToken(event.token);
    emit(LoginSuccess()); // Indicate success, then immediately fetch profile data
    add(GetProfileDataEvent());
  }

  Future<void> _onLogout(LogoutEvent event, Emitter<ProfileState> emit) async {
    await profileRepository.clearAuthToken();
    emit(LogoutSuccess()); // Indicate success, then transition to unauthenticated
    emit(ProfileUnauthenticated());
  }


  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        final serverFailure = failure as ServerFailure;
        if (serverFailure.message == 'User preferences not found') {
          return 'User preferences not found'; // Specific case for preferences
        }
        return serverFailure.message ?? SERVER_FAILURE_MESSAGE;
      case CacheFailure:
        return CACHE_FAILURE_MESSAGE;
      case NetworkFailure:
        return NETWORK_FAILURE_MESSAGE;
      case UnauthenticatedFailure:
        return SESSION_EXPIRED_MESSAGE; // More specific message for session expiry
      default:
        return 'Unexpected error';
    }
  }
}