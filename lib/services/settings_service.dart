import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// خدمة تخزين إعدادات التطبيق (عنوان خادم SRA) محلياً على الجهاز.
///
/// مهم جداً عند التشغيل على Android:
/// - إذا كان الخادم يعمل على جهاز الكمبيوتر نفسه وتستخدم محاكي Android
///   (Emulator)، استخدم: http://10.0.2.2:8000
/// - إذا كنت تستخدم جهاز Android حقيقي على نفس شبكة Wi-Fi، استخدم
///   عنوان IP الخاص بجهاز الكمبيوتر، مثل: http://192.168.1.50:8000
/// - على Windows/Web (إذا كان الخادم يعمل على نفس الجهاز): http://localhost:8000
class SettingsService {
  static const _kServerUrlKey = 'sra_server_url';

  static String get defaultServerUrl {
    if (kIsWeb) return 'http://localhost:8000';
    // قيمة افتراضية معقولة لمحاكي Android؛ يمكن تغييرها من شاشة الإعدادات
    return 'http://10.0.2.2:8000';
  }

  static Future<String> getServerUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kServerUrlKey) ?? defaultServerUrl;
  }

  static Future<void> setServerUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    // إزالة أي شرطة مائلة زائدة في النهاية
    final cleaned = url.endsWith('/') ? url.substring(0, url.length - 1) : url;
    await prefs.setString(_kServerUrlKey, cleaned);
  }
}
