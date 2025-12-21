import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import 'dashboard_screen.dart';
import 'chat_screen.dart';
import 'profile_screen.dart';
import 'menu_screen.dart';
import 'patients_screen.dart';
import 'previsions_screen.dart';

class MainContainer extends StatefulWidget {
  const MainContainer({super.key});

  @override
  State<MainContainer> createState() => _MainContainerState();
}

class _MainContainerState extends State<MainContainer> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const PatientsScreen(),
    const PrevisionsScreen(), // New separated screen
    const ChatScreen(),
    const MenuScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          backgroundColor: Colors.white,
          elevation: 0,
          indicatorColor: AppColors.primary.withOpacity(0.1),
          height: 70,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.grid_view_outlined),
              selectedIcon: Icon(Icons.grid_view, color: AppColors.primary),
              label: 'Accueil',
            ),
             NavigationDestination(
              icon: Icon(Icons.people_outline),
              selectedIcon: Icon(Icons.people, color: AppColors.primary),
              label: 'Patients',
            ),
             NavigationDestination(
              icon: Icon(Icons.trending_up), 
              selectedIcon: Icon(Icons.trending_up, color: AppColors.primary),
              label: 'Prévisions',
            ),
            NavigationDestination(
              icon: Icon(Icons.chat_bubble_outline),
              selectedIcon: Icon(Icons.chat_bubble, color: AppColors.primary),
              label: 'Assistant',
            ),
             NavigationDestination(
              icon: Icon(Icons.menu),
              selectedIcon: Icon(Icons.menu, color: AppColors.primary),
              label: 'Menu',
            ),
          ],
        ),
      ),
    );
  }
}
