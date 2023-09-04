import 'package:flutter/material.dart';

class NavBar extends StatefulWidget {
  final void Function(int index) setPageIndex;
  const NavBar({super.key, required this.setPageIndex});

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  int currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      onTap: (int index) {
        widget.setPageIndex(index);
        setState(() {
          currentPageIndex = index;
        });
      },
      currentIndex: currentPageIndex,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      selectedIconTheme: const IconThemeData(color: Color(0xFFFF8C00)),
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'School',
        ),
      ],
    );
  }
}
