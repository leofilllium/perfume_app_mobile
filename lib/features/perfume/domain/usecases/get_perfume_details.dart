import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/perfume.dart';
import '../repositories/perfume_repository.dart';

class GetPerfumeDetails extends UseCase<Perfume, GetPerfumeDetailsParams> {
  final PerfumeRepository repository;

  GetPerfumeDetails(this.repository);

  @override
  Future<Either<Failure, Perfume>> call(GetPerfumeDetailsParams params) async {
    return await repository.getPerfumeDetails(
      id: params.id
    );
  }
}

class GetPerfumeDetailsParams extends Equatable {
  final int id;

  const GetPerfumeDetailsParams({
    required this.id
  });

  @override
  List<Object?> get props => [
    id
  ];
}