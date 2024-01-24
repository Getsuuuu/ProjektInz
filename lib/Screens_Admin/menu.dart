import 'package:flutter/material.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class MenuPageAdmin extends StatefulWidget {
  @override
  State<MenuPageAdmin> createState() => _MenuPageAdminState();
}

class _MenuPageAdminState extends State<MenuPageAdmin> {
  bool isSuperAdmin = false; // Assume the user is not a super admin initially

  @override
  void initState() {
    super.initState();
    checkSuperAdminStatus();
  }

  Future<void> checkSuperAdminStatus() async {
    try {
      final currentUser = await ParseUser.currentUser();

      if (currentUser != null) {
        final isSuperAdminUser = currentUser.get<bool>('superAdmin') ?? false;

        setState(() {
          isSuperAdmin = isSuperAdminUser;
        });
      } else {
        print('Current user is null.');
      }
    } catch (e) {
      print('Error podczas sprawdzania statusu admina: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Row(
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
        ),
        if (isSuperAdmin)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/adminSettings');
                },
                child: Text('Opcje'),
              ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/');
              },
              child: Text('Wyloguj'),
            ),
          ],
        ),
      ],
    );
  }
}
