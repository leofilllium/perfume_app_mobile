import 'package:equatable/equatable.dart';

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

class GetPerfumeDetailsEvent extends PerfumeEvent {
  final int id;

  const GetPerfumeDetailsEvent({required this.id});

  @override
  List<Object> get props => [id];
}
