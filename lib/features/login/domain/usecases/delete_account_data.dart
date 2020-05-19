import 'package:chat_app/core/error/failures.dart';
import 'package:chat_app/core/usecases/usecase.dart';
import 'package:chat_app/features/login/domain/entities/user.dart';
import 'package:chat_app/features/login/domain/repositories/login_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:meta/meta.dart';

class DeleteAccountData extends UseCase<String, User> {
  final LoginRepository repository;

  DeleteAccountData({@required this.repository});

  @override
  Future<Either<Failure, String>> call(User user) {
    return repository.deleteAccount(user);
  }
}
