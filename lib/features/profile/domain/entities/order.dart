import 'package:equatable/equatable.dart';
import 'package:perfume_app_mobile/features/perfume/domain/entities/perfume.dart';

class OrderEntity extends Equatable {
  final int id;
  final int quantity;
  final String? orderMessage;
  final DateTime createdAt;
  final Perfume perfume; // Keep as required, as it will be filled in

  const OrderEntity({
    required this.id,
    required this.quantity,
    this.orderMessage,
    required this.createdAt,
    required this.perfume,
  });

  // Add copyWith method to allow updating the perfume field
  OrderEntity copyWith({
    int? id,
    int? quantity,
    String? orderMessage,
    DateTime? createdAt,
    Perfume? perfume,
  }) {
    return OrderEntity(
      id: id ?? this.id,
      quantity: quantity ?? this.quantity,
      orderMessage: orderMessage ?? this.orderMessage,
      createdAt: createdAt ?? this.createdAt,
      perfume: perfume ?? this.perfume,
    );
  }

  @override
  List<Object?> get props => [id, quantity, orderMessage, createdAt, perfume];
}
