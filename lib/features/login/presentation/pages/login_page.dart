import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/login_bloc.dart';

class LoginPage extends StatelessWidget {
  static const String routeName = '/login';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: RaisedButton(
          onPressed: () => _singInUsingGoogle(context),
          color: Colors.redAccent,
          padding: const EdgeInsets.symmetric(
            horizontal: 20.0,
            vertical: 10.0,
          ),
          child: Text(
            'Sign In with Google!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20.0,
            ),
          ),
        ),
      ),
    );
  }

  void _singInUsingGoogle(BuildContext context) async {
    BlocProvider.of<LoginBloc>(context).add(SignInWithGoogleEvent());
  }
}
