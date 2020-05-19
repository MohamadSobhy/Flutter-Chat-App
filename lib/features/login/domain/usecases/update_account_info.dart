import 'package:dartz/dartz.dart';
import 'package:meta/meta.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user.dart';
import '../repositories/login_repository.dart';

class UpdateAccountInfo extends UseCase<String, User> {
  final LoginRepository repository;

  UpdateAccountInfo({@required this.repository});
  @override
  Future<Either<Failure, String>> call(User user) {
    return repository.updateAccountInfo(user);
  }
}
