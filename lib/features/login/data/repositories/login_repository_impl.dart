import 'package:chat_app/core/error/exceptions.dart';
import 'package:dartz/dartz.dart';
import 'package:meta/meta.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/login_repository.dart';
import '../datasources/login_local_data_source.dart';
import '../datasources/login_remote_data_source.dart';

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
    final isDeviceConnectedToNetwork = await networkInfo.isConnected;
    if (isDeviceConnectedToNetwork) {
      try {
        final userModel = await remoteDataSource.signInWithGoogle();

        //cache user data
        localDataSource.cacheUserData(userModel);

        return Right(userModel);
      } on ServerException catch (error) {
        return Left(ServerFailure(message: error.message));
      }
    } else {
      return Left(NetworkFailure(message: NO_INTERNET_CONNECTION));
    }
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
      return Right(userModel);
    } on UserNotFoundException catch (error) {
      return Left(UserNotFoundFailure(message: error.message));
    }
  }
}

const String NO_INTERNET_CONNECTION =
    'A WiFi or cellular network connection is required. Please check your network settings.';
