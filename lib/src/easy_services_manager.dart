import 'package:easy_service_manager/src/utils/app_info.dart';

class EasyServicesManager {
  EasyServicesManager._easyServicesManager();
  static final EasyServicesManager instance =
      EasyServicesManager._easyServicesManager();

  late final String? appStoreID;
  late final String? itunesMoreAppLink;
  late final String? androidDeveloperName;
  late final String? supportEmail;
  late final String? aboutAppDescription;
  late final String? appIconPath;
  late final String? privacyPolicy;

  Future<void> initialize(
      {final String? appStoreID,
      final String? itunesMoreAppLink,
      final String? androidDeveloperName,
      final String? supportEmail,
      final String? aboutAppDescription,
      final String? appIconPath,
      final String? privacyPolicy}) async {
    this.appStoreID = appStoreID;
    this.itunesMoreAppLink = itunesMoreAppLink;
    this.androidDeveloperName = androidDeveloperName;
    this.supportEmail = supportEmail;
    this.aboutAppDescription = aboutAppDescription;
    this.appIconPath = appIconPath;
    this.privacyPolicy = privacyPolicy;
    await AppInfo.instance.init();
  }
}
