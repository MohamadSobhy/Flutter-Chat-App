import 'package:dartz/dartz.dart';
import 'package:meta/meta.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user.dart';
import '../repositories/login_repository.dart';

class GetLoggedInUserData extends UseCase<User, NoParam> {
  final LoginRepository repository;

  GetLoggedInUserData({@required this.repository});

  @override
  Future<Either<Failure, User>> call(NoParam params) {
    return repository.getLoggedInUserData();
  }
}
