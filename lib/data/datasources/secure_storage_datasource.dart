import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageDataSource {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  Future<void> writeApiKey(String configId, String apiKey) async {
    try {
      await _storage.write(key: 'api_key_$configId', value: apiKey);
    } catch (e) {
      debugPrint('SecureStorage write error: $e');
    }
  }

  Future<String?> readApiKey(String configId) async {
    try {
      return await _storage.read(key: 'api_key_$configId');
    } catch (e) {
      debugPrint('SecureStorage read error: $e');
      return null;
    }
  }

  Future<void> deleteApiKey(String configId) async {
    try {
      await _storage.delete(key: 'api_key_$configId');
    } catch (e) {
      debugPrint('SecureStorage delete error: $e');
    }
  }
}
