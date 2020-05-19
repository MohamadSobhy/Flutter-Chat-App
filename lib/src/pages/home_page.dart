import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/features/login/domain/entities/user.dart';
import 'package:chat_app/features/login/presentation/bloc/login_bloc.dart';
import 'package:chat_app/features/login/presentation/pages/login_page.dart';
import 'package:chat_app/injection_container.dart';
import 'package:chat_app/src/widgets/custom_app_bar_action.dart';
import 'package:chat_app/src/widgets/user_image_avatar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../main.dart';
import '../widgets/user_item.dart';
import './profile_page.dart';

class HomePage extends StatelessWidget {
  static const String routeName = '/dashboard';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: UserImageAvatar(
          imageUrl: serviceLocator<User>().photoUrl,
          onTap: _openProfilePage,
        ),
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        leading: CustomAppBarAction(
          icon: Icons.search,
          onActionPressed: _openSearchScreen,
        ),
        actions: <Widget>[
          CustomAppBarAction(
            icon: Icons.settings,
            onActionPressed: () => _openSettingsPage(context),
          ),
        ],
      ),
      body: StreamBuilder(
        stream: Firestore.instance.collection('users').snapshots(),
        builder: (ctx, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData)
            return Center(
              child: CircularProgressIndicator(),
            );

          return ListView.builder(
            itemCount: snapshot.data.documents.length,
            itemBuilder: (ctx, index) {
              return UserItem(userDocument: snapshot.data.documents[index]);
            },
          );
        },
      ),
    );
  }

  _openSearchScreen() {}

  void _openProfilePage() {
    Routes.sailor.navigate(ProfilePage.routeName);
  }

  void _openSettingsPage(context) {
    BlocProvider.of<LoginBloc>(context).add(SignOutWithGoogleEvent());
  }
}
