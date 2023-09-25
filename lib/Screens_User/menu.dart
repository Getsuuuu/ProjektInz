import 'package:flutter/material.dart';
class MenuPageUser extends StatefulWidget {

  @override
  State<MenuPageUser> createState() => _MenuPageUserState();
}

class _MenuPageUserState extends State<MenuPageUser> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(context, '/search');
          },
          child: Text('Wyszukiwarka'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(context, '/reserve');
          },
          child: Text('Rezerwacje'),
        ),
      ],
    );
  }
}
