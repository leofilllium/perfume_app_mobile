import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:perfume_app_mobile/features/perfume/domain/entities/perfume.dart';
import 'package:perfume_app_mobile/features/perfume/domain/repositories/perfume_repository.dart';
import 'package:perfume_app_mobile/features/perfume/domain/usecases/get_perfume_details.dart';
import '../../../../../core/error/failures.dart';
import '../../../domain/usecases/get_perfumes.dart';
import 'perfume_event.dart';
import 'perfume_state.dart';

const String SERVER_FAILURE_MESSAGE = 'Server Failure';
const String CACHE_FAILURE_MESSAGE = 'Cache Failure';
const String NETWORK_FAILURE_MESSAGE = 'Network Failure';

class PerfumeBloc extends Bloc<PerfumeEvent, PerfumeState> {
  final GetPerfumes getPerfumes;
  final GetPerfumeDetails getPerfumeDetails;

  PerfumeBloc({
    required this.getPerfumes,
    required this.getPerfumeDetails,
  }) : super(PerfumeInitial()) {
    on<GetPerfumesEvent>(_onGetPerfumes);
    on<GetPerfumeDetailsEvent>(_onGetPerfumeDetails);
  }

  Future<void> _onGetPerfumes(
      GetPerfumesEvent event,
      Emitter<PerfumeState> emit,
      ) async {
    // Determine if this is an initial load or fetching more
    final isFetchingMore = state is AllPerfumesLoaded && event.page > 1;

    if (!isFetchingMore) {
      emit(AllPerfumesLoading());
    } else if (state is AllPerfumesLoaded && (state as AllPerfumesLoaded).isFetchingMore) {
      return; // Already fetching more, prevent duplicate requests
    } else if (state is AllPerfumesLoaded && (state as AllPerfumesLoaded).hasReachedMax) {
      return; // All items loaded, do nothing
    } else if (state is AllPerfumesLoaded) {
      // Indicate that more are being fetched at the bottom of the list
      emit((state as AllPerfumesLoaded).copyWith(isFetchingMore: true));
    }

    final result = await getPerfumes(GetPerfumesParams(
      gender: event.gender,
      searchQuery: event.searchQuery,
      minPrice: event.minPrice,
      maxPrice: event.maxPrice,
      page: event.page,
      pageSize: event.pageSize,
    ));

    result.fold(
          (failure) {
        if (isFetchingMore && state is AllPerfumesLoaded) {
          emit((state as AllPerfumesLoaded).copyWith(isFetchingMore: false));
        } else {
          emit(PerfumeError(message: _mapFailureToMessage(failure)));
        }
      },
          (newPerfumeList) {
        if (isFetchingMore && state is AllPerfumesLoaded) {
          final currentPerfumes = (state as AllPerfumesLoaded).perfumeList.perfumes;
          final updatedPerfumes = List<Perfume>.from(currentPerfumes)
            ..addAll(newPerfumeList.perfumes);

          final hasReachedMax = newPerfumeList.currentPage >= newPerfumeList.totalPages;

          emit(AllPerfumesLoaded(
            perfumeList: PerfumeList(
              perfumes: updatedPerfumes,
              totalCount: newPerfumeList.totalCount,
              currentPage: newPerfumeList.currentPage,
              totalPages: newPerfumeList.totalPages,
            ),
            hasReachedMax: hasReachedMax,
            isFetchingMore: false,
          ));
        } else {
          // Initial load
          final hasReachedMax = newPerfumeList.currentPage >= newPerfumeList.totalPages;
          emit(AllPerfumesLoaded(
            perfumeList: newPerfumeList,
            hasReachedMax: hasReachedMax,
            isFetchingMore: false,
          ));
        }
      },
    );
  }

  Future<void> _onGetPerfumeDetails(
      GetPerfumeDetailsEvent event,
      Emitter<PerfumeState> emit,
      ) async {
    emit(PerfumeDetailsLoading());

    final result = await getPerfumeDetails(GetPerfumeDetailsParams(id: event.id));

    result.fold(
          (failure) {
        emit(PerfumeError(message: _mapFailureToMessage(failure)));
      },
          (perfume) {
        emit(PerfumeDetailsLoaded(perfume));
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