import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user.dart';
import '../repositories/login_repository.dart';

class SignInWithEmailAndPassword extends UseCase<User, LoginParams> {
  final LoginRepository repository;

  SignInWithEmailAndPassword({@required this.repository});

  @override
  Future<Either<Failure, User>> call(LoginParams params) {
    return repository.signInWithEmailAndPassword(params.email, params.password);
  }
}

class LoginParams extends Equatable {
  final String email;
  final String password;

  LoginParams({@required this.email, @required this.password});

  @override
  List<Object> get props => [email, password];
}
