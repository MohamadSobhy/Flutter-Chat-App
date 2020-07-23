import 'dart:convert';
import 'dart:io';

import 'package:chat_app/core/error/exceptions.dart';
import 'package:chat_app/features/login/data/datasources/login_local_data_source.dart';
import 'package:chat_app/injection_container.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';

abstract class LoginRemoteDataSource {
  //! Login using Google Account
  /// Calls the signIn method of the GoogleSignIn package to perform login process.
  ///
  /// Throws a [ServerException] for all error codes.
  Future<UserModel> signInWithGoogle();

  //! Login using Facebook Account
  /// Calls the logIn method of the FacebookLogin package to perform login process.
  ///
  /// Throws a [ServerException] for all error codes.
  Future<UserModel> signInWithFacebook();

  /// Calls the signOut method of the GoogleSignIn package to perform logging out process.
  ///
  /// Throws a [ServerException] for all error codes.
  Future<void> signOutWithGoogle();

  //! Login with email and password

  /// Call the signInWithEmailAndPassword method of the FirebaseAuth package
  /// to perform logining with email and password.
  ///
  /// Throws a [ServerException] for all error cases.
  Future<UserModel> signInWithEmailAndPassword(String email, String password);

  /// Call the createWithEmailAndPassword method of the FirebaseAuth package
  /// to perform signing up with email and password.
  ///
  /// Throws a [ServerException] for all error cases.
  Future<UserModel> signUpWithEmailAndPassword(UserModel user);

  //common actions

  /// Call the update method of the FirebaseAuth package
  /// to perform updating the password and access Firestore server to update
  /// user's data.
  ///
  /// Throws a [ServerException] for all error cases.
  Future<String> updateAccountInfo(UserModel user);

  /// Deletes all the account data from FirebaseAuth and Firetore.
  ///
  /// Throws a [ServerException] for all error cases.
  Future<String> deleteAccount(UserModel user);
}

class LoginRemoteDataSourceImpl implements LoginRemoteDataSource {
  final GoogleSignIn googleSignIn;
  final FirebaseAuth firebaseAuth;
  final Firestore firestoreInstance;
  final FirebaseStorage storage;
  final FacebookLogin facebookLogin;

  LoginRemoteDataSourceImpl({
    @required this.storage,
    @required this.firestoreInstance,
    @required this.firebaseAuth,
    @required this.googleSignIn,
    @required this.facebookLogin,
  });

  @override
  Future<UserModel> signInWithGoogle() async {
    try {
      GoogleSignInAccount account = await googleSignIn.signIn();

      if (account == null) {
        throw ServerException(message: 'Login canceled');
      }

      GoogleSignInAuthentication authentication = await account.authentication;

      AuthCredential authCredential = GoogleAuthProvider.getCredential(
        idToken: authentication.idToken,
        accessToken: authentication.accessToken,
      );

      FirebaseUser user =
          (await firebaseAuth.signInWithCredential(authCredential)).user;

      return await _validateUser(user);
    } catch (error) {
      String message;
      if (error is ServerException)
        message = error.message;
      else
        message = error.toString();
      throw ServerException(message: message);
    }
    return null;
  }

  Future<UserModel> _validateUser(FirebaseUser user) async {
    if (user != null) {
      QuerySnapshot result = await firestoreInstance
          .collection('users')
          .where('id', isEqualTo: user.uid)
          .getDocuments();

      UserModel userData = UserModel(
        id: user.uid,
        displayName: user.displayName,
        email: user.email,
        password: '',
        phoneNumber: user.phoneNumber,
        photoUrl: user.photoUrl,
      );

      if (result.documents.length == 0) {
        _storeUserDataOnServer(userData);
      } else {
        final userDocument = await _getUserDataFromServer(userData.id);

        userData = UserModel.fromJson(userDocument.data);
      }
      return userData;
    } else {
      throw ServerException(message: 'Login failed.');
    }
  }

  @override
  Future<void> signOutWithGoogle() async {
    try {
      await firebaseAuth.signOut();
      //await GoogleSignIn().disconnect();
      await facebookLogin.logOut();
      await googleSignIn.signOut();
    } catch (error) {
      throw ServerException(message: error.toString());
    }
  }

