import 'package:chat_app/src/widgets/users_search_delegate.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/users_provider.dart';
import 'user_item.dart';

enum UsersType {
  friendRequests,
  addFriends,
}

class ManageFriendsPageContent extends StatelessWidget {
  final String userId;
  final UsersType contentType;

  ManageFriendsPageContent({
    @required this.contentType,
    @required this.userId,
  });

  List<DocumentSnapshot> _usersList = [];
  @override
  Widget build(BuildContext context) {
    final usersProvider = Provider.of<UsersProvider>(context);
    // if (_usersList != null) {
    //   return _buildUserList(context, _usersList);
    // }
    print(contentType);

    return Stack(
      children: [
        FutureBuilder<Stream<List<DocumentSnapshot>>>(
          future: contentType == UsersType.friendRequests
              ? usersProvider.getFriendRequests(userId)
              : usersProvider.getUnFriendList(userId),
          builder: (_, snap) {
            if (!snap.hasData) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            return StreamBuilder<List<DocumentSnapshot>>(
              stream: snap.data,
              builder: (__, snapshot) {
                if (!snapshot.hasData) {
                  print(snapshot.data);
                  return Center(child: Text('Loading....'));
                }

                _usersList = snapshot.data;

                if (snapshot.data.isEmpty)
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Text(
                        contentType == UsersType.friendRequests
                            ? 'There are no friend requests! 🤷'
                            : 'Oho!! All Users are friends of you or you sent requests for all of them. \n\nshare our app with your friends to see them here! 😉',
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .bodyText1
                            .copyWith(fontSize: 18),
                      ),
                    ),
                  );

                return _buildUserList(context, snapshot.data);
              },
            );
          },
        ),
        Positioned(
          right: 0,
          bottom: 20,
          child: FloatingActionButton(
            onPressed: () {
              showSearch(
                context: context,
                delegate: UsersSearchDelegate(
                  usersData: _usersList,
                  usersType: contentType,
                  userId: userId,
                ),
              );
            },
            child: Icon(Icons.search),
          ),
        )
      ],
    );
  }

  ListView _buildUserList(context, List<DocumentSnapshot> usersDocs) {
    return ListView.builder(
      key: UniqueKey(),
      padding: const EdgeInsets.symmetric(vertical: 10),
      itemCount: usersDocs.length,
      itemBuilder: (_, index) {
        return UserItem(
          userDocument: usersDocs[index],
          isFriend: false,
          isRequest: contentType == UsersType.friendRequests,
          onAddFriendPressed: () => _sendFriendRequestCallback(
            context,
            usersDocs[index].data['id'],
          ),
          onAcceptRequestPressed: () => _acceptFriendRequest(
            context,
            usersDocs[index].data['id'],
          ),
          onDeleteRequestPressed: () => _deleteRequestPressed(
            context,
            usersDocs[index].data['id'],
          ),
        );
      },
    );
  }

  void _sendFriendRequestCallback(context, friendId) {
    Provider.of<UsersProvider>(context, listen: false)
        .sendFriendRequest(userId, friendId);
  }

  void _acceptFriendRequest(context, String friendId) {
    Provider.of<UsersProvider>(context, listen: false)
        .acceptFriendRequest(userId, friendId);
  }

  void _deleteRequestPressed(context, String friendId) {
    Provider.of<UsersProvider>(context, listen: false)
        .deleteFriendRequest(userId, friendId);
  }
}
