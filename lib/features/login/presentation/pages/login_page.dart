import 'dart:io';

import 'package:chat_app/features/login/data/models/user_model.dart';
import 'package:chat_app/features/login/domain/entities/user.dart';
import 'package:chat_app/injection_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../src/widgets/custom_app_bar_action.dart';
import '../bloc/login_bloc.dart';
import '../widgets/custom_input_field.dart';

class LoginPage extends StatefulWidget {
  static const String routeName = '/login';

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  bool isSigningIn = true;
  String _selectedImagePath;

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
                    isSigningIn ? 'Login' : 'Register',
                    style: Theme.of(context)
                        .textTheme
                        .title
                        .copyWith(fontSize: 30.0),
                  ),
                  const SizedBox(
                    height: 15.0,
                  ),
                  isSigningIn ? _getLoginPageBody(context) : Container(),
                  !isSigningIn ? _buildImageAvatarWithName() : Container(),
                  const SizedBox(
                    height: 15.0,
                  ),
                  CustomInputField(
                    controller: _emailController,
                    label: 'Email',
                    padding: 0.0,
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
                  !isSigningIn ? _buildRegisterPageBody() : Container(),
                  _buildLoginButton(context),
                  SizedBox(
                    height: 15.0,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        isSigningIn
                            ? 'Don\'t have an account? '
                            : 'Have an account? ',
                      ),
                      InkWell(
                        onTap: () {
                          setState(() {
                            isSigningIn = !isSigningIn;
                          });
                        },
                        child: Text(
                          isSigningIn ? 'Register' : 'Sign in',
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

  Widget _buildImageAvatarWithName() {
    return Column(
      children: [
        InkWell(
          onTap: _chooseImageFromGallery,
          child: CircleAvatar(
            radius: 80.0,
            backgroundColor: Colors.transparent,
            backgroundImage: _selectedImagePath != null
                ? FileImage(File(_selectedImagePath))
                : AssetImage('assets/images/icon_user.png'),
          ),
        ),
        CustomInputField(
          label: 'Name',
          controller: _nameController,
          padding: 0.0,
        ),
      ],
    );
  }

  Widget _getLoginPageBody(context) {
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
          height: screenSize.height * 0.12,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                child: CustomAppBarAction(
                  icon: FontAwesomeIcons.facebookF,
                  iconColor: Colors.blue,
                  onActionPressed: () {},
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

  Widget _buildRegisterPageBody() {
    return Column(
      children: [
        CustomInputField(
          label: 'Phone Number',
          padding: 0.0,
          controller: _phoneNumberController,
          keyboardType: TextInputType.phone,
        ),
      ],
    );
  }

  Widget _buildLoginButton(context) {
    return Container(
      height: 60.0,
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 15.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15.0),
        color: Theme.of(context).primaryColor,
        boxShadow: [
          BoxShadow(
            color: Colors.grey[200],
            spreadRadius: 2,
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15.0),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _loginWithEmailAndPassword(context),
            child: Center(
              child: Text(
                isSigningIn ? 'Sign in' : 'Register',
                style: Theme.of(context).textTheme.title,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _singInUsingGoogle(BuildContext context) async {
    BlocProvider.of<LoginBloc>(context).add(SignInWithGoogleEvent());
  }

  void _chooseImageFromGallery() async {
    _selectedImagePath =
        (await ImagePicker.pickImage(source: ImageSource.gallery)).path;
    setState(() {});
  }

  void _loginWithEmailAndPassword(context) {
    String email = _emailController.text.trim();
    String password = _passwordController.text;

    final userData = UserModel(
      id: 'TEMP',
      displayName: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      phoneNumber: _phoneNumberController.text.trim(),
      photoUrl: _selectedImagePath,
    );

    BlocProvider.of<LoginBloc>(context).add(
      isSigningIn
          ? SignInWithEmailAndPasswordEvent(email: email, password: password)
          : SignUpWithEmailAndPasswordEvent(user: userData),
    );
  }
}
