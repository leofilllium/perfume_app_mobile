import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:perfume_app_mobile/features/perfume/domain/entities/perfume.dart';
import 'package:perfume_app_mobile/features/perfume/domain/repositories/perfume_repository.dart';
import '../../../../../core/error/failures.dart';
import '../../../domain/usecases/place_order.dart';
import 'order_event.dart';
import 'order_state.dart';

const String SERVER_FAILURE_MESSAGE = 'Server Failure';
const String CACHE_FAILURE_MESSAGE = 'Cache Failure';
const String NETWORK_FAILURE_MESSAGE = 'Network Failure';
const String UNAUTHORIZED_MESSAGE = 'Please log in to place an order.';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final PlaceOrder placeOrder;
  final PerfumeRepository perfumeRepository;

  OrderBloc({
    required this.placeOrder,
    required this.perfumeRepository,
  }) : super(OrderInitial()) {
    on<PlaceOrderEvent>(_onPlaceOrder);
    on<ResetOrderEvent>(_onResetOrder);
  }

  Future<void> _onPlaceOrder(
      PlaceOrderEvent event,
      Emitter<OrderState> emit,
      ) async {
    final tokenEither = await perfumeRepository.getAuthToken();

    await tokenEither.fold(
          (failure) async {
        emit(OrderError(message: _mapFailureToMessage(failure)));
      },
          (token) async {
        if (token == null || token.isEmpty) {
          emit(const OrderError(message: UNAUTHORIZED_MESSAGE));
          return;
        }

        emit(OrderPlacing());
        final result = await placeOrder(PlaceOrderParams(
          perfumeId: event.orderedPerfume.id,
          quantity: event.quantity,
          orderMessage: event.orderMessage,
          token: token,
        ));

        result.fold(
              (failure) {
            emit(OrderError(message: _mapFailureToMessage(failure)));
          },
              (createdOrder) {
            final completeOrder = createdOrder.copyWith(perfume: event.orderedPerfume);
            emit(OrderSuccess(message: 'Order placed successfully!', order: completeOrder));
          },
        );
      },
    );
  }

  void _onResetOrder(
      ResetOrderEvent event,
      Emitter<OrderState> emit,
      ) {
    emit(OrderInitial());
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