import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../main.dart';
import '../../../../src/widgets/custom_app_bar_action.dart';
import '../bloc/login_bloc.dart';
import '../widgets/custom_input_field.dart';
import '../widgets/custom_submit_button.dart';
import 'update_info_page.dart';

class LoginPage extends StatefulWidget {
  static const String routeName = '/login';

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Text(
                    'Login',
                    style: Theme.of(context)
                        .textTheme
                        .title
                        .copyWith(fontSize: 35.0),
                  ),
                  const SizedBox(
                    height: 15.0,
                  ),
                  _buildLoginWithSocialMediaBody(context),
                  const SizedBox(
                    height: 15.0,
                  ),
                  CustomInputField(
                    controller: _emailController,
                    label: 'Email',
                    padding: 0.0,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  CustomInputField(
                    controller: _passwordController,
                    label: 'Password',
                    obsecureText: true,
                    keyboardType: TextInputType.visiblePassword,
                    suffixIcon: Icons.remove_red_eye,
                    padding: 0.0,
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  _buildLoginButton(context),
                  SizedBox(
                    height: 15.0,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Don\'t have an account? ',
                      ),
                      InkWell(
                        onTap: _openRegisterPage,
                        child: Text(
                          'Register',
                          style: Theme.of(context).textTheme.bodyText1.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.deepOrange,
                              ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginWithSocialMediaBody(context) {
    final screenSize = MediaQuery.of(context).size;
    return Column(
      children: [
        Text(
          'Access Account',
          style: TextStyle(
            fontSize: 16.0,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(
          height: 15.0,
        ),
        Container(
          height: screenSize.height * 0.08,
          width: screenSize.width * 0.5,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: CustomAppBarAction(
                  icon: FontAwesomeIcons.facebookF,
                  iconColor: Colors.blue,
                  onActionPressed: () => _signInUsingFacebook(context),
                ),
              ),
              Expanded(
                child: CustomAppBarAction(
                  icon: FontAwesomeIcons.google,
                  onActionPressed: () => _singInUsingGoogle(context),
                ),
              )
            ],
          ),
        ),
        const SizedBox(
          height: 15.0,
        ),
        Text(
          'or Login with Email',
        ),
      ],
    );
  }

  Widget _buildLoginButton(context) {
    return CustomSubmitButton(
      label: 'Login',
      onSubmit: () => _loginWithEmailAndPassword(context),
    );
  }

  void _openRegisterPage() {
    Routes.sailor.navigate(UpdateInfoPage.routeName, params: {
      'isSigningUp': true,
    });
  }

  void _singInUsingGoogle(BuildContext context) async {
    BlocProvider.of<LoginBloc>(context).add(SignInWithGoogleEvent());
  }

  void _signInUsingFacebook(BuildContext context) {
    BlocProvider.of<LoginBloc>(context).add(SignInWithFacebookEvent());
  }

  void _loginWithEmailAndPassword(context) {
    String email = _emailController.text.trim();
    String password = _passwordController.text;

    BlocProvider.of<LoginBloc>(context).add(
      SignInWithEmailAndPasswordEvent(email: email, password: password),
    );
  }
}
