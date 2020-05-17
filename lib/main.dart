import 'package:chat_app/injection_container.dart';
import 'package:chat_app/src/pages/image_message_view.dart';
import 'package:flutter/material.dart';
import 'package:sailor/sailor.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'src/pages/chat_page.dart';
import 'src/pages/home_page.dart';
import 'src/pages/login_page.dart';
import 'src/pages/settings_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await init();
  Routes.createRoutes();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userData = serviceLocator<SharedPreferences>().getString('userData');
    return MaterialApp(
      title: 'Chat App',
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
      ),
      home: userData != null ? HomePage() : LoginPage(),
      onGenerateRoute: Routes.sailor.generator(),
      navigatorKey: Routes.sailor.navigatorKey,
    );
  }
}

class Routes {
  static Sailor sailor = Sailor();

  static void createRoutes() {
    sailor.addRoutes([
      SailorRoute(
        name: LoginPage.routeName,
        builder: (_, args, params) => LoginPage(),
      ),
      SailorRoute(
        name: HomePage.routeName,
        builder: (_, args, params) => HomePage(),
      ),
      SailorRoute(
        name: SettingsPage.routeName,
        builder: (_, args, params) => SettingsPage(),
      ),
      SailorRoute(
        name: ChatPage.routeName,
        builder: (_, args, params) => ChatPage(
          peerId: params.param('peerId'),
          peerName: params.param('peerName'),
        ),
        params: [
          SailorParam(
            name: 'peerId',
            defaultValue: '',
            isRequired: true,
          ),
          SailorParam(
            name: 'peerName',
            defaultValue: '',
            isRequired: true,
          ),
        ],
      ),
      SailorRoute(
        name: ImageMessageView.routeName,
        builder: (ctx, args, params) => ImageMessageView(
          imageUrl: params.param('imageUrl'),
        ),
        params: [
          SailorParam(
            name: 'imageUrl',
            isRequired: true,
          ),
        ],
      ),
    ]);
  }
}
