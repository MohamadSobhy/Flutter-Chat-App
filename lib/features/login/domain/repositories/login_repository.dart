import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/user.dart';

abstract class LoginRepository {
  //login with Google Account
  Future<Either<Failure, User>> signInWithGoogle();
  Future<Either<Failure, void>> signOutWithGoogle();
  Future<Either<Failure, User>> signInWithFacebook();

  //login with email and password
  Future<Either<Failure, User>> signInWithEmailAndPassword(
    String email,
    String password,
  );
  Future<Either<Failure, User>> signUpWithEmailAndPassword(User user);

  //common actions
  Future<Either<Failure, User>> getLoggedInUserData();
  Future<Either<Failure, String>> updateAccountInfo(User user);
  Future<Either<Failure, String>> deleteAccount(User user);
}
