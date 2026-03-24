import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Local data source for the offline prayer-log queue.
///
/// Owns Hive initialization with AES encryption (key stored in
/// flutter_secure_storage) and CRUD operations on the queue.
class OfflineQueueRepository {
  static const String _boxName = 'offline_sync_queue';
  static const String _hiveKeyStorageKey = 'hive_encryption_key';
  final FlutterSecureStorage _secureStorage;

  OfflineQueueRepository({FlutterSecureStorage? secureStorage})
      : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  /// Initialize Hive and open the encrypted box. Call once at app startup.
  Future<void> initialize() async {
    await Hive.initFlutter();
    final encryptionKey = await _getOrCreateEncryptionKey();
    await Hive.openBox<Map<dynamic, dynamic>>(
      _boxName,
      encryptionCipher: HiveAesCipher(encryptionKey),
    );
  }

  /// Gets the AES key from secure storage, or generates and stores a new one.
  Future<List<int>> _getOrCreateEncryptionKey() async {
    final existingKey = await _secureStorage.read(key: _hiveKeyStorageKey);
    if (existingKey != null) {
      return base64Decode(existingKey);
    }
    final newKey = Hive.generateSecureKey();
    await _secureStorage.write(
      key: _hiveKeyStorageKey,
      value: base64Encode(newKey),
    );
    return newKey;
  }

  /// Whether the queue has pending items.
  bool get isEmpty {
    try {
      return Hive.box<Map<dynamic, dynamic>>(_boxName).isEmpty;
    } catch (_) {
      return true;
    }
  }

  /// Add an action to the queue.
  Future<void> enqueueAction({
    required String prayerName,
    required bool completed,
    required bool inJamaat,
    required String location,
  }) async {
    final box = Hive.box<Map<dynamic, dynamic>>(_boxName);
    await box.add({
      'prayerName': prayerName,
      'completed': completed,
      'inJamaat': inJamaat,
      'location': location,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Get all queued actions as (key, data) pairs.
  List<MapEntry<dynamic, Map<dynamic, dynamic>>> getAllActions() {
    final box = Hive.box<Map<dynamic, dynamic>>(_boxName);
    return box.keys.map((key) {
      final value = box.get(key);
      return MapEntry(key, value ?? {});
    }).toList();
  }

  /// Remove a processed action by its Hive key.
  Future<void> dequeueAction(dynamic key) async {
    final box = Hive.box<Map<dynamic, dynamic>>(_boxName);
    await box.delete(key);
  }
}
