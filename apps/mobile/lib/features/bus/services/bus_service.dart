import 'package:flutter/foundation.dart';
import 'package:nardana_connect/core/services/supabase_service.dart';
import 'package:nardana_connect/features/bus/models/bus_timetable_model.dart';

class BusService {
  static final BusService instance = BusService._();
  BusService._();

  /// Fetch only published bus timetable entries from Supabase
  Future<List<BusTimetableModel>> fetchTimetables() async {
    try {
      final res = await SupabaseService.client
          .from('bus_timetables')
          .select('*')
          .eq('is_published', true)
          .order('display_order', ascending: true);

      if (res.isNotEmpty) {
        return (res as List)
            .map((e) => BusTimetableModel.fromMap(e as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      debugPrint('[BusService] fetchTimetables error: $e');
    }

    return BusTimetableModel.fallbackList;
  }
}

