import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  static const String routeName = '/settings';

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _userNameController = TextEditingController();

  final _phoneNumberController = TextEditingController();

  Map<String, dynamic> accountData = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Account Settings'),
      ),
      body: FutureBuilder(
        future: SharedPreferences.getInstance(),
        builder: (ctx, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          accountData = json.decode(snapshot.data.getString(
            'user',
          ));

          _userNameController.text = accountData['displayName'];
          if (accountData['phoneNumber'] != null) {
            _phoneNumberController.text = accountData['phoneNumber'];
          }

          return Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(35.0),
                    child: Stack(
                      children: <Widget>[
                        CachedNetworkImage(
                          height: 150.0,
                          imageUrl: accountData['photoUrl'],
                          fit: BoxFit.cover,
                        ),
                        Positioned.fill(
                          child: Container(
                            color: Colors.black12,
                            child: Center(
                              child: IconButton(
                                icon: Icon(Icons.camera_enhance),
                                color: Colors.white.withOpacity(0.6),
                                iconSize: 40.0,
                                onPressed: _chooseImageFromGellary,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  Text(accountData['email']),
                  SizedBox(
                    height: 20.0,
                  ),
                  Container(
                    width: 300.0,
                    padding: const EdgeInsets.all(20.0),
                    child: TextField(
                      controller: _userNameController,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF08245E),
                        fontSize: 20.0,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Your Name',
                      ),
                    ),
                  ),
                  Container(
                    width: 300.0,
                    padding: const EdgeInsets.all(20.0),
                    child: TextField(
                      controller: _phoneNumberController,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF08245E),
                        fontSize: 20.0,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Phone Number',
                      ),
                    ),
                  ),
                  OutlineButton(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30.0,
                      vertical: 10.0,
                    ),
                    onPressed: _updateUserData,
                    child: Text(
                      'Update',
                      style: TextStyle(fontSize: 16.0),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _chooseImageFromGellary() async {
    final newImage = await ImagePicker.pickImage(source: ImageSource.gallery);

    if (newImage != null) {
      FirebaseStorage.instance
          .ref()
          .child(accountData['id'] + '.png')
          .putFile(newImage)
          .onComplete
          .then((value) {
        value.ref.getDownloadURL().then((url) async {
          accountData['photoUrl'] = url;

          await _updateUserData();
          setState(() {});
        });
      });
    }
  }

  Future<void> _updateUserData() async {
    accountData = {
      'id': accountData['id'],
      'email': accountData['email'],
      'displayName': _userNameController.text.trim(),
      'phoneNumber': _phoneNumberController.text.trim(),
      'photoUrl': accountData['photoUrl'],
    };
    Firestore.instance
        .collection('users')
        .document(accountData['id'])
        .updateData(accountData);

    await (await SharedPreferences.getInstance())
      ..clear()
      ..setString('userData', json.encode(accountData));
  }
}
