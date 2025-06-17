// features/perfume/domain/usecases/get_recommended_perfumes.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/perfume_repository.dart';

class GetRecommendedPerfumes extends UseCase<RecommendedPerfumeList, GetRecommendedPerfumesParams> {
  final PerfumeRepository repository;

  GetRecommendedPerfumes(this.repository);

  @override
  Future<Either<Failure, RecommendedPerfumeList>> call(GetRecommendedPerfumesParams params) async {
    return await repository.getRecommendedPerfumes(
      page: params.page,
      pageSize: params.pageSize,
    );
  }
}

class GetRecommendedPerfumesParams extends Equatable {
  final int page;
  final int pageSize;

  const GetRecommendedPerfumesParams({
    this.page = 1,
    this.pageSize = 10,
  });

  @override
  List<Object> get props => [page, pageSize];
}