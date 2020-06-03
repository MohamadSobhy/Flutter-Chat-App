import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:chat_app/features/login/data/datasources/login_local_data_source.dart';
import 'package:chat_app/src/widgets/custom_app_bar_action.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../injection_container.dart';
import '../../data/models/user_model.dart';
import '../bloc/login_bloc.dart';
import '../widgets/custom_input_field.dart';
import '../widgets/custom_submit_button.dart';

class UpdateInfoPage extends StatefulWidget {
  static const String routeName = '/update-info';
  final bool isSigningUp;

  const UpdateInfoPage({this.isSigningUp});

  @override
  _UpdateInfoPageState createState() => _UpdateInfoPageState();
}

class _UpdateInfoPageState extends State<UpdateInfoPage> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _phoneNumberController = TextEditingController();
  String _selectedImagePath;
  bool _isNewImageChoosed = false;
  bool _isLoggedInWithEmailAndPassword;
  UserModel userData;
  bool _isLoading = false;

  @override
  void initState() {
    _initialzeContentWithUserData();

    super.initState();
  }

  void _initialzeContentWithUserData() {
    if (widget.isSigningUp == null) {
      final preferences = serviceLocator<SharedPreferences>();
      userData = UserModel.fromJson(
        json.decode(
          preferences.getString('user'),
        ),
      );
      _nameController.text = userData.displayName;
      _emailController.text = userData.email;
      _passwordController.text = userData.password;
      _phoneNumberController.text = userData.phoneNumber;
      _selectedImagePath = userData.photoUrl;

      _isLoggedInWithEmailAndPassword =
          LoginMethod.values[preferences.getInt('login_method')] ==
              LoginMethod.emailAndPassword;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return ModalProgressHUD(
      inAsyncCall: _isLoading,
      child: Scaffold(
        body: Stack(
          children: [
            Container(
              color: Theme.of(context).primaryColor,
              height: screenSize.height,
              width: screenSize.width,
            ),
            Positioned(
              top: 30.0,
              child: CustomAppBarAction(
                height: 45.0,
                icon: Icons.arrow_back_ios,
                onActionPressed: _goBack, //_goBack,
              ),
            ),
            widget.isSigningUp == null
                ? Positioned(
                    top: 30.0,
                    right: 0.0,
                    child: CustomAppBarAction(
                      height: 45.0,
                      icon: Icons.done,
                      onActionPressed: () =>
                          _updateProfileInfo(context), //_goToEditProfileScreen,
                    ),
                  )
                : Container(),
            Positioned(
              top: screenSize.height * 0.25,
              child: Container(
                width: screenSize.width,
                height: screenSize.height * 0.75,
                padding: EdgeInsets.only(
                  top: screenSize.height * 0.10,
                  left: 15.0,
                  right: 15.0,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).canvasColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(35.0),
                    topRight: Radius.circular(35.0),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(
                        height: screenSize.height * 0.05,
                      ),
                      widget.isSigningUp == null
                          ? Text(userData.email)
                          : Container(),
                      SizedBox(
                        height: screenSize.height * 0.05,
                      ),
                      CustomInputField(
                        label: 'Name',
                        controller: _nameController,
                        padding: 0.0,
                        keyboardType: TextInputType.text,
                      ),
                      const SizedBox(
                        height: 15.0,
                      ),
                      widget.isSigningUp != null
                          ? CustomInputField(
                              controller: _emailController,
                              label: 'Email',
                              padding: 0.0,
                              keyboardType: TextInputType.emailAddress,
                            )
                          : Container(),
                      widget.isSigningUp != null
                          ? const SizedBox(
                              height: 20.0,
                            )
                          : Container(),
                      _isLoggedInWithEmailAndPassword != null
                          ? _isLoggedInWithEmailAndPassword
                              ? CustomInputField(
                                  controller: _passwordController,
                                  label: 'Password',
                                  obsecureText: true,
                                  keyboardType: TextInputType.visiblePassword,
                                  suffixIcon: Icons.remove_red_eye,
                                  padding: 0.0,
                                )
                              : Container()
                          : Container(),
                      const SizedBox(
                        height: 20.0,
                      ),
                      CustomInputField(
                        label: 'Phone Number',
                        padding: 0.0,
                        controller: _phoneNumberController,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(
                        height: 20.0,
                      ),
                      widget.isSigningUp != null
                          ? CustomSubmitButton(
                              onSubmit: () => _createAccount(context),
                              label: 'Register',
                            )
                          : Container(),
                      widget.isSigningUp != null
                          ? _buildBackToSignInRow(context)
                          : Container(),
                      SizedBox(
                        height: 15.0,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: screenSize.height * 0.12,
              left: screenSize.width * 0.3,
              child: InkWell(
                onTap: _chooseImageFromGallery,
                child: CircleAvatar(
                  radius: 80.0,
                  backgroundColor: Colors.transparent,
                  backgroundImage: _selectedImagePath != null
                      ? _isNewImageChoosed
                          ? FileImage(File(_selectedImagePath))
                          : NetworkImage(userData.photoUrl)
                      : AssetImage('assets/images/icon_user.png'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Row _buildBackToSignInRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Have an account? ',
        ),
        InkWell(
          onTap: _goBack,
          child: Text(
            'Sign in',
            style: Theme.of(context).textTheme.bodyText1.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.deepOrange,
                ),
          ),
        ),
      ],
    );
  }

  void _goBack() {
    Navigator.of(context).pop();
  }

  void _chooseImageFromGallery() async {
    final image = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      _selectedImagePath = image.path;
      setState(() {
        _isNewImageChoosed = true;
      });
    }
  }

  void _createAccount(context) {
    final newUser = UserModel(
      id: 'TEMP',
      displayName: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      phoneNumber: _phoneNumberController.text.trim(),
      photoUrl: _selectedImagePath,
    );

    BlocProvider.of<LoginBloc>(context).add(
      SignUpWithEmailAndPasswordEvent(user: newUser),
    );
  }

  void _updateProfileInfo(context) {
    final newUser = UserModel(
      id: userData.id,
      displayName: _nameController.text.trim(),
      email: userData.email,
      password: _passwordController.text,
      phoneNumber: _phoneNumberController.text.trim(),
      photoUrl: _isNewImageChoosed
          ? _selectedImagePath + ' 1'
          : userData.photoUrl + ' 0',
    );
    setState(() {
      _isLoading = true;
    });

    final bloc = BlocProvider.of<LoginBloc>(context);
    if (subscription != null) subscription.cancel();
    subscription = bloc.listen((state) {
      if (state is AlertMessageState || state is ErrorState) {
        _isLoading = false;
      } else if (state is LoadingState) {
        print('start loading');
        _isLoading = true;
      }
      setState(() {});
    });
    bloc.add(
      UpdateAccountInfoEvent(user: newUser),
    );

    //_goBack();
  }

  StreamSubscription subscription;
  @override
  void dispose() {
    if (subscription != null) subscription.cancel();
    super.dispose();
  }
}
