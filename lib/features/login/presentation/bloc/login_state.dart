part of 'login_bloc.dart';

abstract class LoginState extends Equatable {
  const LoginState();
}

class InitialState extends LoginState {
  @override
  List<Object> get props => [];
}

class LoggedInState extends LoginState {
  final User user;

  LoggedInState({@required this.user});

  @override
  List<Object> get props => [user];
}

class LoggedOutState extends LoginState {
  @override
  List<Object> get props => [];
}

class LoadingState extends LoginState {
  @override
  List<Object> get props => [];
}

class ErrorState extends LoginState {
  final String message;

  ErrorState({@required this.message});

  @override
  List<Object> get props => [message];
}

class AlertMessageState extends LoginState {
  final String message;

  AlertMessageState({@required this.message});

  @override
  List<Object> get props => [message];
}

class AccountDeletedState extends LoginState {
  @override
  List<Object> get props => [];
}

class SignedUpWithEmailState extends LoginState {
  @override
  List<Object> get props => [];
}
