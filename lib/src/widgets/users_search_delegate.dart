import 'package:chat_app/src/widgets/user_item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UsersSearchDelegate extends SearchDelegate<String> {
  final List<DocumentSnapshot> usersData;

  UsersSearchDelegate({@required this.usersData});

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
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

    return _buildUsersList(searchResult);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = query.isEmpty ? usersData : _performSearchOperation();
    return _buildUsersList(suggestions);
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

  ListView _buildUsersList(usersDataList) {
    return ListView.builder(
      itemCount: usersDataList.length,
      itemBuilder: (ctx, index) {
        return UserItem(userDocument: usersDataList[index]);
      },
    );
  }
}
