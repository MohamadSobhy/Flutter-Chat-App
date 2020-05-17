import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../features/login/domain/entities/user.dart';
import '../error/failures.dart';

abstract class UseCase<Type, Param> {
  Future<Either<Failure, Type>> call(Param params);
}

class NoParam extends Equatable {
  @override
  List<Object> get props => [];
}
