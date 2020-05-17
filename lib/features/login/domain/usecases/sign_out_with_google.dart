import 'package:dartz/dartz.dart';
import 'package:meta/meta.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/login_repository.dart';

class SignOutWithGoogle extends UseCase<void, NoParam> {
  final LoginRepository repository;

  SignOutWithGoogle({@required this.repository});

  @override
  Future<Either<Failure, void>> call(NoParam params) {
    return repository.signOutWithGoogle();
  }
}
