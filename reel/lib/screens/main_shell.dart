// 하단 네비게이션을 포함한 메인 앱 껍데기 — 홈·검색·공유·설정 탭 전환
import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'search_screen.dart';
import 'share_screen.dart';
import 'settings_screen.dart';
import '../utils/constants.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  static const _screens = [
    HomeScreen(),
    SearchScreen(),
    ShareScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: _BottomNav(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _BottomNav({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        border: const Border(top: BorderSide(color: Color(0x0F000000))),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20)],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(icon: Icons.grid_view_rounded, label: '홈', index: 0, current: currentIndex, onTap: onTap),
              _NavItem(icon: Icons.search_rounded, label: '검색', index: 1, current: currentIndex, onTap: onTap),
              _NavItem(icon: Icons.share_rounded, label: '공유', index: 2, current: currentIndex, onTap: onTap),
              _NavItem(icon: Icons.settings_rounded, label: '설정', index: 3, current: currentIndex, onTap: onTap),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index;
  final int current;
  final ValueChanged<int> onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.index,
    required this.current,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final active = index == current;
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: active ? AppColors.accent : const Color(0xFFC0C0C0), size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: active ? AppColors.accent : const Color(0xFFC0C0C0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
