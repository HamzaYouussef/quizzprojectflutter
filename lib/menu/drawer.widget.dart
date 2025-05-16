import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final drawerItems = [
      _DrawerItem(
        label: 'Accueil',
        icon: Icons.home,
        route: '/home',
      ),
      _DrawerItem(
        label: 'Météo',
        icon: Icons.cloud,
        route: '/meteo',
      ),
      _DrawerItem(
        label: 'Gallerie',
        icon: Icons.photo_library,
        route: '/gallerie',
      ),
      _DrawerItem(
        label: 'Pays',
        icon: Icons.flag,
        route: '/pays',
      ),
      _DrawerItem(
        label: 'Contact',
        icon: Icons.contact_mail,
        route: '/contact',
      ),
      _DrawerItem(
        label: 'Paramètres',
        icon: Icons.settings,
        route: '/parametres',
      ),
      _DrawerItem(
        label: 'Déconnexion',
        icon: Icons.logout,
        route: '/authentification',
        isLogout: true,
      ),
    ];

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.lightBlueAccent.shade100, Colors.blue.shade700],
              ),
            ),
            child: const Center(
              child: CircleAvatar(
                backgroundImage: AssetImage("images/profil.png"),
                radius: 60,
              ),
            ),
          ),
          ...drawerItems.map((item) => _buildListTile(context, item)).toList(),
        ],
      ),
    );
  }

  Widget _buildListTile(BuildContext context, _DrawerItem item) {
    final color = item.isLogout ? Colors.red : Colors.blue.shade800;
    return ListTile(
      title: Text(
        item.label,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w500,
          color: item.isLogout ? Colors.red : null,
        ),
      ),
      leading: Icon(item.icon, color: color, size: 28),
      trailing: Icon(Icons.arrow_forward_ios, color: color, size: 18),
      onTap: () async {
        Navigator.pop(context);
        if (item.isLogout) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('connecte', false);
          Navigator.pushNamedAndRemoveUntil(context, item.route, (_) => false);
        } else {
          Navigator.pushNamed(context, item.route);
        }
      },
    );
  }
}

class _DrawerItem {
  final String label;
  final IconData icon;
  final String route;
  final bool isLogout;

  const _DrawerItem({
    required this.label,
    required this.icon,
    required this.route,
    this.isLogout = false,
  });
}
