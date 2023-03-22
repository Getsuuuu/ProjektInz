import 'package:flutter/material.dart';
import 'package:xdd/auth/register.dart';
import 'package:xdd/auth/login.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';

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
    },
  ));
}