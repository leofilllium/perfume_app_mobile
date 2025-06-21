import 'package:equatable/equatable.dart';
import '../../../domain/entities/perfume.dart';

abstract class OrderEvent extends Equatable {
  const OrderEvent();

  @override
  List<Object> get props => [];
}

class PlaceOrderEvent extends OrderEvent {
  final int quantity;
  final String? orderMessage;
  final Perfume orderedPerfume;

  const PlaceOrderEvent({
    required this.quantity,
    this.orderMessage,
    required this.orderedPerfume,
  });

  @override
  List<Object> get props => [quantity, orderMessage ?? '', orderedPerfume];
}

class ResetOrderEvent extends OrderEvent {
  const ResetOrderEvent();
}
