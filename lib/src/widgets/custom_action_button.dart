import 'package:flutter/material.dart';

class CustomActionButton extends StatelessWidget {
  final String title;
  final Function onPressed;

  const CustomActionButton({
    @required this.title,
    @required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      elevation: 2,
      height: 25,
      color: Theme.of(context).primaryColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      minWidth: 100,
      child: Text(
        title,
        style: Theme.of(context).textTheme.button.copyWith(color: Colors.white),
      ),
      onPressed: onPressed,
    );
  }
}
