import 'package:flutter/material.dart';

class LoadingPage extends StatefulWidget {
  static const String routeName = '/loading';

  @override
  _LoadingPageState createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage>
    with SingleTickerProviderStateMixin {
  AnimationController _scaleAnimationController;

  @override
  void initState() {
    super.initState();

    _scaleAnimationController = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    )..forward();

    _scaleAnimationController.repeat();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _scaleAnimationController,
        builder: (ctx, child) => Center(
          child: Hero(
            tag: 'hero',
            child: CircleAvatar(
              radius: _scaleAnimationController.value * 40,
              backgroundColor: Theme.of(context).primaryColor,
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scaleAnimationController.dispose();
    super.dispose();
  }
}
