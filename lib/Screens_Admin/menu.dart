import 'package:flutter/material.dart';
class MenuPageAdmin extends StatefulWidget {

  @override
  State<MenuPageAdmin> createState() => _MenuPageAdminState();
}

class _MenuPageAdminState extends State<MenuPageAdmin> {
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
            Navigator.pushNamed(context, '/scan');
          },
          child: Text('Skaner'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(context, '/addGame');
          },
          child: Text('Dodaj grę'),
        ),
      ],
    );
  }
}
