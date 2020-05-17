import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/injection_container.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../main.dart';
import '../widgets/user_item.dart';
import './settings_page.dart';
import './login_page.dart';

class HomePage extends StatefulWidget {
  static const String routeName = '/dashboard';

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: _isLoading,
      child: WillPopScope(
        onWillPop: () => _onBackButtonPressed(context),
        child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text(
              'Dashboard',
              style: TextStyle(
                color: Color(0xFF08245E),
                fontSize: 25.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: <Widget>[
              DropdownButton(
                isExpanded: false,
                underline: Container(),
                iconEnabledColor: Color(0xFF08245E),
                icon: Icon(Icons.more_vert),
                iconSize: 30.0,
                items: [
                  DropdownMenuItem(
                      value: 'settings',
                      child: Row(
                        children: <Widget>[
                          Icon(Icons.settings),
                          SizedBox(
                            width: 10.0,
                          ),
                          Text('Settings'),
                        ],
                      )),
                  DropdownMenuItem(
                      value: 'logout',
                      child: Row(
                        children: <Widget>[
                          Icon(Icons.exit_to_app),
                          SizedBox(
                            width: 10.0,
                          ),
                          Text('Logout'),
                        ],
                      )),
                ],
                onChanged: (value) async {
                  if (value == 'settings') {
                    _openSettingsPage();
                  } else {
                    final isLoggingOut = await _onBackButtonPressed(context);
                    if (isLoggingOut) {
                      Routes.sailor.navigate(LoginPage.routeName,
                          removeUntilPredicate: (_) => false);
                    }
                  }
                },
              )
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
        ),
      ),
    );
  }

  Future<bool> _onBackButtonPressed(context) async {
    final isLogOutClicked = await _showLogOutDialog(context);
    if (isLogOutClicked != null && isLogOutClicked) {
      setState(() {
        _isLoading = true;
      });
      await FirebaseAuth.instance.signOut();
      //await GoogleSignIn().disconnect();
      await GoogleSignIn().signOut();
      setState(() {
        _isLoading = false;
      });

      return Future.value(true);
    } else {
      return Future.value(false);
    }
  }

  void _openSettingsPage() {
    Routes.sailor.navigate(SettingsPage.routeName);
  }

  Future<bool> _showLogOutDialog(context) {
    final screenSize = MediaQuery.of(context).size;

    return showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          contentPadding: const EdgeInsets.all(0.0),
          content: Container(
            height: screenSize.height * 0.2,
            width: screenSize.width * 0.5,
            color: Colors.white,
            child: Container(
              color: Colors.deepOrange,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      'Log out!',
                      style: TextStyle(
                        color: Color(0xFF08245E),
                        fontSize: 30.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Are you sure to log out?',
                      style: TextStyle(
                        color: Color(0xFF08245E),
                        fontSize: 20.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: <Widget>[
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Routes.sailor.pop(false);
                },
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Text(
                    'No',
                    style: TextStyle(
                      fontSize: 20.0,
                      color: Color(0xFF08245E),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Routes.sailor.pop(true);
                },
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Text(
                    'Yes',
                    style: TextStyle(
                      fontSize: 20.0,
                      color: Color(0xFF08245E),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
      barrierDismissible: false,
    );
  }
}
