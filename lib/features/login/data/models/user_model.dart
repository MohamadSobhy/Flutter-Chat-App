import 'package:chat_app/features/login/domain/entities/user.dart';
import 'package:meta/meta.dart';

class UserModel extends User {
  UserModel({
    @required String id,
    @required String displayName,
    @required String email,
    @required String password,
    @required String phoneNumber,
    @required String photoUrl,
  }) : super(
          id: id,
          displayName: displayName,
          email: email,
          password: password,
          phoneNumber: phoneNumber,
          photoUrl: photoUrl,
        );

  factory UserModel.fromJson(Map<String, dynamic> parsedJson) {
    return UserModel(
      id: parsedJson['id'],
      displayName: parsedJson['displayName'],
      email: parsedJson['email'],
      password: parsedJson['password'],
      phoneNumber: parsedJson['phoneNumber'],
      photoUrl: parsedJson['photoUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'displayName': displayName,
      'email': email,
      'password': password,
      'phoneNumber': phoneNumber,
      'photoUrl': photoUrl,
    };
  }
}
