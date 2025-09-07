// lib/domain/services/anonymous_identity_service.dart
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class AnonymousIdentityService {
  static const _storageKey = 'anonymous_device_id';
  final _secureStorage = const FlutterSecureStorage();
  final _uuid = const Uuid();

  Future<String> getAnonymousId() async {
    String? deviceId;
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      deviceId = prefs.getString(_storageKey);
    } else {
      deviceId = await _secureStorage.read(key: _storageKey);
    }
    
    if (deviceId == null) {
      deviceId = _uuid.v4();
      if (kIsWeb) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_storageKey, deviceId);
      } else {
        await _secureStorage.write(key: _storageKey, value: deviceId);
      }
    }
    return deviceId;
  }
}