import 'package:go_router/go_router.dart';
import 'package:nardana_connect/features/splash/presentation/screens/splash_screen.dart';
import 'package:nardana_connect/features/language/presentation/screens/language_selection_screen.dart';
import 'package:nardana_connect/features/welcome/presentation/screens/welcome_screen.dart';
import 'package:nardana_connect/features/shell/presentation/screens/main_shell_screen.dart';
import 'package:nardana_connect/features/explore/presentation/screens/explore_screen.dart';
import 'package:nardana_connect/features/explore/presentation/screens/search_screen.dart';
import 'package:nardana_connect/features/emergency/presentation/screens/emergency_screen.dart';
import 'package:nardana_connect/features/notices/presentation/screens/notices_screen.dart';
import 'package:nardana_connect/features/jobs/presentation/screens/jobs_screen.dart';
import 'package:nardana_connect/features/marketplace/presentation/screens/marketplace_screen.dart';
import 'package:nardana_connect/features/profile/presentation/screens/favorites_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/language',
      builder: (context, state) => const LanguageSelectionScreen(),
    ),
    GoRoute(
      path: '/welcome',
      builder: (context, state) => const WelcomeScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const MainShellScreen(),
    ),
    GoRoute(
      path: '/search',
      builder: (context, state) => const SearchScreen(),
    ),
    GoRoute(
      path: '/explore',
      builder: (context, state) => const ExploreScreen(),
    ),
    GoRoute(
      path: '/emergency',
      builder: (context, state) => const EmergencyScreen(),
    ),
    GoRoute(
      path: '/notices',
      builder: (context, state) => const NoticesScreen(),
    ),
    GoRoute(
      path: '/jobs',
      builder: (context, state) => const JobsScreen(),
    ),
    GoRoute(
      path: '/marketplace',
      builder: (context, state) => const MarketplaceScreen(),
    ),
    GoRoute(
      path: '/favorites',
      builder: (context, state) => const FavoritesScreen(),
    ),
  ],
);
