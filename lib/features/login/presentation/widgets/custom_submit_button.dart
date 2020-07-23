import 'package:flutter/material.dart';

class CustomSubmitButton extends StatelessWidget {
  final Function onSubmit;
  final String label;

  const CustomSubmitButton({@required this.onSubmit, @required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 45.0,
      width: MediaQuery.of(context).size.width * 0.3,
      margin: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 15.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: Theme.of(context).primaryColor,
        boxShadow: [
          BoxShadow(
            color: Colors.grey[200],
            spreadRadius: 2,
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15.0),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onSubmit,
            child: Center(
              child: Text(
                label,
                style: Theme.of(context).textTheme.title,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
