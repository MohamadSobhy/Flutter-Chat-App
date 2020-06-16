import 'dart:convert';
import 'dart:io';

import 'package:chat_app/core/error/exceptions.dart';
import 'package:chat_app/features/login/data/datasources/login_local_data_source.dart';
import 'package:chat_app/injection_container.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
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

  LoginRemoteDataSourceImpl({
    @required this.storage,
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

        final userData = UserModel(
          id: user.uid,
          displayName: user.displayName,
          email: user.email,
          password: '',
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

  @override
  Future<UserModel> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final authResult = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final userDocument = await _getUserDataFromServer(authResult);

      final userModel = UserModel.fromJson(userDocument.data);

      return userModel;
    } catch (error) {
      throw ServerException(message: error.toString().split(',')[1]);
    }
  }

  Future<DocumentSnapshot> _getUserDataFromServer(AuthResult authResult) {
    return firestoreInstance
        .collection('users')
        .document(authResult.user.uid)
        .get();
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
      throw ServerException(message: error.toString().split(',')[1]);
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
      final isImageChanged = user.photoUrl.split(' ')[1];
      user.photoUrl = user.photoUrl.split(' ')[0];
      if (isImageChanged == '1') {
        await _uploadUserImageToServer(user);
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
