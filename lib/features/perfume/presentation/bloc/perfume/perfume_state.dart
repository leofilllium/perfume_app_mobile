import 'package:equatable/equatable.dart';
import '../../../domain/entities/perfume.dart';
import '../../../domain/repositories/perfume_repository.dart';

abstract class PerfumeState extends Equatable {
  const PerfumeState();

  @override
  List<Object> get props => [];
}

class PerfumeInitial extends PerfumeState {}

class AllPerfumesLoading extends PerfumeState {}

class PerfumeDetailsLoading extends PerfumeState {}

class PerfumeDetailsLoaded extends PerfumeState {
  final Perfume perfume;

  const PerfumeDetailsLoaded(this.perfume);

  @override
  List<Object> get props => [perfume];
}

class AllPerfumesLoaded extends PerfumeState {
  final PerfumeList perfumeList;
  final bool hasReachedMax;
  final bool isFetchingMore;

  const AllPerfumesLoaded({
    required this.perfumeList,
    this.hasReachedMax = false,
    this.isFetchingMore = false,
  });

  AllPerfumesLoaded copyWith({
    PerfumeList? perfumeList,
    bool? hasReachedMax,
    bool? isFetchingMore,
  }) {
    return AllPerfumesLoaded(
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