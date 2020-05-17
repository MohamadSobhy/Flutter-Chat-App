import 'package:chat_app/core/error/exceptions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:meta/meta.dart';

import '../models/user_model.dart';

abstract class LoginRemoteDataSource {
  /// Calls the signIn method of the GoogleSignIn package to perform login process.
  ///
  /// Throws a [ServerException] for all error codes.
  Future<UserModel> signInWithGoogle();

  /// Calls the signOut method of the GoogleSignIn package to perform logging out process.
  ///
  /// Throws a [ServerException] for all error codes.
  Future<void> signOutWithGoogle();
}

class LoginRemoteDataSourceImpl implements LoginRemoteDataSource {
  final GoogleSignIn googleSignIn;
  final FirebaseAuth firebaseAuth;
  final Firestore firestoreInstance;

  LoginRemoteDataSourceImpl({
    @required this.firestoreInstance,
    @required this.firebaseAuth,
    @required this.googleSignIn,
  });

  @override
  Future<UserModel> signInWithGoogle() async {
    try {
      GoogleSignInAccount account = await googleSignIn.signIn();

      GoogleSignInAuthentication authentication = await account.authentication;

      AuthCredential authCredential = GoogleAuthProvider.getCredential(
        idToken: authentication.idToken,
        accessToken: authentication.accessToken,
      );

      FirebaseUser user =
          (await firebaseAuth.signInWithCredential(authCredential)).user;

      if (user != null) {
        QuerySnapshot result = await firestoreInstance
            .collection('users')
            .where('id', isEqualTo: user.uid)
            .getDocuments();

        var userData = UserModel(
          id: user.uid,
          displayName: user.displayName,
          email: user.email,
          phoneNumber: user.phoneNumber,
          photoUrl: user.photoUrl,
        );

        if (result.documents.length == 0) {
          _storeUserDataOnServer(userData);
        }
        return userData;
      }
    } catch (error) {
      throw ServerException(message: error.toString());
    }
    return null;
  }

  void _storeUserDataOnServer(UserModel userData) {
    firestoreInstance
        .collection('users')
        .document(userData.id)
        .setData(userData.toMap());
  }

  @override
  Future<void> signOutWithGoogle() async {
    try {
      await firebaseAuth.signOut();
      //await GoogleSignIn().disconnect();
      await googleSignIn.signOut();
    } catch (error) {
      throw ServerException(message: error.toString());
    }
  }
}
