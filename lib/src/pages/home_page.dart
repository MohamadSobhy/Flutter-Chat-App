import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/login/data/models/user_model.dart';
import '../../features/login/presentation/pages/profile_page.dart';
import '../../injection_container.dart';
import '../../main.dart';
import '../providers/users_provider.dart';
import '../widgets/custom_app_bar_action.dart';
import '../widgets/user_image_avatar.dart';
import '../widgets/user_item.dart';
import '../widgets/users_search_delegate.dart';
import 'settings_page.dart';

class HomePage extends StatefulWidget {
  static const String routeName = '/dashboard';

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _userPhotoUrl;
  List<DocumentSnapshot> usersData;
  String currentUserId;

  @override
  void initState() {
    final userJsonString =
        serviceLocator<SharedPreferences>().getString('user');
    if (userJsonString != null) {
      final user = UserModel.fromJson(json.decode(userJsonString));
      _userPhotoUrl = user.photoUrl;
      currentUserId = user.id;
    }
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
              child: FutureBuilder<Stream<List<DocumentSnapshot>>>(
                future: Provider.of<UsersProvider>(context)
                    .getListOfFriends(currentUserId),
                builder: (ctx, snap) {
                  if (!snap.hasData) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  return StreamBuilder<List<DocumentSnapshot>>(
                    stream: snap.data,
                    builder:
                        (ctx, AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
                      if (!snapshot.hasData) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      usersData = snapshot.data;

                      if (snapshot.data.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset('assets/images/chat_icon.png'),
                              Text(
                                'You don\'t have friends!. Try to add some. ☺️😊',
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText1
                                    .copyWith(fontSize: 18),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        itemCount: snapshot.data.length,
                        itemBuilder: (ctx, index) {
                          return UserItem(
                            userDocument: snapshot.data[index],
                          );
                        },
                      );
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

  void _openSearchScreen() {
    showSearch(
      context: context,
      delegate: UsersSearchDelegate(
        usersData: usersData,
      ),
    );
  }

  void _openProfilePage() {
    Routes.sailor.navigate(ProfilePage.routeName, params: {
      'userId': null,
    }).then((value) {
      setState(() {});
    });
  }

  void _openSettingsPage(context) {
    Routes.sailor.navigate(SettingsPage.routeName);
  }
}
