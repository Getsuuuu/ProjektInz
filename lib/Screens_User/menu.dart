import 'package:flutter/material.dart';
import '../Screens/search.dart';
import '../Screens/options.dart';
import 'reserve_screen.dart';

class MenuPageUser extends StatefulWidget {
  final int initialIndex;

  const MenuPageUser({Key? key, this.initialIndex = 0}) : super(key: key);

  @override
  State<MenuPageUser> createState() => _MenuPageUserState();
}

class _MenuPageUserState extends State<MenuPageUser> {
  late int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  final List<Widget> _screens = [
    SearchPage(),
    ReservePage(),
    OptionsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.shifting,
            items: <BottomNavigationBarItem>[
              _buildCustomNavItem(Icons.search, 'Wyszukaj', Colors.red),
              _buildCustomNavItem(Icons.calendar_today, 'Rezerwacje', Colors.green),
              _buildCustomNavItem(Icons.settings, 'Opcje', Colors.purple),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.grey,
            onTap: (index) {
              print("Selected index: $index");
              setState(() {
                _selectedIndex = index;
              });
            },
          ),
        ),
      );
  }

  BottomNavigationBarItem _buildCustomNavItem(IconData icon, String label, Color color) {
    return BottomNavigationBarItem(
      icon: Icon(icon, color: Colors.white),
      label: label,
      backgroundColor: color,
    );
  }
}
