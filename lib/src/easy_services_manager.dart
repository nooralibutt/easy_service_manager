import 'package:easy_service_manager/easy_service_manager.dart';
import 'package:easy_service_manager/src/rating_manager.dart';
import 'package:easy_service_manager/src/utils/app_info.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class EasyServicesManager {
  EasyServicesManager._easyServicesManager();
  static final EasyServicesManager instance =
      EasyServicesManager._easyServicesManager();

  AppInfo _appInfo = AppInfo();

  Future<void> initialize(
      {final String? appStoreID,
      final String? itunesMoreAppLink,
      final String? androidDeveloperName,
      final String? supportEmail,
      final String? aboutAppDescription,
      final String? appIconPath,
      final String? privacyPolicy}) async {
    final info = await PackageInfo.fromPlatform();
    RatingManager.incrementAppLaunches();

    _appInfo = AppInfo(
      appStoreID: appStoreID,
      itunesMoreAppLink: itunesMoreAppLink,
      androidDeveloperName: androidDeveloperName,
      supportEmail: supportEmail,
      aboutAppDescription: aboutAppDescription,
      appIconPath: appIconPath,
      privacyPolicy: privacyPolicy,
      appName: info.appName,
      packageName: info.packageName,
      versionAndBuild: '${info.version}+${info.buildNumber}',
    );
  }

  Widget moreScreen() => MoreSettings(appInfo: _appInfo);

  Widget rateFloatingActionButton() =>
      RateFloatingButton(appStoreId: _appInfo.appStoreID);

  Future<bool> tryShowingCustomInAppReview(BuildContext context) =>
      RatingManager.tryShowingCustomInAppReview(context, _appInfo.appStoreID);

  Future<bool> tryShowingNativeInAppReview() =>
      RatingManager.tryShowingNativeInAppReview();

  Future<bool?> showRatingDialog(BuildContext context, String? appStoreId) =>
      RatingManager.showRatingDialog(context, appStoreId);
}
