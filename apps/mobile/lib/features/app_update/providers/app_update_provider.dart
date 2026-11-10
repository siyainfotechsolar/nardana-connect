import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nardana_connect/features/app_update/services/app_update_service.dart';

final appUpdateServiceProvider = Provider<AppUpdateService>((ref) {
  return AppUpdateService.instance;
});

class AppUpdateNotifier extends StateNotifier<AsyncValue<AppUpdateCheckResult>> {
  final AppUpdateService _service;

  AppUpdateNotifier(this._service) : super(const AsyncValue.loading()) {
    checkUpdates();
  }

  Future<void> checkUpdates({bool forceRefresh = false}) async {
    state = const AsyncValue.loading();
    try {
      final result = await _service.checkUpdateStatus(forceRefresh: forceRefresh);
      state = AsyncValue.data(result);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> dismissOptional() async {
    final current = state.value;
    if (current?.config != null) {
      await _service.dismissOptionalUpdate(current!.config!.latestVersion);
      // Re-evaluate to set status back to upToDate
      await checkUpdates(forceRefresh: false);
    }
  }

  Future<bool> launchUpdate() async {
    final current = state.value;
    if (current?.config != null) {
      return await _service.launchUpdateUrl(current!.config!);
    }
    return false;
  }
}

final appUpdateNotifierProvider =
    StateNotifierProvider<AppUpdateNotifier, AsyncValue<AppUpdateCheckResult>>((ref) {
  final service = ref.watch(appUpdateServiceProvider);
  return AppUpdateNotifier(service);
});

