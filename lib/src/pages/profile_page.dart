import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/features/login/data/models/user_model.dart';
import 'package:chat_app/features/login/domain/entities/user.dart';
import 'package:chat_app/injection_container.dart';
import 'package:chat_app/main.dart';
import 'package:chat_app/src/pages/image_message_view.dart';
import 'package:chat_app/src/widgets/custom_app_bar_action.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  static const String routeName = '/settings';

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _userNameController = TextEditingController();

  final _phoneNumberController = TextEditingController();

  UserModel user;

  @override
  void didChangeDependencies() {
    user = UserModel.fromJson(
      json.decode(
        serviceLocator<SharedPreferences>().getString('user'),
      ),
    );
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return DefaultTabController(
      length: 2,
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
                onActionPressed: _goBack,
              ),
            ),
            Positioned(
              top: 30.0,
              right: 0.0,
              child: CustomAppBarAction(
                height: 45.0,
                icon: Icons.edit,
                onActionPressed: () {},
              ),
            ),
            Positioned(
              top: screenSize.height * 0.25,
              child: Container(
                width: screenSize.width,
                height: screenSize.height * 0.75,
                decoration: BoxDecoration(
                  color: Theme.of(context).canvasColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(35.0),
                    topRight: Radius.circular(35.0),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.only(
                    top: screenSize.height * 0.15,
                    left: 15.0,
                    right: 15.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        user.displayName,
                        style: Theme.of(context).textTheme.title,
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      Text(
                        user.email,
                      ),
                      SizedBox(
                        height: 20.0,
                      ),
                      user.phoneNumber != null
                          ? Text(user.phoneNumber)
                          : Container(),
                      _buildProfileInfoTabBar(),
                      _buildProfileInfoTabBarView(),
                    ],
                  ),
                ),
              ),
            ),
            _buildUserImageAvatar(screenSize),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileInfoTabBar() {
    return TabBar(
      labelColor: Theme.of(context).primaryColor,
      unselectedLabelColor: Colors.black,
      tabs: [
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Text(
            'Experience',
            style: TextStyle(fontSize: 18.0),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Text(
            'Reviews(0)',
            style: TextStyle(fontSize: 18.0),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileInfoTabBarView() {
    return Expanded(
      child: TabBarView(
        children: [
          Center(
            child: Text('No Experience available.'),
          ),
          Center(
            child: Text('No Reviews available.'),
          )
        ],
      ),
    );
  }

  Widget _buildUserImageAvatar(screenSize) {
    return Positioned(
      top: screenSize.height * 0.12,
      left: screenSize.width * 0.3,
      child: Hero(
        tag: 'user-avatar',
        child: Material(
          color: Colors.transparent,
          child: GestureDetector(
            onTap: _viewUserImageOnFullScreen,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(60.0),
              child: CachedNetworkImage(
                height: MediaQuery.of(context).size.width * 0.4,
                imageUrl: user.photoUrl,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _viewUserImageOnFullScreen() {
    Routes.sailor.navigate(ImageMessageView.routeName, params: {
      'imageUrl': user.photoUrl,
    });
  }

  void _chooseImageFromGellary() async {
    final newImage = await ImagePicker.pickImage(source: ImageSource.gallery);

    if (newImage != null) {
      FirebaseStorage.instance
          .ref()
          .child(user.id + '.png')
          .putFile(newImage)
          .onComplete
          .then((value) {
        value.ref.getDownloadURL().then((url) async {
          user.photoUrl = url;

          await _updateUserData();
          setState(() {});
        });
      });
    }
  }

  Future<void> _updateUserData() async {
    UserModel accountData = UserModel(
      id: user.id,
      email: user.email,
      displayName: _userNameController.text.trim(),
      phoneNumber: _phoneNumberController.text.trim(),
      photoUrl: user.photoUrl,
      password: user.password,
    );

    Firestore.instance
        .collection('users')
        .document(user.id)
        .updateData(accountData.toMap());

    await (await SharedPreferences.getInstance())
      ..clear()
      ..setString('userData', json.encode(accountData));
  }

  void _goBack() {
    Navigator.of(context).pop();
  }
}
