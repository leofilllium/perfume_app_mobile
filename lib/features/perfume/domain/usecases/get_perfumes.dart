import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/perfume_repository.dart';

class GetPerfumes extends UseCase<PerfumeList, GetPerfumesParams> {
  final PerfumeRepository repository;

  GetPerfumes(this.repository);

  @override
  Future<Either<Failure, PerfumeList>> call(GetPerfumesParams params) async {
    return await repository.getPerfumes(
      gender: params.gender,
      searchQuery: params.searchQuery,
      minPrice: params.minPrice,
      maxPrice: params.maxPrice,
      page: params.page,
      pageSize: params.pageSize,
    );
  }
}

class GetPerfumesParams extends Equatable {
  final String? gender;
  final String? searchQuery;
  final double? minPrice;
  final double? maxPrice;
  final int? page;
  final int? pageSize;

  const GetPerfumesParams({
    this.gender,
    this.searchQuery,
    this.minPrice,
    this.maxPrice,
    this.page,
    this.pageSize,
  });

  @override
  List<Object?> get props => [
    gender,
    searchQuery,
    minPrice,
    maxPrice,
    page,
    pageSize,
  ];
}