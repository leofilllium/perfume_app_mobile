import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:perfume_app_mobile/features/perfume/domain/entities/perfume.dart';
import 'package:perfume_app_mobile/features/profile/data/models/order_model.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/get_perfumes.dart';
import '../../domain/usecases/place_order.dart';
import '../../domain/repositories/perfume_repository.dart';
import 'perfume_event.dart';
import 'perfume_state.dart';

const String SERVER_FAILURE_MESSAGE = 'Server Failure';
const String CACHE_FAILURE_MESSAGE = 'Cache Failure';
const String NETWORK_FAILURE_MESSAGE = 'Network Failure';
const String UNAUTHORIZED_MESSAGE = 'Please log in to place an order.';

class PerfumeBloc extends Bloc<PerfumeEvent, PerfumeState> {
  final GetPerfumes getPerfumes;
  final PlaceOrder placeOrder;
  final PerfumeRepository perfumeRepository;

  // Added to keep track of the last successfully loaded perfume state
  PerfumeLoaded? _lastPerfumeLoadedState;

  PerfumeBloc({
    required this.getPerfumes,
    required this.placeOrder,
    required this.perfumeRepository,
  }) : super(PerfumeInitial()) {
    on<GetPerfumesEvent>(_onGetPerfumes);
    on<PlaceOrderEvent>(_onPlaceOrder);
  }

  Future<void> _onGetPerfumes(
      GetPerfumesEvent event,
      Emitter<PerfumeState> emit,
      ) async {
    // Determine if this is an initial load or fetching more
    final isFetchingMore = state is PerfumeLoaded && event.page > 1;

    if (!isFetchingMore) {
      emit(PerfumeLoading()); // Only show full screen loader for initial load
    } else if (state is PerfumeLoaded && (state as PerfumeLoaded).isFetchingMore) {
      return; // Already fetching more, prevent duplicate requests
    } else if (state is PerfumeLoaded && (state as PerfumeLoaded).hasReachedMax) {
      return; // All items loaded, do nothing
    } else if (state is PerfumeLoaded) {
      // Indicate that more are being fetched at the bottom of the list
      emit((state as PerfumeLoaded).copyWith(isFetchingMore: true));
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
        if (isFetchingMore && state is PerfumeLoaded) {
          emit((state as PerfumeLoaded).copyWith(isFetchingMore: false));
        } else {
          emit(PerfumeError(message: _mapFailureToMessage(failure)));
        }
      },
          (newPerfumeList) {
        if (isFetchingMore && state is PerfumeLoaded) {
          final currentPerfumes = (state as PerfumeLoaded).perfumeList.perfumes;
          final updatedPerfumes = List<Perfume>.from(currentPerfumes)
            ..addAll(newPerfumeList.perfumes);

          final hasReachedMax = newPerfumeList.currentPage >= newPerfumeList.totalPages;

          final newState = PerfumeLoaded(
            perfumeList: PerfumeList(
              perfumes: updatedPerfumes,
              totalCount: newPerfumeList.totalCount,
              currentPage: newPerfumeList.currentPage,
              totalPages: newPerfumeList.totalPages,
            ),
            hasReachedMax: hasReachedMax,
            isFetchingMore: false,
          );
          emit(newState);
          _lastPerfumeLoadedState = newState; // Store the new loaded state
        } else {
          // Initial load
          final hasReachedMax = newPerfumeList.currentPage >= newPerfumeList.totalPages;
          final newState = PerfumeLoaded(
            perfumeList: newPerfumeList,
            hasReachedMax: hasReachedMax,
            isFetchingMore: false,
          );
          emit(newState);
          _lastPerfumeLoadedState = newState; // Store the initial loaded state
        }
      },
    );
  }

  Future<void> _onPlaceOrder(
      PlaceOrderEvent event,
      Emitter<PerfumeState> emit,
      ) async {
    final tokenEither = await perfumeRepository.getAuthToken();

    await tokenEither.fold(
          (failure) async {
        emit(OrderError(message: _mapFailureToMessage(failure)));
        // Re-emit the last loaded state after an order error to restore list view
        if (_lastPerfumeLoadedState != null) {
          emit(_lastPerfumeLoadedState!);
        }
      },
          (token) async {
        if (token == null || token.isEmpty) {
          emit(const OrderError(message: UNAUTHORIZED_MESSAGE));
          // Re-emit the last loaded state if unauthorized
          if (_lastPerfumeLoadedState != null) {
            emit(_lastPerfumeLoadedState!);
          }
          return;
        }

        emit(OrderPlacing());
        final result = await placeOrder(PlaceOrderParams(
          perfumeId: event.orderedPerfume.id, // Use ID from the passed perfume
          quantity: event.quantity,
          orderMessage: event.orderMessage,
          token: token,
        ));
        result.fold(
              (failure) {
            emit(OrderError(message: _mapFailureToMessage(failure)));
            // Re-emit the last loaded state after an order error to restore list view
            if (_lastPerfumeLoadedState != null) {
              emit(_lastPerfumeLoadedState!);
            }
          },
              (createdOrder) { // This `createdOrder` is already an OrderEntity (or OrderModel)
            // No need to call fromJson again.
            // Use copyWith on the received OrderEntity to inject the full Perfume object.
            final completeOrder = createdOrder.copyWith(perfume: event.orderedPerfume);

            emit(OrderSuccess(message: 'Order placed successfully!', order: completeOrder));
            // Re-emit the last loaded state after order success to restore list view
            if (_lastPerfumeLoadedState != null) {
              emit(_lastPerfumeLoadedState!);
            }
          },
        );
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