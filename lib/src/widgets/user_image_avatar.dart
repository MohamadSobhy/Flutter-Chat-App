import 'package:flutter/material.dart';

class UserImageAvatar extends StatelessWidget {
  final String imageUrl;
  final Function() onTap;

  const UserImageAvatar({
    @required this.imageUrl,
    @required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        vertical: 7.0,
        horizontal: 7.0,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: Colors.grey[200],
        image: DecorationImage(
          image: NetworkImage(imageUrl),
        ),
      ),
      height: 45,
      width: 45,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10.0),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
          ),
        ),
      ),
    );
  }
}
