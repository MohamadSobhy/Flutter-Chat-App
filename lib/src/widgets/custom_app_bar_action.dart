import 'package:flutter/material.dart';

class CustomAppBarAction extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final double height;
  final Function() onActionPressed;

  const CustomAppBarAction({
    @required this.icon,
    @required this.onActionPressed,
    this.iconColor,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        vertical: 7.0,
        horizontal: 7.0,
      ),
      width: 45,
      height: height != null ? height : double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: Colors.grey[200],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10.0),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onActionPressed,
            child: Icon(
              icon,
              color: iconColor == null
                  ? Theme.of(context).primaryColor
                  : iconColor,
            ),
          ),
        ),
      ),
    );
  }
}
