import 'dart:async';

import 'package:package_info_plus/package_info_plus.dart';

class AppInfo {
  // Singleton instance code
  static final AppInfo _instance = AppInfo._();
  static AppInfo get instance => _instance;
  AppInfo._();

  late PackageInfo _info;

  Future<void> init() async {
    _info = await PackageInfo.fromPlatform();
  }

  String get appName => _info.appName;
  String get packageName => _info.packageName;
  String get versionAndBuild => '${_info.version}+${_info.buildNumber}';
}
