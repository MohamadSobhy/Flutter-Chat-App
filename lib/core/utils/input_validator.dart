import 'package:chat_app/core/error/failures.dart';
import 'package:dartz/dartz.dart';

class InputValidator {
  Either<Failure, bool> validateEmail(String email) {
    String emailReges =
        "^[a-zA-Z0-9.!#\$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*\$";
    final isValid = RegExp(emailReges).hasMatch(email);

    if (isValid) {
      return Right(isValid);
    } else {
      return Left(
        InputFailure(message: 'Please, enter a valid email address.'),
      );
    }
  }

  Either<Failure, bool> validatePassword(String password) {
    final isValid = password.length >= 6;
    if (isValid) {
      return Right(isValid);
    } else {
      return Left(InputFailure(message: 'Please, enter a valid password.'));
    }
  }
}
