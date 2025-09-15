import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  final String? selectedRoute;
  final Function(String) onRouteSelected;

  const AppDrawer({
    super.key,
    this.selectedRoute,
    required this.onRouteSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text(
              'Planazoo',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            selected: selectedRoute == '/home',
            onTap: () => onRouteSelected('/home'),
          ),
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: const Text('Calendar'),
            selected: selectedRoute == '/calendar',
            onTap: () => onRouteSelected('/calendar'),
          ),
          ListTile(
            leading: const Icon(Icons.list),
            title: const Text('Plans'),
            selected: selectedRoute == '/plans',
            onTap: () => onRouteSelected('/plans'),
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            selected: selectedRoute == '/settings',
            onTap: () => onRouteSelected('/settings'),
          ),
        ],
      ),
    );
  }
}
