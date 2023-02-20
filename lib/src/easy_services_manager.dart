import 'dart:io';

import 'package:easy_service_manager/src/more_settings.dart';
import 'package:easy_service_manager/src/rating_manager.dart';
import 'package:easy_service_manager/src/utils/app_info.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class EasyServicesManager {
  EasyServicesManager._easyServicesManager();
  static final EasyServicesManager instance =
      EasyServicesManager._easyServicesManager();

  AppInfo _appInfo = AppInfo();

  /// You have to initialize it on the start of the app
  Future<void> initialize(
      {
      /// This is the appstore app id
      final String? appStoreID,

      /// This is the apple store more apps link
      final String? itunesMoreAppLink,

      /// This is the google play store account name
      final String? androidDeveloperName,

      /// This is the support email
      final String? supportEmail,

      /// This is the about dialog description
      final String? aboutAppDescription,

      /// This is the app launcher icon asset path
      final String? appIconPath,

      ///  This is the privacy policy text or link
      final String? privacyPolicy}) async {
    final info = await PackageInfo.fromPlatform();
    await EasyRatingManager.incrementAppLaunches();

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

  ///  This will return more setting screen
  Widget moreScreen() => MoreSettings(appInfo: _appInfo);

  /// This will return rate floating action button if user haven't rated yet
  Widget? rateFloatingActionButton() {
    if (EasyRatingManager.isAlreadyRated ||
        (Platform.isIOS && _appInfo.appStoreID == null)) {
      return null;
    }
    return RateFloatingButton(appStoreId: _appInfo.appStoreID);
  }

  /// This will return custom rating dialog if you want to show rating dialog on your own
  Future<bool> tryShowingCustomInAppReview(BuildContext context) =>
      EasyRatingManager.tryShowingCustomInAppReview(
          context, _appInfo.appStoreID);

  /// This will return custom in app review dialog if you want to show in app review dialog on your own
  Future<bool> tryShowingNativeInAppReview() =>
      EasyRatingManager.tryShowingNativeInAppReview();
}
