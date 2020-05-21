import 'package:flutter/material.dart';

class UserImageAvatar extends StatelessWidget {
  final String imageUrl;
  final double height;
  final double width;
  final Function() onTap;

  const UserImageAvatar({
    @required this.imageUrl,
    @required this.onTap,
    this.height = 45.0,
    this.width = 45.0,
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
          image: imageUrl == null
              ? AssetImage('assets/images/icon_user.png')
              : NetworkImage(imageUrl),
          fit: BoxFit.fill,
        ),
      ),
      height: height,
      width: width,
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
