import 'package:chat_app/core/error/exceptions.dart';
import 'package:dartz/dartz.dart';
import 'package:meta/meta.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/login_repository.dart';
import '../datasources/login_local_data_source.dart';
import '../datasources/login_remote_data_source.dart';

typedef Future<User> _SignInOrSignUpMethod();
typedef Future<String> _UpdateOrDeleteAccountMethod();

class LoginRepositoryImpl implements LoginRepository {
  final LoginRemoteDataSource remoteDataSource;
  final LoginLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  LoginRepositoryImpl({
    @required this.remoteDataSource,
    @required this.localDataSource,
    @required this.networkInfo,
  });

  @override
  Future<Either<Failure, User>> signInWithGoogle() async {
    return await _signInOrSignUp(() {
      localDataSource.storeLoginMethod(LoginMethod.google);
      return remoteDataSource.signInWithGoogle();
    });
  }

  @override
  Future<Either<Failure, User>> signInWithFacebook() async {
    return await _signInOrSignUp(() {
      localDataSource.storeLoginMethod(LoginMethod.facebook);
      return remoteDataSource.signInWithFacebook();
    });
  }

  @override
  Future<Either<Failure, void>> signOutWithGoogle() async {
    if (await networkInfo.isConnected) {
      try {
        await localDataSource.clear();
        return Right(await remoteDataSource.signOutWithGoogle());
      } on ServerException catch (error) {
        return Left(ServerFailure(message: error.message));
      }
    } else {
      return Left(NetworkFailure(message: NO_INTERNET_CONNECTION));
    }
  }

  @override
  Future<Either<Failure, User>> getLoggedInUserData() async {
    try {
      final userModel = await localDataSource.getUserData();

      //login again to link app to firebase
      if (localDataSource.getLoginMethod() == LoginMethod.emailAndPassword)
        remoteDataSource.signInWithEmailAndPassword(
          userModel.email,
          userModel.password,
        );

      return Right(userModel);
    } on UserNotFoundException catch (error) {
      return Left(UserNotFoundFailure(message: error.message));
    } on ServerException catch (error) {
      return Left(ServerFailure(message: error.message));
    }
  }

  @override
  Future<Either<Failure, User>> signInWithEmailAndPassword(
      String email, String password) async {
    return await _signInOrSignUp(
      () {
        localDataSource.storeLoginMethod(LoginMethod.emailAndPassword);
        return remoteDataSource.signInWithEmailAndPassword(email, password);
      },
    );
  }

  @override
  Future<Either<Failure, User>> signUpWithEmailAndPassword(User user) async {
    return await _signInOrSignUp(
      () {
        localDataSource.storeLoginMethod(LoginMethod.emailAndPassword);
        return remoteDataSource.signUpWithEmailAndPassword(user);
      },
    );
  }

  @override
  Future<Either<Failure, String>> updateAccountInfo(User user) async {
    return await _updateOrDeleteAccount(() {
      //localDataSource.cacheUserData(user);
      _tempUser = user;
      return remoteDataSource.updateAccountInfo(user);
    });
  }

  @override
  Future<Either<Failure, String>> deleteAccount(User user) async {
    return await _updateOrDeleteAccount(() {
      localDataSource.clear();
      return remoteDataSource.deleteAccount(user);
    });
  }

  Future<Either<Failure, User>> _signInOrSignUp(
      _SignInOrSignUpMethod signInOrSignOut) async {
    if (await networkInfo.isConnected) {
      try {
        final user = await signInOrSignOut();

        localDataSource.cacheUserData(user);
        remoteDataSource.registerNotificationsForUser(user.id);

        return Right(user);
      } on ServerException catch (error) {
        print('Error:${error.message}');
        return Left(ServerFailure(message: error.message.split(',')[1]));
      }
    } else {
      return Left(NetworkFailure(message: NO_INTERNET_CONNECTION));
    }
  }

  User _tempUser;
  Future<Either<Failure, String>> _updateOrDeleteAccount(
    _UpdateOrDeleteAccountMethod updateOrDeleteAccount,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await updateOrDeleteAccount();

        if (_tempUser != null) {
          await localDataSource.cacheUserData(_tempUser);
          _tempUser = null;
        }

        return Right(result);
      } on ServerException catch (error) {
        return Left(ServerFailure(message: error.message));
      }
    } else {
      return Left(NetworkFailure(message: NO_INTERNET_CONNECTION));
    }
  }
}

const String NO_INTERNET_CONNECTION =
    'A WiFi or cellular network connection is required. Please check your network settings.';
