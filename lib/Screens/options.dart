import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class OptionsScreen extends StatefulWidget {
  @override
  _OptionsScreenState createState() => _OptionsScreenState();
}

class _OptionsScreenState extends State<OptionsScreen> {
  bool isAdmin = false;
  bool isSuperAdmin = false;

  Future<void> checkAdminStatus() async {
    try {
      final currentUser = await ParseUser.currentUser();

      if (currentUser != null) {
        final isAdminUser = currentUser.get<bool>('admin') ?? false;

        setState(() {
          isAdmin = isAdminUser;
        });
      } else {
      }
    } catch (e) {
      print('Error podczas sprawdzania statusu admina: $e');
    }
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
      }
    } catch (e) {
      print('Error podczas sprawdzania statusu admina: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    checkSuperAdminStatus();
    checkAdminStatus();
  }

  @override
  Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Opcje'),
          automaticallyImplyLeading: false,
          backgroundColor: Colors.purple,
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            if (isAdmin)
              Padding(
                padding: const EdgeInsets.all(6.0),
                child: Container(
                  constraints: BoxConstraints(
                    minWidth: double.infinity,
                    minHeight: 60.0,
                  ),
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/addGame');
                    },
                    style: OutlinedButton.styleFrom(
                      primary: Colors.black,
                      side: BorderSide(color: Colors.black),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: Text('Dodaj grę'),
                  ),
                ),
              ),
            if (isSuperAdmin)
              Padding(
                padding: const EdgeInsets.all(6.0),
                child: Container(
                  constraints: BoxConstraints(
                    minWidth: double.infinity,
                    minHeight: 60.0,
                  ),
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/editAdmin');
                    },
                    style: OutlinedButton.styleFrom(
                      primary: Colors.black,
                      side: BorderSide(color: Colors.black),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: Text('Edytuj pracowników'),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(6.0),
              child: Container(
                constraints: BoxConstraints(
                  minWidth: double.infinity,
                  minHeight: 60.0,
                ),
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/');
                  },
                  style: OutlinedButton.styleFrom(
                    primary: Colors.black,
                    side: BorderSide(color: Colors.black),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: Text('Wyloguj'),
                ),
              ),
            ),
          ],
        ),
      );
    }
}
