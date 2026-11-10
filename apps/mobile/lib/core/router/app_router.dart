import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nardana_connect/features/splash/presentation/screens/splash_screen.dart';
import 'package:nardana_connect/features/language/presentation/screens/language_selection_screen.dart';
import 'package:nardana_connect/features/welcome/presentation/screens/welcome_screen.dart';
import 'package:nardana_connect/features/auth/presentation/screens/login_screen.dart';
import 'package:nardana_connect/features/auth/presentation/screens/register_screen.dart';
import 'package:nardana_connect/features/shell/presentation/screens/main_shell_screen.dart';
import 'package:nardana_connect/features/explore/presentation/screens/explore_screen.dart';
import 'package:nardana_connect/features/explore/presentation/screens/business_detail_screen.dart';
import 'package:nardana_connect/features/explore/presentation/screens/search_screen.dart';
import 'package:nardana_connect/features/emergency/presentation/screens/emergency_screen.dart';
import 'package:nardana_connect/features/jobs/presentation/screens/jobs_screen.dart';
import 'package:nardana_connect/features/jobs/presentation/screens/job_detail_screen.dart';
import 'package:nardana_connect/features/marketplace/presentation/screens/marketplace_screen.dart';
import 'package:nardana_connect/features/marketplace/presentation/screens/marketplace_detail_screen.dart';
import 'package:nardana_connect/features/notices/presentation/screens/notices_screen.dart';
import 'package:nardana_connect/features/notices/presentation/screens/notice_detail_screen.dart';
import 'package:nardana_connect/features/notices/presentation/screens/pdf_viewer_screen.dart';
import 'package:nardana_connect/features/profile/presentation/screens/favorites_screen.dart';
import 'package:nardana_connect/features/profile/presentation/screens/settings_screen.dart';
import 'package:nardana_connect/features/election/presentation/screens/election_screen.dart';
import 'package:nardana_connect/features/election/presentation/screens/candidate_detail_screen.dart';
import 'package:nardana_connect/features/advertisements/models/advertisement_model.dart';
import 'package:nardana_connect/features/advertisements/presentation/screens/advertisement_detail_screen.dart';
import 'package:nardana_connect/features/app_update/models/app_update_config_model.dart';
import 'package:nardana_connect/features/app_update/presentation/screens/force_update_screen.dart';
import 'package:nardana_connect/features/app_update/presentation/screens/maintenance_screen.dart';

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
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
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
      path: '/business-detail',
      builder: (context, state) {
        final business = state.extra as Map<String, dynamic>? ?? {};
        return BusinessDetailScreen(business: business);
      },
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
      path: '/notice-detail',
      builder: (context, state) {
        final notice = state.extra as Map<String, dynamic>? ?? {};
        return NoticeDetailScreen(notice: notice);
      },
    ),
    GoRoute(
      path: '/jobs',
      builder: (context, state) => const JobsScreen(),
    ),
    GoRoute(
      path: '/job-detail',
      builder: (context, state) {
        final job = state.extra as Map<String, dynamic>? ?? {};
        return JobDetailScreen(job: job);
      },
    ),
    GoRoute(
      path: '/marketplace',
      builder: (context, state) => const MarketplaceScreen(),
    ),
    GoRoute(
      path: '/marketplace-detail',
      builder: (context, state) {
        final item = state.extra as Map<String, dynamic>? ?? {};
        return MarketplaceDetailScreen(item: item);
      },
    ),
    GoRoute(
      path: '/favorites',
      builder: (context, state) => const FavoritesScreen(),
    ),
    GoRoute(
      path: '/advertisement-detail',
      builder: (context, state) {
        final ad = state.extra as AdvertisementModel;
        return AdvertisementDetailScreen(ad: ad);
      },
    ),
    GoRoute(
      path: '/force-update',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        final config = extra['config'] as AppUpdateConfigModel?;
        final installedVersion = extra['installedVersion'] as String? ?? '1.0.0';
        final installedBuildNumber = extra['installedBuildNumber'] as int? ?? 1;
        if (config == null) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        return ForceUpdateScreen(
          config: config,
          installedVersion: installedVersion,
          installedBuildNumber: installedBuildNumber,
        );
      },
    ),
    GoRoute(
      path: '/maintenance',
      builder: (context, state) {
        final config = state.extra as AppUpdateConfigModel?;
        if (config == null) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        return MaintenanceScreen(config: config);
      },
    ),
    GoRoute(
      path: '/pdf-viewer',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        final title = extra['title'] as String? ?? 'दस्तऐवज';
        final url = extra['url'] as String?;
        final fallback = extra['fallbackRoute'] as String? ?? '/notices';
        return PdfViewerScreen(title: title, url: url, fallbackRoute: fallback);
      },
    ),
    GoRoute(
      path: '/election',
      builder: (context, state) => const ElectionScreen(),
    ),
    GoRoute(
      path: '/candidate-detail',
      builder: (context, state) {
        final candidate = state.extra as Map<String, dynamic>? ?? {};
        return CandidateDetailScreen(candidate: candidate);
      },
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
);
