import 'package:chat_app/core/error/exceptions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:meta/meta.dart';

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
  Future<UserModel> signUpWithEmailAndPassword(
    String email,
    String password,
  );

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
      throw ServerException(message: error.toString());
    }
  }

  Future<DocumentSnapshot> _getUserDataFromServer(AuthResult authResult) {
    return firestoreInstance
        .collection('users')
        .document(authResult.user.uid)
        .get();
  }

  @override
  Future<UserModel> signUpWithEmailAndPassword(
      String email, String password) async {
    try {
      final authResult = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final userData = UserModel(
        id: authResult.user.uid,
        displayName: authResult.user.displayName,
        email: authResult.user.email,
        password: password,
        phoneNumber: authResult.user.phoneNumber,
        photoUrl: authResult.user.photoUrl,
      );

      _storeUserDataOnServer(userData);

      return userData;
    } catch (error) {
      throw ServerException(message: error.toString());
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

      currentUser.updatePassword(user.password);

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
}
