import 'package:flutter/material.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';

import 'Screens/search.dart';
import 'Screens_Admin/addGame.dart';
import 'Screens_Admin/menu.dart';
import 'Screens_Admin/scaner.dart';
import 'Screens_Admin/search_Admin.dart';
import 'Screens_User/menu.dart';
import 'Screens_User/reserve_screen.dart';
import 'Screens_User/search_User.dart';
import 'auth/login.dart';
import 'auth/register.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final keyApplicationId = 'N3oWhRPKvCzwauZ2M7KSBC8p9EdEiYwjoA1ZYoMk';
  final keyClientKey = 'yDKM2rBTQnSffihrKOJC3D9XUWkk8VJB6RV8tCWz';
  final keyParseServerUrl = 'https://parseapi.back4app.com';

  await Parse().initialize(keyApplicationId, keyParseServerUrl,
      clientKey: keyClientKey, debug: true);

  runApp(MaterialApp(
    title: 'Login',
    initialRoute: '/',
    routes: {
      '/': (context) => LoginPage(),
      '/register': (context) => RegisterPage(),
      '/searchUser': (context) => SearchPageUser(),
      '/search': (context) => SearchPage(),
      '/addGame': (context) => AddGameForm(),
      '/menuUser': (context) => MenuPageUser(),
      '/reserve': (context) => ReservePage(),
      '/scan': (context) => ScanerPage(),
      '/searchAdmin': (context) => SearchPageAdmin(title: '',),
      '/menuAdmin': (context) => MenuPageAdmin(),
    },
  ));
}