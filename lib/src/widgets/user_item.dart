import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../main.dart';
import '../pages/chat_page.dart';

class UserItem extends StatelessWidget {
  final DocumentSnapshot userDocument;

  const UserItem({@required this.userDocument});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.deepOrangeAccent,
      elevation: 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      margin: const EdgeInsets.symmetric(
        horizontal: 5.0,
        vertical: 5.0,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _openChatPage,
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(30.0),
                  child: CachedNetworkImage(
                    imageUrl: userDocument.data['photoUrl'],
                    height: 60.0,
                    width: 60.0,
                    fit: BoxFit.cover,
                  ),
                ),
                title: Text(
                  userDocument.data['displayName'],
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18.0,
                  ),
                ),
                subtitle: Text(
                  userDocument.data['email'],
                  style: TextStyle(
                    color: Colors.grey[400],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _openChatPage() {
    Routes.sailor.navigate(ChatPage.routeName, params: {
      'peerId': userDocument.data['id'],
      'peerName': userDocument.data['displayName'],
    });
  }
}
