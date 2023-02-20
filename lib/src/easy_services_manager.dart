import 'dart:io';

import 'package:easy_ads_flutter/easy_ads_flutter.dart';
import 'package:easy_service_manager/src/services/ad_manager.dart';
import 'package:easy_service_manager/src/services/ad_setting.dart';
import 'package:easy_service_manager/src/services/more_settings.dart';
import 'package:easy_service_manager/src/services/rating_manager.dart';
import 'package:easy_service_manager/src/utils/app_info.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class EasyServicesManager {
  EasyServicesManager._easyServicesManager();
  static final EasyServicesManager instance =
      EasyServicesManager._easyServicesManager();

  AppInfo _appInfo = AppInfo();
  final AdManager _adManager = AdManager();

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

      /// These are the add keywords
      final List<String>? adKeywords,

      /// These are the add keywords
      final IAdIdManager? adIdManager,

      /// This is the app remote configuration settings endpoint url
      final String? remoteConfigEndpointUrl,

      ///  This is the privacy policy text or link
      final String? privacyPolicy}) async {
    final info = await PackageInfo.fromPlatform();
    await AdSetting.fetch(remoteConfigEndpointUrl);
    await EasyRatingManager.incrementAppLaunches();

    await _adManager.initialize(
        adIdManager: adIdManager ?? const TestAdIdManager(),
        adKeywords: adKeywords);

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

  /// This will show the banner ad as widget
  Widget showBanner() => _adManager.showPriorityBanner();

  /// This will show the Interstitial ad
  bool showInterstitial({Function? onInterstitialClosed}) =>
      _adManager.showInterstitial(onInterstitialClosed: onInterstitialClosed);

  /// This will show the Interstitial ad with count from the remote config settings
  void showCountedInterstitial({Function? onInterstitialClosed}) => _adManager
      .showCountedInterstitial(onInterstitialClosed: onInterstitialClosed);

  /// This will show the Rewarded ad
  void showRewardedAd({Function? onRewardedClosed}) =>
      _adManager.showRewardedAd(onRewardedClosed: onRewardedClosed);
}
