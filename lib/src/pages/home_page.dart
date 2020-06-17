import 'dart:convert';

import 'package:chat_app/features/login/data/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/login/domain/entities/user.dart';
import '../../features/login/presentation/bloc/login_bloc.dart';
import '../../features/login/presentation/pages/profile_page.dart';
import '../../injection_container.dart';
import '../../main.dart';
import '../widgets/custom_app_bar_action.dart';
import '../widgets/user_image_avatar.dart';
import '../widgets/user_item.dart';

class HomePage extends StatefulWidget {
  static const String routeName = '/dashboard';

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _userPhotoUrl;

  @override
  void initState() {
    final userJsonString =
        serviceLocator<SharedPreferences>().getString('user');
    if (userJsonString != null)
      _userPhotoUrl = UserModel.fromJson(json.decode(userJsonString)).photoUrl;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: screenSize.height,
            width: screenSize.width,
            color: Theme.of(context).primaryColor,
          ),
          Positioned(
            top: 30.0,
            child: CustomAppBarAction(
              icon: Icons.search,
              height: 45.0,
              onActionPressed: _openSearchScreen,
            ),
          ),
          Positioned(
            top: 30.0,
            right: 0.0,
            child: CustomAppBarAction(
              icon: Icons.settings,
              height: 45.0,
              onActionPressed: () => _openSettingsPage(context),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 30.0),
              child: Hero(
                tag: 'user-avatar',
                child: UserImageAvatar(
                  imageUrl: _userPhotoUrl,
                  onTap: _openProfilePage,
                ),
              ),
            ),
          ),
          Positioned(
            top: screenSize.height * 0.15,
            child: Container(
              width: screenSize.width,
              height: screenSize.height * 0.85,
              decoration: BoxDecoration(
                color: Theme.of(context).canvasColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(35.0),
                  topRight: Radius.circular(35.0),
                ),
              ),
              child: StreamBuilder(
                stream: Firestore.instance.collection('users').snapshots(),
                builder: (ctx, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData)
                    return Center(
                      child: CircularProgressIndicator(),
                    );

                  return ListView.builder(
                    itemCount: snapshot.data.documents.length,
                    itemBuilder: (ctx, index) {
                      return UserItem(
                          userDocument: snapshot.data.documents[index]);
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  _openSearchScreen() {}

  void _openProfilePage() {
    Routes.sailor.navigate(ProfilePage.routeName, params: {
      'userId': null,
    }).then((value) {
      setState(() {});
    });
  }

  void _openSettingsPage(context) {
    BlocProvider.of<LoginBloc>(context).add(SignOutWithGoogleEvent());
  }
}
