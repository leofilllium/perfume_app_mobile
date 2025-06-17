import 'package:equatable/equatable.dart';
import 'package:perfume_app_mobile/features/profile/domain/entities/order.dart';
import '../../domain/entities/perfume.dart';
import '../../domain/repositories/perfume_repository.dart'; // Ensure PerfumeList is imported

abstract class PerfumeState extends Equatable {
  const PerfumeState();

  @override
  List<Object> get props => [];
}

class PerfumeInitial extends PerfumeState {}

// Initial full load or refresh
class PerfumeLoading extends PerfumeState {}

// State for when perfumes are successfully loaded
class PerfumeLoaded extends PerfumeState {
  final PerfumeList perfumeList;
  final bool hasReachedMax; // Indicates if all pages have been loaded
  final bool isFetchingMore; // Indicates if more items are currently being fetched

  const PerfumeLoaded({
    required this.perfumeList,
    this.hasReachedMax = false,
    this.isFetchingMore = false,
  });

  // Helper to create a new state with updated values
  PerfumeLoaded copyWith({
    PerfumeList? perfumeList,
    bool? hasReachedMax,
    bool? isFetchingMore,
  }) {
    return PerfumeLoaded(
      perfumeList: perfumeList ?? this.perfumeList,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isFetchingMore: isFetchingMore ?? this.isFetchingMore,
    );
  }

  @override
  List<Object> get props => [perfumeList, hasReachedMax, isFetchingMore];
}

class PerfumeError extends PerfumeState {
  final String message;

  const PerfumeError({required this.message});

  @override
  List<Object> get props => [message];
}

class OrderSuccess extends PerfumeState {
  final String message;
  final OrderEntity order;

  const OrderSuccess({required this.message, required this.order});

  @override
  List<Object> get props => [message, order];
}

class OrderError extends PerfumeState {
  final String message;

  const OrderError({required this.message});

  @override
  List<Object> get props => [message];
}

class OrderPlacing extends PerfumeState {}