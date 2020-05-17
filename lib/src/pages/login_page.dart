import 'dart:convert';

import 'package:chat_app/injection_container.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../main.dart';
import './home_page.dart';

class LoginPage extends StatefulWidget {
  static const String routeName = '/login';
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  GoogleSignIn googleSignIn = GoogleSignIn();

  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: _isLoading,
      child: Scaffold(
        body: Center(
          child: RaisedButton(
            onPressed: _singInUsingGoogle,
            color: Colors.redAccent,
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 10.0,
            ),
            child: Text(
              'Sign In with Google!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20.0,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _singInUsingGoogle() async {
    try {
      setState(() {
        _isLoading = true;
      });

      googleSignIn = GoogleSignIn();
      GoogleSignInAccount account = await googleSignIn.signIn().catchError((_) {
        setState(() {
          _isLoading = false;
        });
      });

      GoogleSignInAuthentication authentication = await account.authentication;

      AuthCredential authCredential = GoogleAuthProvider.getCredential(
        idToken: authentication.idToken,
        accessToken: authentication.accessToken,
      );

      FirebaseUser user =
          (await firebaseAuth.signInWithCredential(authCredential)).user;

      if (user != null) {
        QuerySnapshot result = await Firestore.instance
            .collection('users')
            .where('id', isEqualTo: user.uid)
            .getDocuments();

        var userData = {
          'displayName': user.displayName,
          'email': user.email,
          'phoneNumber': user.phoneNumber,
          'photoUrl': user.photoUrl,
          'id': user.uid,
        };

        if (result.documents.length == 0) {
          Firestore.instance
              .collection('users')
              .document(user.uid)
              .setData(userData);
        }
        serviceLocator<SharedPreferences>().setString(
          'userData',
          json.encode(userData),
        );

        setState(() {
          _isLoading = false;
        });
        Routes.sailor.navigate(HomePage.routeName);
      }
    } catch (error) {
      print(error);
      setState(() {
        _isLoading = false;
      });
    }
  }
}
