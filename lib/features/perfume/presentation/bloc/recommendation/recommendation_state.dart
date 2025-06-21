import 'package:equatable/equatable.dart';
import '../../../domain/entities/perfume.dart';
import '../../../domain/repositories/perfume_repository.dart';

abstract class RecommendationState extends Equatable {
  const RecommendationState();

  @override
  List<Object> get props => [];
}

class RecommendationInitial extends RecommendationState {}

class RecommendedPerfumesLoading extends RecommendationState {}

class RecommendedPerfumesLoaded extends RecommendationState {
  final PerfumeList perfumeList;
  final bool hasReachedMax;
  final bool isFetchingMore;
  final bool hasCompletedQuiz;

  const RecommendedPerfumesLoaded({
    required this.perfumeList,
    this.hasReachedMax = false,
    this.isFetchingMore = false,
    this.hasCompletedQuiz = true,
  });

  RecommendedPerfumesLoaded copyWith({
    PerfumeList? perfumeList,
    bool? hasReachedMax,
    bool? isFetchingMore,
    bool? hasCompletedQuiz,
  }) {
    return RecommendedPerfumesLoaded(
      perfumeList: perfumeList ?? this.perfumeList,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isFetchingMore: isFetchingMore ?? this.isFetchingMore,
      hasCompletedQuiz: hasCompletedQuiz ?? this.hasCompletedQuiz,
    );
  }

  @override
  List<Object> get props => [perfumeList, hasReachedMax, isFetchingMore, hasCompletedQuiz];
}

class RecommendationError extends RecommendationState {
  final String message;

  const RecommendationError({required this.message});

  @override
  List<Object> get props => [message];
}

class QuizNotCompletedState extends RecommendationState {
  const QuizNotCompletedState();

  @override
  List<Object> get props => [];
}