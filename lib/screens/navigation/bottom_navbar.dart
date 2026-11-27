import 'package:flutter/material.dart';
import '../home/home_screen.dart';
import '../budget/budget_screen.dart';
import '../project/project_screen.dart';
import '../contribution/contribution_screen.dart';
import '../profile/profile_screen.dart';

class BottomNavbar extends StatefulWidget {
  const BottomNavbar({super.key});
  @override
  State<BottomNavbar> createState() => _BottomNavbarState();
}

class _BottomNavbarState extends State<BottomNavbar> {
  int _currentIndex = 0;
  bool _contributionBusy = false;
  void _select(int index) { if (!_contributionBusy) setState(() => _currentIndex = index); }
  @override
  Widget build(BuildContext context) {
    final screens = <Widget>[
      const HomeScreen(), const BudgetScreen(), const ProjectScreen(),
      ContributionScreen(onProjects: () => _select(2), onBusy: (value) { if (mounted) setState(() => _contributionBusy = value); }),
      const ProfileScreen(),
    ];
    return Scaffold(body: screens[_currentIndex], bottomNavigationBar: BottomNavigationBar(
      currentIndex: _currentIndex, onTap: _select, type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF245B9E), unselectedItemColor: const Color(0xFF687586), backgroundColor: Colors.white,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Beranda'),
        BottomNavigationBarItem(icon: Icon(Icons.bar_chart_outlined), label: 'Anggaran'),
        BottomNavigationBarItem(icon: Icon(Icons.folder_outlined), label: 'Proyek'),
        BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline), label: 'Kontribusi'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profil'),
      ],
    ));
  }
}
