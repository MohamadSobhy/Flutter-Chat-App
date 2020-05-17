import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:chat_app/core/usecases/usecase.dart';
import 'package:chat_app/features/login/domain/entities/user.dart';
import 'package:chat_app/features/login/domain/usecases/get_logged_in_user_data.dart';
import 'package:chat_app/features/login/domain/usecases/sign_in_with_google.dart';
import 'package:chat_app/features/login/domain/usecases/sign_out_with_google.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final SignInWithGoogle signInWithGoogle;
  final SignOutWithGoogle signOutWithGoogle;
  final GetLoggedInUserData getLoggedInUserData;

  LoginBloc({
    @required this.signInWithGoogle,
    @required this.signOutWithGoogle,
    @required this.getLoggedInUserData,
  });

  @override
  LoginState get initialState => InitialState();

  @override
  Stream<LoginState> mapEventToState(
    LoginEvent event,
  ) async* {
    if (event is SignInWithGoogleEvent) {
      yield LoadingState();

      final signInGoogleEither = await signInWithGoogle(NoParam());

      yield signInGoogleEither.fold(
        (failure) => ErrorState(message: failure.message),
        (userData) => LoggedInState(user: userData),
      );
    } else if (event is SignOutWithGoogleEvent) {
      yield LoadingState();

      final signOutGoogleEither = await signOutWithGoogle(NoParam());

      yield signOutGoogleEither.fold(
        (failure) => ErrorState(message: failure.message),
        (_) => LoggedOutState(),
      );
    } else if (event is CheckLoggedInStateEvent) {
      yield LoadingState();

      final loggedInStateEither = await getLoggedInUserData(NoParam());

      yield loggedInStateEither.fold(
        (failure) => AlertMessageState(message: failure.message),
        (userData) => LoggedInState(user: userData),
      );
    }
  }
}
