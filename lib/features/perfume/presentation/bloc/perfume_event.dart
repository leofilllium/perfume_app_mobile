import 'package:equatable/equatable.dart';
import '../../domain/entities/perfume.dart';


abstract class PerfumeEvent extends Equatable {
  const PerfumeEvent();

  @override
  List<Object> get props => [];
}

class GetPerfumesEvent extends PerfumeEvent {
  final String? gender;
  final String? searchQuery;
  final double? minPrice;
  final double? maxPrice;
  final int page;
  final int pageSize;

  const GetPerfumesEvent({
    this.gender,
    this.searchQuery,
    this.minPrice,
    this.maxPrice,
    this.page = 1,
    this.pageSize = 10,
  });

  @override
  List<Object> get props => [gender ?? '', searchQuery ?? '', minPrice ?? 0.0, maxPrice ?? 0.0, page, pageSize];
}

class PlaceOrderEvent extends PerfumeEvent {
  final int quantity;
  final String? orderMessage;
  final Perfume orderedPerfume; // Add the full Perfume object here

  const PlaceOrderEvent({
    required this.quantity,
    this.orderMessage,
    required this.orderedPerfume, // Make it required
  });

  @override
  List<Object> get props => [quantity, orderMessage ?? '', orderedPerfume];
}
