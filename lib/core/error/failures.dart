import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

abstract class Failure extends Equatable {
  final String message;

  Failure({@required this.message});

  @override
  List<Object> get props => [message];
}

class ServerFailure extends Failure {
  ServerFailure({@required String message}) : super(message: message);
}

class CacheFailure extends Failure {
  CacheFailure({@required String message}) : super(message: message);
}

class NetworkFailure extends Failure {
  NetworkFailure({@required String message}) : super(message: message);
}

class UserNotFoundFailure extends Failure {
  UserNotFoundFailure({@required String message}) : super(message: message);
}

class InputFailure extends Failure {
  InputFailure({@required String message}) : super(message: message);
}