  @override
  Future<UserModel> signInWithFacebook() async {
    try {
      final result = await facebookLogin.logIn(['email']);

      switch (result.status) {
        case FacebookLoginStatus.loggedIn:
          {
            final authCredential = FacebookAuthProvider.getCredential(
              accessToken: result.accessToken.token,
            );

            final authResult =
                await firebaseAuth.signInWithCredential(authCredential);

            return await _validateUser(authResult.user);
          }
        case FacebookLoginStatus.cancelledByUser:
          {
            throw ServerException(message: 'Login Canceled!');
          }
        case FacebookLoginStatus.error:
        default:
          {
            throw ServerException(message: 'Login failed!');
          }
      }
    } catch (error) {
      String message;
      if (error is ServerException)
        message = error.message;
      else
        message = error.toString();
      throw ServerException(message: message);
    }
  }

  @override
  Future<UserModel> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      if (email.isEmpty) {
        throw ServerException(message: 'Email can\'t be empty');
      }

      if (password.isEmpty) {
        throw ServerException(message: 'Password can\'t be empty');
      }

      final authResult = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final userDocument = await _getUserDataFromServer(authResult.user.uid);

      final userModel = UserModel.fromJson(userDocument.data);

      return userModel;
    } catch (error) {
      // String message;
      // if (error.toString().split(',').length > 1)
      //   message = error.toString().split(',')[1];
      // else
      //   message = error.toString();
      throw ServerException(message: error.message);
    }
  }

  Future<DocumentSnapshot> _getUserDataFromServer(String userID) {
    return firestoreInstance.collection('users').document(userID).get();
  }

  @override
  Future<UserModel> signUpWithEmailAndPassword(UserModel user) async {
    try {
      final authResult = await firebaseAuth.createUserWithEmailAndPassword(
        email: user.email,
        password: user.password,
      );

      user.id = authResult.user.uid;

      if (user.photoUrl != null) await _uploadUserImageToServer(user);

      _storeUserDataOnServer(user);

      return user;
    } catch (error) {
      // String message;
      // if (error.toString().split(',').length > 1)
      //   message = error.toString().split(',')[1];
      // else
      //   message = error.toString();
      throw ServerException(message: error.message);
    }
  }

  @override
  Future<String> deleteAccount(UserModel user) async {
    try {
      final currentUser = await firebaseAuth.currentUser();

      await _deleteUserDataFromServer(user);

      await currentUser.delete();
      return 'Done: Account deleted successfully.';
    } catch (error) {
      throw ServerException(message: error.toString());
    }
  }

  @override
  Future<String> updateAccountInfo(UserModel user) async {
    try {
      final currentUser = await firebaseAuth.currentUser();

      final preferences = serviceLocator<SharedPreferences>();
      if (LoginMethod.values[preferences.getInt('login_method')] ==
          LoginMethod.emailAndPassword) {
        await currentUser.updatePassword(user.password);
        await firebaseAuth.signInWithEmailAndPassword(
            email: user.email, password: user.password);
      }

      //check whether the user choosed a new image or not.
      if (user.photoUrl != null) {
        final isImageChanged = user.photoUrl.split(' ')[1];
        user.photoUrl = user.photoUrl.split(' ')[0];
        if (isImageChanged == '1') {
          await _uploadUserImageToServer(user);
        }
      }
      preferences.setString('user', json.encode(user.toMap()));

      await _updateUserDataOnServer(user);
      return 'Done: Account updated successfully.';
    } catch (error) {
      throw ServerException(message: error.toString());
    }
  }

  Future<void> _storeUserDataOnServer(UserModel userData) async {
    await firestoreInstance
        .collection('users')
        .document(userData.id)
        .setData(userData.toMap());
  }

  Future<void> _updateUserDataOnServer(UserModel userData) async {
    await firestoreInstance
        .collection('users')
        .document(userData.id)
        .updateData(userData.toMap());
  }

  Future<void> _deleteUserDataFromServer(UserModel user) async {
    await firestoreInstance.collection('users').document(user.id).delete();
  }

  Future<void> _uploadUserImageToServer(UserModel user) async {
    final newImage = File(user.photoUrl);

    StorageUploadTask task =
        storage.ref().child(user.id + '.png').putFile(newImage);

    final taskSnapshot = await task.onComplete;
    user.photoUrl = await taskSnapshot.ref.getDownloadURL();
    print(user.photoUrl);
  }
}
