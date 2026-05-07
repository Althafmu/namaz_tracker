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

  static Box<Map> get box {
    if (_box == null || !_box!.isOpen) {
      throw StateError('GroupDashboardCache not initialized. Call init() first.');
    }
    return _box!;
  }

  static Future<void> cacheDashboard(int groupId, Map<String, dynamic> data) async {
    await box.put('group_$groupId', data);
  }

  static Map<String, dynamic>? getCachedDashboard(int groupId) {
    final data = box.get('group_$groupId');
    if (data != null) {
      return Map<String, dynamic>.from(data);
    }
    return null;
  }

  static Future<void> clearCache(int groupId) async {
    await box.delete('group_$groupId');
  }
}