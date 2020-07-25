import 'dart:async';
import 'dart:convert';

import 'package:chat_app/injection_container.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class UsersProvider extends ChangeNotifier {
  final _firestore = serviceLocator<Firestore>();

  Future<void> unFriendUser(String currentUserId, String friendId) async {
    final friendDoc =
        await _firestore.collection('users').document(friendId).get();
    final userDoc =
        await _firestore.collection('users').document(currentUserId).get();

    final friendFriends =
        List<String>.from(json.decode(friendDoc.data['friends'] ?? '[]'));
    final userFriends =
        List<String>.from(json.decode(userDoc.data['friends'] ?? '[]'));

    userFriends.remove(friendId);
    friendFriends.remove(currentUserId);

    _firestore
        .collection('users')
        .document(currentUserId)
        .updateData({'friends': json.encode(userFriends)});

    _firestore
        .collection('users')
        .document(friendId)
        .updateData({'friends': json.encode(friendFriends)});
  }

  Future<void> sendFriendRequest(String currentUserId, String friendId) async {
    final friendDoc =
        await _firestore.collection('users').document(friendId).get();
    final requests =
        List<String>.from(json.decode(friendDoc.data['requests'] ?? '[]'));

    requests.add(currentUserId);
    _firestore
        .collection('users')
        .document(friendId)
        .updateData({'requests': json.encode(requests)});
  }

  Future<void> acceptFriendRequest(
      String currentUserId, String friendId) async {
    final friendDoc =
        await _firestore.collection('users').document(friendId).get();
    final friendRequests =
        List<String>.from(json.decode(friendDoc.data['requests'] ?? '[]'));
    final friendFriends =
        List<String>.from(json.decode(friendDoc.data['friends'] ?? '[]'));

    final userDoc =
        await _firestore.collection('users').document(currentUserId).get();
    final userRequests =
        List<String>.from(json.decode(userDoc.data['requests'] ?? '[]'));
    final userFriends =
        List<String>.from(json.decode(userDoc.data['friends'] ?? '[]'));

    friendRequests.remove(currentUserId);
    friendFriends.add(currentUserId);

    userRequests.remove(friendId);
    userFriends.add(friendId);

    _firestore.collection('users').document(currentUserId)
      ..updateData({
        'friends': json.encode(userFriends),
        'requests': json.encode(userRequests),
      });

    _firestore.collection('users').document(friendId).updateData({
      'friends': json.encode(friendFriends),
      'requests': json.encode(friendRequests),
    });
  }

  Future<void> deleteFriendRequest(
      String currentUserId, String friendId) async {
    final userDoc =
        await _firestore.collection('users').document(currentUserId).get();

    final userRequests = List<String>.from(
      json.decode(userDoc.data['requests'] ?? '[]'),
    );

    userRequests.remove(friendId);

    _firestore
        .collection('users')
        .document(currentUserId)
        .updateData({'requests': json.encode(userRequests)});
  }

  Future<Stream<List<DocumentSnapshot>>> getListOfFriends(
      String currentUserId) {
    return _getListOfUsers(currentUserId: currentUserId, isFriends: true);
  }

  Future<Stream<List<DocumentSnapshot>>> getUnFriendList(String currentUserId) {
    return _getListOfUsers(currentUserId: currentUserId, isFriends: false);
  }

  Future<Stream<List<DocumentSnapshot>>> getFriendRequests(
      String currentUserId) {
    return _getListOfUsers(
      currentUserId: currentUserId,
      isFriends: false,
      isGetRequest: true,
    );
  }

  Future<Stream<List<DocumentSnapshot>>> _getListOfUsers({
    @required String currentUserId,
    @required bool isFriends,
    bool isGetRequest = false,
  }) async {
    return _firestore.collection('users').snapshots().transform(
      StreamTransformer<QuerySnapshot, List<DocumentSnapshot>>.fromHandlers(
        handleData: (querySnapshot, sink) async {
          print('loading friend list of $currentUserId');

          final userDocument = await _firestore
              .collection('users')
              .document(currentUserId)
              .get();

          final friendList = List<String>.from(
            json.decode(
              (userDocument).data['friends'] ?? "[]",
            ),
          );

          final requestList = List<String>.from(
            json.decode(
              (userDocument).data['requests'] ?? "[]",
            ),
          );

          print(friendList);

          final _firendsList = List<DocumentSnapshot>();
          final _unFriendsList = List<DocumentSnapshot>();
          final _friendRequests = List<DocumentSnapshot>();

          for (final doc in querySnapshot.documents) {
            if (friendList.contains(doc.data['id']) ||
                doc.data['id'] == currentUserId) {
              _firendsList.add(doc);
            } else {
              final userRequests = List<String>.from(
                json.decode(doc.data['requests'] ?? '[]'),
              );

              if (!requestList.contains(doc.data['id']) &&
                  !userRequests.contains(currentUserId)) {
                _unFriendsList.add(doc);
              }

              if (requestList.contains(doc.data['id'])) {
                _friendRequests.add(doc);
              }
            }
          }

          print(_firendsList);

          if (isFriends) {
            sink.add(_firendsList);
          } else {
            if (isGetRequest)
              sink.add(_friendRequests);
            else
              sink.add(_unFriendsList);
          }
        },
      ),
    );
  }
}
