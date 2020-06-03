import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/login/domain/entities/user.dart';
import '../../features/login/presentation/bloc/login_bloc.dart';
import '../../features/login/presentation/pages/profile_page.dart';
import '../../injection_container.dart';
import '../../main.dart';
import '../widgets/custom_app_bar_action.dart';
import '../widgets/user_image_avatar.dart';
import '../widgets/user_item.dart';

class HomePage extends StatelessWidget {
  static const String routeName = '/dashboard';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Hero(
          tag: 'user-avatar',
          child: UserImageAvatar(
            imageUrl: serviceLocator<User>().photoUrl,
            onTap: _openProfilePage,
          ),
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
