import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

class User extends Equatable {
  String id;
  final String displayName;
  final String email;
  final String password;
  final String phoneNumber;
  String photoUrl;

  User({
    @required this.id,
    @required this.displayName,
    @required this.email,
    @required this.password,
    @required this.phoneNumber,
    @required this.photoUrl,
  });

  @override
  List<Object> get props => [
        id,
        displayName,
        email,
        password,
        phoneNumber,
        photoUrl,
      ];
}
