import 'package:equatable/equatable.dart';

abstract class RecommendationEvent extends Equatable {
  const RecommendationEvent();

  @override
  List<Object> get props => [];
}

class GetRecommendedPerfumesEvent extends RecommendationEvent {
  final int page;
  final int pageSize;

  const GetRecommendedPerfumesEvent({
    this.page = 1,
    this.pageSize = 10,
  });

  @override
  List<Object> get props => [page, pageSize];
}
