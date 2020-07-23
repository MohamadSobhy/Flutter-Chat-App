import 'package:flutter/material.dart';

class EmptyChatMessage extends StatelessWidget {
  final String peerName;

  const EmptyChatMessage({@required this.peerName});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height * 0.3,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Image.asset(
                'assets/images/empty_chat.png',
                height: 100,
                fit: BoxFit.cover,
              ),
              Text(
                'No Messages Yet!',
                style: TextStyle(
                  fontSize: 25.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber,
                ),
              ),
              Text(
                'start chating with $peerName now.',
                style: Theme.of(context)
                    .textTheme
                    .bodyText1
                    .copyWith(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
