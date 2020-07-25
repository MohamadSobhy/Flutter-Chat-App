import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../main.dart';
import '../pages/chat_page.dart';
import 'custom_action_button.dart';

class UserItem extends StatefulWidget {
  final DocumentSnapshot userDocument;
  final bool isFriend;
  final bool isRequest;
  final Function onAddFriendPressed;
  final Function onDeleteRequestPressed;
  final Function onAcceptRequestPressed;

  const UserItem({
    @required this.userDocument,
    this.isFriend = true,
    this.isRequest = false,
    this.onAddFriendPressed,
    this.onDeleteRequestPressed,
    this.onAcceptRequestPressed,
  });

  @override
  _UserItemState createState() => _UserItemState();
}

class _UserItemState extends State<UserItem> {
  bool _isRequestSent = false;
  bool _isRequestAccepted = false;
  bool _isRequestDeleted = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      // color: Colors.grey[100],
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
            onTap: widget.isFriend || _isRequestAccepted ? _openChatPage : null,
            splashColor: Theme.of(context).splashColor,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: widget.userDocument.data['photoUrl'] == null ||
                            widget.userDocument.data['photoUrl'].isEmpty
                        ? Image.asset('assets/images/icon_user.png')
                        : CachedNetworkImage(
                            imageUrl: widget.userDocument.data['photoUrl'],
                            height: 50.0,
                            width: 50.0,
                            fit: BoxFit.fill,
                          ),
                  ),
                  title: Text(
                    widget.userDocument.data['displayName'],
                    style: Theme.of(context).textTheme.title.copyWith(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0,
                        ),
                  ),
                  subtitle: Text(
                    widget.userDocument.data['email'],
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: !widget.isFriend
                      ? _isRequestAccepted ||
                              _isRequestDeleted ||
                              _isRequestSent
                          ? Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Text(
                                _isRequestAccepted
                                    ? 'You are now friends. click to start chatting!'
                                    : _isRequestSent
                                        ? 'Request Sent'
                                        : 'Request Deleted',
                              ),
                            )
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CustomActionButton(
                                  title: widget.isRequest
                                      ? 'Accept Request'
                                      : 'Add Friend',
                                  onPressed: widget.isRequest
                                      ? _onAcceptRequestPressed
                                      : _onAddFriendPressed,
                                ),
                                SizedBox(width: 10),
                                widget.isRequest
                                    ? CustomActionButton(
                                        title: 'Delete',
                                        onPressed: _onDeleteRequestPressed,
                                      )
                                    : Container()
                              ],
                            )
                      : Container(),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Function _onAcceptRequestPressed() {
    setState(() {
      _isRequestAccepted = true;
    });
    return widget.onAcceptRequestPressed();
  }

  Function _onAddFriendPressed() {
    setState(() {
      _isRequestSent = true;
    });
    return widget.onAddFriendPressed();
  }

  void _onDeleteRequestPressed() {
    setState(() {
      _isRequestDeleted = true;
    });
    widget.onDeleteRequestPressed();
  }

  void _openChatPage() {
    Routes.sailor.navigate(ChatPage.routeName, params: {
      'peerId': widget.userDocument.data['id'],
      'peerName': widget.userDocument.data['displayName'],
      'peerImageUrl': widget.userDocument.data['photoUrl'],
    });
  }
}
