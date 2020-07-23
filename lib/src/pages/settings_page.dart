import 'package:chat_app/core/theme/app_themes.dart';
import 'package:chat_app/core/theme/bloc/theme_bloc.dart';
import 'package:chat_app/features/login/presentation/bloc/login_bloc.dart';
import 'package:chat_app/injection_container.dart';
import 'package:chat_app/src/widgets/custom_confirmation_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  static const String routeName = '/settings';

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool isDarkMoodChoosed = false;

  @override
  void initState() {
    final themeIndex = serviceLocator<SharedPreferences>().getInt('theme');
    if (themeIndex == null || AppTheme.values[themeIndex] == AppTheme.light) {
      isDarkMoodChoosed = false;
    } else {
      isDarkMoodChoosed = true;
    }
    setState(() {});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        centerTitle: true,
      ),
      body: Column(children: [
        SwitchListTile(
          title: Text('Dark mood'),
          value: isDarkMoodChoosed,
          onChanged: (newValue) {
            final themeBloc = BlocProvider.of<ThemeBloc>(context);
            if (newValue) {
              themeBloc.add(ChangeAppTheme(theme: AppTheme.dark));
            } else {
              themeBloc.add(ChangeAppTheme(theme: AppTheme.light));
            }

            setState(() {
              isDarkMoodChoosed = newValue;
            });
          },
        ),
        OutlineButton(
          highlightedBorderColor: Theme.of(context).primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          onPressed: _performLogOut,
          child: Text('Log out'),
        ),
      ]),
    );
  }

  void _performLogOut() {
    showDialog(
      context: context,
      child: CustomConfirmationDialog(
        title: 'Do you want to log out?',
        onCancelPressed: () {
          Navigator.of(context).pop();
        },
        onOkPressed: _sendLogoutEvent,
      ),
    );
  }

  void _sendLogoutEvent() {
    BlocProvider.of<LoginBloc>(context).add(SignOutWithGoogleEvent());
    Navigator.popUntil(context, (route) => route.isFirst);
  }
}
