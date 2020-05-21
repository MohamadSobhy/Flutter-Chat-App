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
      color: Colors.grey[100],
      elevation: 0.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      margin: const EdgeInsets.symmetric(
        horizontal: 10.0,
        vertical: 5.0,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _openChatPage,
            splashColor: Theme.of(context).splashColor,
            child: ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: userDocument.data['photoUrl'] == null
                    ? Image.asset('assets/images/icon_user.png')
                    : CachedNetworkImage(
                        imageUrl: userDocument.data['photoUrl'],
                        height: 50.0,
                        width: 50.0,
                        fit: BoxFit.fill,
                      ),
              ),
              title: Text(
                userDocument.data['displayName'],
                style: Theme.of(context).textTheme.title.copyWith(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0,
                    ),
              ),
              subtitle: Text(
                userDocument.data['email'],
                style: TextStyle(
                  color: Colors.black,
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
      'peerImageUrl': userDocument.data['photoUrl'],
    });
  }
}
