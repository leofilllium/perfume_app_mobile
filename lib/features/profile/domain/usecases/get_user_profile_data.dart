import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:perfume_app_mobile/core/error/failures.dart';
import 'package:perfume_app_mobile/core/usecases/usecase.dart';
import '../entities/order.dart';
import '../entities/preferences.dart';
import '../entities/user.dart';
import '../repositories/profile_repository.dart';

class UserProfileData {
  final UserEntity user;
  final List<OrderEntity> orders;
  final PreferencesEntity? preferences; // Nullable if not set

  UserProfileData({
    required this.user,
    required this.orders,
    this.preferences,
  });
}

class GetUserProfileData extends UseCase<UserProfileData, GetUserProfileDataParams> {
  final ProfileRepository repository;

  GetUserProfileData(this.repository);

  @override
  Future<Either<Failure, UserProfileData>> call(GetUserProfileDataParams params) async {
    final userResult = await repository.getUserProfile(params.token);
    final ordersResult = await repository.getUserOrders(params.token);
    final preferencesResult = await repository.getUserPreferences(params.token);

    return userResult.fold(
          (failure) => Left(failure),
          (user) => ordersResult.fold(
            (failure) => Left(failure),
            (orders) => preferencesResult.fold(
              (failure) {
            if (failure is ServerFailure && failure.message == 'User preferences not found') {
              return Right(UserProfileData(user: user, orders: orders, preferences: null));
            }
            return Left(failure);
          },
              (preferences) => Right(UserProfileData(user: user, orders: orders, preferences: preferences)),
        ),
      ),
    );
  }
}

class GetUserProfileDataParams extends Equatable {
  final String token;

  const GetUserProfileDataParams({required this.token});

  @override
  List<Object> get props => [token];
}