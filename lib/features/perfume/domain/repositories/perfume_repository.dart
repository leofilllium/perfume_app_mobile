import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:perfume_app_mobile/core/error/failures.dart';
import 'package:perfume_app_mobile/features/profile/domain/entities/order.dart';
import '../entities/perfume.dart';

class PerfumeList extends Equatable {
  final List<Perfume> perfumes;
  final int totalCount;
  final int currentPage;
  final int totalPages;

  const PerfumeList({
    required this.perfumes,
    required this.totalCount,
    required this.currentPage,
    required this.totalPages,
  });

  @override
  List<Object> get props => [perfumes, totalCount, currentPage, totalPages];
}


class RecommendedPerfumeList extends PerfumeList {
  final bool hasCompletedQuiz;

  const RecommendedPerfumeList({
    required List<Perfume> perfumes,
    required int totalCount,
    required int currentPage,
    required int totalPages,
    required this.hasCompletedQuiz,
  }) : super(
    perfumes: perfumes,
    totalCount: totalCount,
    currentPage: currentPage,
    totalPages: totalPages,
  );

  @override
  List<Object> get props => [
    ...super.props,
    hasCompletedQuiz,
  ];
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

  Future<Either<Failure, RecommendedPerfumeList>> getRecommendedPerfumes({
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