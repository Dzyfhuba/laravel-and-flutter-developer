import 'package:flutter/material.dart';

class NavBar extends StatefulWidget {
  final void Function(int index) setPageIndex;
  final int pageIndex;
  const NavBar({
    super.key,
    required this.setPageIndex,
    required this.pageIndex,
  });

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  int currentPageIndex = 0;

  @override
  void didUpdateWidget(state) {
    super.didUpdateWidget(state);
    setState(() {
      currentPageIndex = widget.pageIndex;
    });
  }

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
          tooltip: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.add),
          label: 'New Post',
          tooltip: 'New Post',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
          tooltip: 'Profile',
        ),
      ],
    );
  }
}
