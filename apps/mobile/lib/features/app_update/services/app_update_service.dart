import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:nardana_connect/core/services/supabase_service.dart';
import 'package:nardana_connect/features/app_update/models/app_update_config_model.dart';
import 'package:nardana_connect/features/app_update/services/version_comparator.dart';

enum AppUpdateStatus {
  upToDate,
  forceUpdateRequired,
  optionalUpdateAvailable,
  maintenanceMode,
  error,
}

class AppUpdateCheckResult {
  final AppUpdateStatus status;
  final String installedVersion;
  final int installedBuildNumber;
  final AppUpdateConfigModel? config;
  final String? errorMessage;

  const AppUpdateCheckResult({
    required this.status,
    required this.installedVersion,
    required this.installedBuildNumber,
    this.config,
    this.errorMessage,
  });

  bool get isBlocking =>
      status == AppUpdateStatus.forceUpdateRequired ||
      status == AppUpdateStatus.maintenanceMode;
}

class AppUpdateService {
  static final AppUpdateService instance = AppUpdateService._internal();
  AppUpdateService._internal();

  AppUpdateConfigModel? _cachedConfig;
  DateTime? _lastFetchTime;
  static const Duration _cacheDuration = Duration(seconds: 30);

  PackageInfo? _cachedPackageInfo;

  /// Retrieves the installed app PackageInfo (cached or fresh)
  Future<PackageInfo> getPackageInfo({bool forceRefresh = false}) async {
    if (_cachedPackageInfo != null && !forceRefresh) {
      return _cachedPackageInfo!;
    }
    _cachedPackageInfo = await PackageInfo.fromPlatform();
    return _cachedPackageInfo!;
  }

  /// Fetches published update configuration from Supabase
  Future<AppUpdateConfigModel?> fetchConfig({bool forceRefresh = false}) async {
    final now = DateTime.now();
    if (!forceRefresh &&
        _cachedConfig != null &&
        _lastFetchTime != null &&
        now.difference(_lastFetchTime!) < _cacheDuration) {
      return _cachedConfig;
    }

    try {
      final res = await SupabaseService.client
          .from('app_update_config')
          .select('*')
          .eq('platform', 'android')
          .maybeSingle();

      if (res != null) {
        _cachedConfig = AppUpdateConfigModel.fromJson(res);
        _lastFetchTime = now;
        return _cachedConfig;
      }
    } catch (e) {
      debugPrint('Error fetching app update config: $e');
    }
    return _cachedConfig;
  }

  /// Evaluates update status
  Future<AppUpdateCheckResult> checkUpdateStatus({bool forceRefresh = false}) async {
    try {
      final packageInfo = await getPackageInfo(forceRefresh: forceRefresh);
      final installedVersion = packageInfo.version;
      final installedBuild = int.tryParse(packageInfo.buildNumber) ?? 1;

      final config = await fetchConfig(forceRefresh: forceRefresh);
      if (config == null) {
        return AppUpdateCheckResult(
          status: AppUpdateStatus.upToDate,
          installedVersion: installedVersion,
          installedBuildNumber: installedBuild,
          errorMessage: 'अपडेट कॉन्फिगरेशन लोड होऊ शकले नाही.',
        );
      }

      // 1. Check Maintenance Mode first
      if (config.maintenanceMode) {
        return AppUpdateCheckResult(
          status: AppUpdateStatus.maintenanceMode,
          installedVersion: installedVersion,
          installedBuildNumber: installedBuild,
          config: config,
        );
      }

      // 2. Check Force Update
      // If below minimum supported version/build OR (forceUpdateEnabled is true AND installed < latest)
      final belowMin = VersionComparator.isBelowMinimum(
        installedVersion: installedVersion,
        installedBuild: installedBuild,
        minVersion: config.minimumSupportedVersion,
        minBuild: config.minimumSupportedBuild,
      );

      final newerAvailable = VersionComparator.isNewerAvailable(
        installedVersion: installedVersion,
        installedBuild: installedBuild,
        latestVersion: config.latestVersion,
        latestBuild: config.latestBuildNumber,
      );

      if (belowMin || (config.forceUpdateEnabled && newerAvailable)) {
        return AppUpdateCheckResult(
          status: AppUpdateStatus.forceUpdateRequired,
          installedVersion: installedVersion,
          installedBuildNumber: installedBuild,
          config: config,
        );
      }

      // 3. Check Optional Update
      if (config.optionalUpdateEnabled && newerAvailable) {
        final isDismissed = await _isOptionalDismissed(config.latestVersion);
        if (!isDismissed) {
          return AppUpdateCheckResult(
            status: AppUpdateStatus.optionalUpdateAvailable,
            installedVersion: installedVersion,
            installedBuildNumber: installedBuild,
            config: config,
          );
        }
      }

      return AppUpdateCheckResult(
        status: AppUpdateStatus.upToDate,
        installedVersion: installedVersion,
        installedBuildNumber: installedBuild,
        config: config,
      );
    } catch (e) {
      debugPrint('Update check error: $e');
      return AppUpdateCheckResult(
        status: AppUpdateStatus.upToDate,
        installedVersion: '1.0.0',
        installedBuildNumber: 1,
        errorMessage: e.toString(),
      );
    }
  }

  /// Persistent dismissal preference for optional update
  Future<bool> _isOptionalDismissed(String version) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dismissedVer = prefs.getString('opt_update_dismissed_version');
      final dismissedTimeStr = prefs.getString('opt_update_dismissed_time');

      if (dismissedVer != version || dismissedTimeStr == null) {
        return false;
      }

      final dismissedTime = DateTime.tryParse(dismissedTimeStr);
      if (dismissedTime == null) return false;

      // Reset dismissal after 24 hours
      final hoursPassed = DateTime.now().difference(dismissedTime).inHours;
      return hoursPassed < 24;
    } catch (_) {
      return false;
    }
  }

  /// Dismiss optional update for 24 hours
  Future<void> dismissOptionalUpdate(String version) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('opt_update_dismissed_version', version);
      await prefs.setString('opt_update_dismissed_time', DateTime.now().toIso8601String());
    } catch (e) {
      debugPrint('Error dismissing optional update: $e');
    }
  }

  /// Launches Google Play Store or APK URL
  Future<bool> launchUpdateUrl(AppUpdateConfigModel config) async {
    // 1. Try native market:// scheme
    final marketUri = Uri.parse('market://details?id=in.nardana.connect.nardana_connect');
    if (await canLaunchUrl(marketUri)) {
      try {
        final success = await launchUrl(marketUri, mode: LaunchMode.externalApplication);
        if (success) return true;
      } catch (_) {}
    }

    // 2. Try Play Store Web URL
    if (config.playStoreUrl.isNotEmpty) {
      final playUri = Uri.parse(config.playStoreUrl);
      if (await canLaunchUrl(playUri)) {
        try {
          final success = await launchUrl(playUri, mode: LaunchMode.externalApplication);
          if (success) return true;
        } catch (_) {}
      }
    }

    // 3. Fallback to APK Download URL
    if (config.apkDownloadUrl.isNotEmpty) {
      final apkUri = Uri.parse(config.apkDownloadUrl);
      if (await canLaunchUrl(apkUri)) {
        return await launchUrl(apkUri, mode: LaunchMode.externalApplication);
      }
    }

    return false;
  }
}
