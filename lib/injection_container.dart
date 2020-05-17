import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

GetIt serviceLocator = GetIt.instance;

Future<void> init() async {
  //!Externals
  final prefs = await SharedPreferences.getInstance();
  serviceLocator.registerLazySingleton(() => prefs);
}
