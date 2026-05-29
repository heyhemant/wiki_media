import 'package:flutter/material.dart';
import '../generated/l10n.dart';
import '../utils/design_system.dart';
import 'feed_screen.dart';
import 'profiles_screen.dart';
import 'stats_screen.dart';
import 'settings_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  final VoidCallback onThemeChanged;
  final VoidCallback onDataReset;

  const MainNavigationScreen({
    super.key,
    required this.onThemeChanged,
    required this.onDataReset,
  });

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _onTabTapped(int index) {
    _pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          FeedScreen(
            onThemeChanged: widget.onThemeChanged,
            onDataReset: widget.onDataReset,
          ),
          ProfilesScreen(
            onProfileChanged: () {
              // We refresh the whole app state when profile changes to reload the feed
              widget.onDataReset();
            },
          ),
          const StatsScreen(),
          SettingsScreen(
            onThemeChanged: widget.onThemeChanged,
            onDataReset: widget.onDataReset,
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: colors.divider,
              width: 0.5,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: colors.bottomNavBackground,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: colors.bottomNavUnselected,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          elevation: 0,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home_outlined),
              activeIcon: const Icon(Icons.home),
              label: S.of(context).home,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.person_outline),
              activeIcon: const Icon(Icons.person),
              label: S.of(context).profiles,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.bar_chart_outlined),
              activeIcon: const Icon(Icons.bar_chart),
              label: S.of(context).stats,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.settings_outlined),
              activeIcon: const Icon(Icons.settings),
              label: S.of(context).settings,
            ),
          ],
        ),
      ),
    );
  }
}
