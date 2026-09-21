import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';

class ContextEnricher {
  static Future<Map<String, String>> enrich() async {
    final packageInfo = await PackageInfo.fromPlatform();
    final deviceInfo = DeviceInfoPlugin();

    String platform = 'unknown';
    String deviceModel = 'unknown';

    try {
      if (Platform.isAndroid) {
        final info = await deviceInfo.androidInfo;
        platform = 'android';
        deviceModel = '${info.manufacturer} ${info.model}';
      } else if (Platform.isIOS) {
        final info = await deviceInfo.iosInfo;
        platform = 'ios';
        deviceModel = info.utsname.machine;
      } else if (Platform.isWindows) {
        platform = 'windows';
        deviceModel = 'windows';
      } else if (Platform.isMacOS) {
        platform = 'macos';
        deviceModel = 'macos';
      } else if (Platform.isLinux) {
        platform = 'linux';
        deviceModel = 'linux';
      }
    } catch (_) {}

    return {
      'appVersion': '${packageInfo.version}+${packageInfo.buildNumber}',
      'platform': platform,
      'deviceModel': deviceModel,
    };
  }
}
