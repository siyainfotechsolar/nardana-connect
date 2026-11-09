import 'package:flutter/material.dart';
import 'package:nardana_connect/core/constants/app_colors.dart';
import 'package:nardana_connect/core/localization/app_localizations.dart';
import 'package:nardana_connect/features/home/presentation/screens/home_screen.dart';
import 'package:nardana_connect/features/explore/presentation/screens/explore_screen.dart';
import 'package:nardana_connect/features/post/presentation/screens/post_screen.dart';
import 'package:nardana_connect/features/notices/presentation/screens/notices_screen.dart';
import 'package:nardana_connect/features/profile/presentation/screens/profile_screen.dart';

class MainShellScreen extends StatefulWidget {
  const MainShellScreen({super.key});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    ExploreScreen(),
    PostScreen(),
    NoticesScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

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
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          backgroundColor: Colors.white,
          indicatorColor: AppColors.primaryBlue.withValues(alpha: 0.12),
          elevation: 0,
          onDestinationSelected: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.home_outlined),
              selectedIcon: const Icon(Icons.home_rounded, color: AppColors.primaryBlue),
              label: l10n.translate('home'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.explore_outlined),
              selectedIcon: const Icon(Icons.explore_rounded, color: AppColors.primaryBlue),
              label: l10n.translate('explore'),
            ),
            NavigationDestination(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: AppColors.secondaryGreen,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
              ),
              selectedIcon: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: AppColors.secondaryGreen,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
              ),
              label: l10n.translate('post'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.notifications_none_rounded),
              selectedIcon: const Icon(Icons.notifications_rounded, color: AppColors.primaryBlue),
              label: l10n.translate('updates'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.person_outline_rounded),
              selectedIcon: const Icon(Icons.person_rounded, color: AppColors.primaryBlue),
              label: l10n.translate('profile'),
            ),
          ],
        ),
      ),
    );
  }
}
