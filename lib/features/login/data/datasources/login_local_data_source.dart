import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/error/exceptions.dart';
import '../models/user_model.dart';

enum LoginMethod {
  emailAndPassword,
  google,
  facebook,
}

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

  // Stores the current login method on preferences.
  Future<void> storeLoginMethod(LoginMethod loginMethod);

  //returns the current login method.
  LoginMethod getLoginMethod();
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
    await preferences.remove('login_method');
  }

  @override
  Future<void> storeLoginMethod(LoginMethod loginMethod) async {
    await preferences.setInt('login_method', loginMethod.index);
  }

  @override
  LoginMethod getLoginMethod() {
    return LoginMethod.values[preferences.getInt('login_method')];
  }
}
