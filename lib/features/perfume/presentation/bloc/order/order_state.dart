import 'package:equatable/equatable.dart';
import 'package:perfume_app_mobile/features/profile/domain/entities/order.dart';

abstract class OrderState extends Equatable {
  const OrderState();

  @override
  List<Object> get props => [];
}

class OrderInitial extends OrderState {}

class OrderPlacing extends OrderState {}

class OrderSuccess extends OrderState {
  final String message;
  final OrderEntity order;

  const OrderSuccess({required this.message, required this.order});

  @override
  List<Object> get props => [message, order];
}

class OrderError extends OrderState {
  final String message;

  const OrderError({required this.message});

  @override
  List<Object> get props => [message];
}