import 'package:flutter/material.dart';

class UNavigationBar extends StatefulWidget {
  const UNavigationBar({Key? key, required this.title, required this.actions})
      : super(key: key);

  final String title;
  final List<Widget> actions;

  @override
  State<UNavigationBar> createState() => _UNavigationBar();
}

class _UNavigationBar extends State<UNavigationBar> {
  int _selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.star),
          label: 'Favourite',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_box),
          label: 'Extra',
        ),
      ],
      currentIndex: _selectedIndex,
      selectedItemColor: Colors.amber[800],
      onTap: (index) => {
        setState(() {
          _selectedIndex = index;
        })
      },
    );
  }
}
