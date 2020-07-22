part of 'login_bloc.dart';

abstract class LoginEvent extends Equatable {
  const LoginEvent();
}

class SignInWithGoogleEvent extends LoginEvent {
  @override
  List<Object> get props => [];
}

class SignInWithFacebookEvent extends LoginEvent {
  @override
  List<Object> get props => [];
}

class SignInWithEmailAndPasswordEvent extends LoginEvent {
  final String email;
  final String password;

  SignInWithEmailAndPasswordEvent({
    @required this.email,
    @required this.password,
  });

  @override
  List<Object> get props => [email, password];
}

class SignUpWithEmailAndPasswordEvent extends LoginEvent {
  final User user;

  SignUpWithEmailAndPasswordEvent({@required this.user});

  @override
  List<Object> get props => [user];
}

class UpdateAccountInfoEvent extends LoginEvent {
  final User user;

  UpdateAccountInfoEvent({@required this.user});

  @override
  List<Object> get props => [user];
}

class DeleteAccountInfoEvent extends LoginEvent {
  final User user;

  DeleteAccountInfoEvent({@required this.user});

  @override
  List<Object> get props => [user];
}

class SignOutWithGoogleEvent extends LoginEvent {
  @override
  List<Object> get props => [];
}

class CheckLoggedInStateEvent extends LoginEvent {
  @override
  List<Object> get props => [];
}
