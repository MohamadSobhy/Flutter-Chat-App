import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String displayName;
  final String email;
  final String phoneNumber;
  final String photoUrl;

  User({
    @required this.id,
    @required this.displayName,
    @required this.email,
    @required this.phoneNumber,
    @required this.photoUrl,
  });

  @override
  List<Object> get props => [id, displayName, email, phoneNumber, photoUrl];
}
