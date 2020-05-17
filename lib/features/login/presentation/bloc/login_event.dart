part of 'login_bloc.dart';

abstract class LoginEvent extends Equatable {
  const LoginEvent();
}

class SignInWithGoogleEvent extends LoginEvent {
  @override
  List<Object> get props => [];
}

class SignOutWithGoogleEvent extends LoginEvent {
  @override
  List<Object> get props => [];
}

class CheckLoggedInStateEvent extends LoginEvent {
  @override
  List<Object> get props => [];
}
