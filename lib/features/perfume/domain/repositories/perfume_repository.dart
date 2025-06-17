import 'package:dartz/dartz.dart';
import 'package:perfume_app_mobile/core/error/failures.dart';
import 'package:perfume_app_mobile/features/profile/domain/entities/order.dart';
import '../entities/perfume.dart';

class PerfumeList {
  final List<Perfume> perfumes;
  final int totalCount;
  final int currentPage; // New field (added here for clarity)
  final int totalPages;

  PerfumeList({
    required this.perfumes,
    required this.totalCount,
    required this.currentPage, // Added for clarity
    required this.totalPages,
  });
}

abstract class PerfumeRepository {
  Future<Either<Failure, PerfumeList>> getPerfumes({
    String? gender,
    String? searchQuery,
    double? minPrice,
    double? maxPrice,
    int? page,
    int? pageSize,
  });

  Future<Either<Failure, OrderEntity>> placeOrder({
    required int perfumeId,
    required int quantity,
    String? orderMessage,
    required String token,
  });

  Future<Either<Failure, String?>> getAuthToken();
}