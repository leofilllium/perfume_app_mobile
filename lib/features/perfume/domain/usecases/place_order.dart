import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:perfume_app_mobile/features/profile/domain/entities/order.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/perfume_repository.dart';

class PlaceOrder extends UseCase<OrderEntity, PlaceOrderParams> { // Change void to OrderEntity
  final PerfumeRepository repository;

  PlaceOrder(this.repository);

  @override
  Future<Either<Failure, OrderEntity>> call(PlaceOrderParams params) async { // Change void to OrderEntity
    return await repository.placeOrder(
      perfumeId: params.perfumeId,
      quantity: params.quantity,
      orderMessage: params.orderMessage,
      token: params.token,
    );
  }
}

class PlaceOrderParams extends Equatable {
  final int perfumeId;
  final int quantity;
  final String? orderMessage;
  final String token;

  const PlaceOrderParams({
    required this.perfumeId,
    required this.quantity,
    this.orderMessage,
    required this.token,
  });

  @override
  List<Object?> get props => [perfumeId, quantity, orderMessage, token];
}