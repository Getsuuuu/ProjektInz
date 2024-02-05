import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

import 'Screens/search.dart';
import 'Screens_Admin/addGame.dart';
import 'Screens_Admin/editAdmin.dart';
import 'Screens_Admin/menu.dart';
import 'Screens_Admin/scaner.dart';
import 'Screens_User/menu.dart';
import 'Screens_User/reserve_screen.dart';
import 'auth/login.dart';
import 'auth/register.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final keyApplicationId = 'N3oWhRPKvCzwauZ2M7KSBC8p9EdEiYwjoA1ZYoMk';
  final keyClientKey = 'yDKM2rBTQnSffihrKOJC3D9XUWkk8VJB6RV8tCWz';
  final keyParseServerUrl = 'https://parseapi.back4app.com';
  final keyLiveQueryUrl = 'https://testinzynierskimg1.b4a.io';

  await Parse().initialize(
    keyApplicationId,
    keyParseServerUrl,
    clientKey: keyClientKey,
    autoSendSessionId: true,
    liveQueryUrl: keyLiveQueryUrl,
    debug: true,
  );


  runApp(MaterialApp(
    title: 'Login',
    initialRoute: '/',
    debugShowCheckedModeBanner: false,
    routes: {
      '/': (context) => LoginPage(),
      '/register': (context) => RegisterPage(),
      '/search': (context) => SearchPage(),
      '/addGame': (context) => AddGameForm(),
      '/menuUser': (context) => MenuPageUser(),
      '/reserve': (context) => ReservePage(),
      '/scan': (context) => ScanerPage(),
      '/menuAdmin': (context) => MenuPageAdmin(),
      '/editAdmin': (context) => EditAdminPage(),
    },
  ));
}