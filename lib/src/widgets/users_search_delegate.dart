import 'package:chat_app/src/providers/users_provider.dart';
import 'package:chat_app/src/widgets/user_item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'manage_friends_page_content.dart';

class UsersSearchDelegate extends SearchDelegate<String> {
  final List<DocumentSnapshot> usersData;
  final UsersType usersType;
  final String userId;

  UsersSearchDelegate({@required this.usersData, this.usersType, this.userId});

  @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context);
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      query.isNotEmpty
          ? IconButton(
              icon: Icon(
                Icons.clear,
                color: Theme.of(context).scaffoldBackgroundColor,
              ),
              onPressed: () {
                query = '';
              },
            )
          : Container(),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        color: Theme.of(context).scaffoldBackgroundColor,
        progress: transitionAnimation,
      ),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final searchResult = _performSearchOperation();

    return _buildUsersList(context, searchResult);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = query.isEmpty ? usersData : _performSearchOperation();
    return _buildUsersList(context, suggestions);
  }

  List<DocumentSnapshot> _performSearchOperation() {
    return usersData
        .where(
          (user) =>
              user['displayName'].toLowerCase().contains(query.toLowerCase()) ||
              query.toLowerCase().contains(user['displayName'].toLowerCase()) ||
              user['email'].toLowerCase().contains(query.toLowerCase()) ||
              query.toLowerCase().contains(user['email'].toLowerCase()) ||
              (user['phoneNumber'] != null &&
                  user['phoneNumber']
                      .toLowerCase()
                      .contains(query.toLowerCase())) ||
              (user['phoneNumber'] != null &&
                  query
                      .toLowerCase()
                      .contains(user['phoneNumber'].toLowerCase())),
        )
        .toList();
  }

  ListView _buildUsersList(context, List<DocumentSnapshot> usersDataList) {
    return ListView.builder(
      itemCount: usersDataList.length,
      itemBuilder: (ctx, index) {
        return UserItem(
          userDocument: usersDataList[index],
          isFriend: usersType == null,
          isRequest: usersType == UsersType.friendRequests,
          onAddFriendPressed: () => _sendFriendRequestCallback(
            context,
            usersDataList[index].data['id'],
          ),
          onAcceptRequestPressed: () => _acceptFriendRequest(
            context,
            usersDataList[index].data['id'],
          ),
          onDeleteRequestPressed: () => _deleteRequestPressed(
            context,
            usersDataList[index].data['id'],
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
    usersData.removeWhere((element) => element.data['id'] == friendId);

    Provider.of<UsersProvider>(context, listen: false)
        .acceptFriendRequest(userId, friendId);
  }

  void _deleteRequestPressed(context, String friendId) {
    Provider.of<UsersProvider>(context, listen: false)
        .deleteFriendRequest(userId, friendId);
  }
}
