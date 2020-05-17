import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/error/exceptions.dart';
import '../models/user_model.dart';

abstract class LoginLocalDataSource {
  /// Stores the user data json string into shared preferences
  ///
  /// Throws a [CacheException] for all error codes.
  Future<void> cacheUserData(UserModel user);

  /// fetches the user cahed data and returns a user model of this data.
  ///
  /// Throws a [UserNotFoundException] for all error codes.
  Future<UserModel> getUserData();

  /// Deletes the cahced User data from preferences.
  Future<void> clear();
}

class LoginLocalDataSourceImpl implements LoginLocalDataSource {
  final SharedPreferences preferences;

  LoginLocalDataSourceImpl({@required this.preferences});

  @override
  Future<void> cacheUserData(UserModel user) async {
    try {
      String userJsonString = json.encode(user.toMap());
      await preferences.setString('user', userJsonString);
    } catch (error) {
      throw CacheException(message: error.toString());
    }
  }

  @override
  Future<UserModel> getUserData() async {
    final userDataString = preferences.getString('user');
    if (userDataString != null) {
      final parsedJson = json.decode(userDataString);
      return UserModel.fromJson(parsedJson);
    } else {
      throw UserNotFoundException(
        message: 'Welcome to our app, login now and start chating.',
      );
    }
  }

  @override
  Future<void> clear() async {
    await preferences.remove('user');
  }
}
