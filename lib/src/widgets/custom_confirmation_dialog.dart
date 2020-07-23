import 'package:flutter/material.dart';

class CustomConfirmationDialog extends StatelessWidget {
  final String title;
  final Function() onCancelPressed;
  final Function() onOkPressed;

  const CustomConfirmationDialog({
    @required this.title,
    @required this.onCancelPressed,
    @required this.onOkPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      content: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Are you sure?',
              style: Theme.of(context).textTheme.title.copyWith(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Text(title),
          ],
        ),
      ),
      contentPadding: const EdgeInsets.only(top: 10, bottom: 15),
      buttonPadding: const EdgeInsets.all(0),
      actions: [
        FlatButton(
          onPressed: onCancelPressed,
          child: Text(
            'Cancel',
            style: TextStyle(color: Theme.of(context).primaryColor),
          ),
        ),
        FlatButton(
          onPressed: onOkPressed,
          child: Text(
            'Yes',
            style: TextStyle(color: Theme.of(context).primaryColor),
          ),
        ),
      ],
    );
  }
}
