import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:perfume_app_mobile/features/perfume/domain/entities/perfume.dart';
import 'package:perfume_app_mobile/features/perfume/domain/repositories/perfume_repository.dart';
import 'package:perfume_app_mobile/features/perfume/domain/usecases/get_recommended_perfumes.dart';
import '../../../../../core/error/failures.dart';
import 'recommendation_event.dart';
import 'recommendation_state.dart';

const String SERVER_FAILURE_MESSAGE = 'Server Failure';
const String CACHE_FAILURE_MESSAGE = 'Cache Failure';
const String NETWORK_FAILURE_MESSAGE = 'Network Failure';
const String UNAUTHORIZED_RECOMMENDATIONS_MESSAGE = 'Please log in to view personalized recommendations.';

class RecommendationBloc extends Bloc<RecommendationEvent, RecommendationState> {
  final GetRecommendedPerfumes getRecommendedPerfumes;

  RecommendationBloc({
    required this.getRecommendedPerfumes,
  }) : super(RecommendationInitial()) {
    on<GetRecommendedPerfumesEvent>(_onGetRecommendedPerfumes);
  }

  Future<void> _onGetRecommendedPerfumes(
      GetRecommendedPerfumesEvent event,
      Emitter<RecommendationState> emit,
      ) async {
    // Determine if this is an initial load or fetching more
    final isFetchingMore = state is RecommendedPerfumesLoaded && event.page > 1;

    if (!isFetchingMore) {
      emit(RecommendedPerfumesLoading());
    } else if (state is RecommendedPerfumesLoaded && (state as RecommendedPerfumesLoaded).isFetchingMore) {
      return; // Already fetching more, prevent duplicate requests
    } else if (state is RecommendedPerfumesLoaded && (state as RecommendedPerfumesLoaded).hasReachedMax) {
      return; // All items loaded, do nothing
    } else if (state is RecommendedPerfumesLoaded) {
      // Indicate that more are being fetched at the bottom of the list
      emit((state as RecommendedPerfumesLoaded).copyWith(isFetchingMore: true));
    }

    final result = await getRecommendedPerfumes(GetRecommendedPerfumesParams(
      page: event.page,
      pageSize: event.pageSize,
    ));

    result.fold(
          (failure) {
        if (failure is ServerFailure && failure.message == UNAUTHORIZED_RECOMMENDATIONS_MESSAGE) {
          emit(RecommendationError(message: UNAUTHORIZED_RECOMMENDATIONS_MESSAGE));
        } else if (isFetchingMore && state is RecommendedPerfumesLoaded) {
          emit((state as RecommendedPerfumesLoaded).copyWith(isFetchingMore: false));
        } else {
          emit(RecommendationError(message: _mapFailureToMessage(failure)));
        }
      },
          (recommendedPerfumeList) {
        if (!recommendedPerfumeList.hasCompletedQuiz) {
          emit(const QuizNotCompletedState());
          return;
        }

        if (isFetchingMore && state is RecommendedPerfumesLoaded) {
          final currentPerfumes = (state as RecommendedPerfumesLoaded).perfumeList.perfumes;
          final updatedPerfumes = List<Perfume>.from(currentPerfumes)
            ..addAll(recommendedPerfumeList.perfumes);

          final hasReachedMax = recommendedPerfumeList.currentPage >= recommendedPerfumeList.totalPages;

          emit(RecommendedPerfumesLoaded(
            perfumeList: PerfumeList(
              perfumes: updatedPerfumes,
              totalCount: recommendedPerfumeList.totalCount,
              currentPage: recommendedPerfumeList.currentPage,
              totalPages: recommendedPerfumeList.totalPages,
            ),
            hasReachedMax: hasReachedMax,
            isFetchingMore: false,
            hasCompletedQuiz: true,
          ));
        } else {
          final hasReachedMax = recommendedPerfumeList.currentPage >= recommendedPerfumeList.totalPages;
          emit(RecommendedPerfumesLoaded(
            perfumeList: recommendedPerfumeList,
            hasReachedMax: hasReachedMax,
            isFetchingMore: false,
            hasCompletedQuiz: true,
          ));
        }
      },
    );
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        final serverFailure = failure as ServerFailure;
        return serverFailure.message ?? SERVER_FAILURE_MESSAGE;
      case CacheFailure:
        return CACHE_FAILURE_MESSAGE;
      case NetworkFailure:
        return NETWORK_FAILURE_MESSAGE;
      default:
        return 'Unexpected error';
    }
  }
}