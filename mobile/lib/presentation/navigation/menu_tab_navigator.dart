import 'package:flutter/material.dart';
import '../screens/menu_screen.dart';

class MenuTabNavigator extends StatefulWidget {
  const MenuTabNavigator({super.key});

  @override
  State<MenuTabNavigator> createState() => _MenuTabNavigatorState();
}

class _MenuTabNavigatorState extends State<MenuTabNavigator> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: _navigatorKey,
      onGenerateRoute: (RouteSettings settings) {
        return MaterialPageRoute(
          builder: (context) => const MenuScreen(),
        );
      },
    );
  }
}
