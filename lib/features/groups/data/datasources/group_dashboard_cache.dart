import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

class GroupDashboardCache {
  static const String _boxName = 'dashboard_cache';
  static Box<Map>? _box;

  static Future<void> init() async {
    if (!Hive.isBoxOpen(_boxName)) {
      _box = await Hive.openBox<Map>(_boxName);
    } else {
      _box = Hive.box<Map>(_boxName);
    }
  }

  static Box<Map>? _safeBox() {
    if (_box == null || !_box!.isOpen) {
      try {
        if (Hive.isBoxOpen(_boxName)) {
          _box = Hive.box<Map>(_boxName);
        }
      } catch (_) {
        return null;
      }
    }
    return _box;
  }

  static Future<void> cacheDashboard(String groupId, Map<String, dynamic> data) async {
    final b = _safeBox();
    if (b == null) {
      debugPrint('[Cache] Box not available, skipping cache');
      return;
    }
    try {
      await b.put('group_$groupId', data);
    } catch (e) {
      debugPrint('[Cache] Failed to cache dashboard: $e');
    }
  }

  static Map<String, dynamic>? getCachedDashboard(String groupId) {
    final b = _safeBox();
    if (b == null) {
      debugPrint('[Cache] Box not available, returning null');
      return null;
    }
    try {
      final data = b.get('group_$groupId');
      if (data != null) {
        return Map<String, dynamic>.from(data);
      }
    } catch (e) {
      debugPrint('[Cache] Failed to read cache: $e');
    }
    return null;
  }

  static Future<void> clearCache(String groupId) async {
    final b = _safeBox();
    if (b == null) return;
    try {
      await b.delete('group_$groupId');
    } catch (e) {
      debugPrint('[Cache] Failed to clear cache: $e');
    }
  }
}