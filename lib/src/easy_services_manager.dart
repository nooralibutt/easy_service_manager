import 'dart:convert';
import 'dart:io';

import 'package:easy_ads_flutter/easy_ads_flutter.dart';
import 'package:easy_service_manager/src/models/app_info.dart';
import 'package:easy_service_manager/src/models/notification_model.dart';
import 'package:easy_service_manager/src/services/ad_manager.dart';
import 'package:easy_service_manager/src/services/easy_notification_manager.dart';
import 'package:easy_service_manager/src/services/more_settings.dart';
import 'package:easy_service_manager/src/services/rating_manager.dart';
import 'package:easy_service_manager/src/services/remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

class EasyServicesManager {
  EasyServicesManager._easyServicesManager();
  static final EasyServicesManager instance =
      EasyServicesManager._easyServicesManager();

  AppInfo _appInfo = AppInfo();
  final AdManager _adManager = AdManager();
  EasyNotificationManager? _notificationManager;
  List<String>? _notificationsList;

  /// Standard remote config fetched from server
  RemoteConfig? get remoteConfig => _remoteConfig;
  RemoteConfig? _remoteConfig;

  /// It will contain all the raw data fetched from server, you can use your own parser to parse it.
  Map<String, dynamic>? get remoteRawConfig => _remoteRawConfig;
  Map<String, dynamic>? _remoteRawConfig;

  /// You must have to initialize it on the start of the app
  Future<void> initialize({
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

    /// It will be your easy ads AdIdManager
    final IAdIdManager? adIdManager,

    /// if [true] then app open ad will be shown on app state change
    bool isShowAppOpenOnAppStateChange = false,

    /// This is the app remote configuration settings endpoint url
    final String? remoteConfigEndpointUrl,

    ///  This is the privacy policy text or link
    final String? privacyPolicy,

    ///  For custom key of wallpapers
    final RemoteConfigKeyMapper? wallpapersKey,

    ///  if `useNotifications = true`, manager will initialize local notifications
    final bool useNotifications = false,

    ///  For Scheduling local notifications, provide notifications list here
    final List<String>? notificationsList,

    ///  if `isAutoScheduleNotification = true`, manager schedule provided notifications list here automatically
    final bool isAutoScheduleNotification = true,
  }) async {
    final packageInfo = await PackageInfo.fromPlatform();

    if (remoteConfigEndpointUrl != null && remoteConfigEndpointUrl.isNotEmpty) {
      await _fetch(remoteConfigEndpointUrl, wallpapersKey);
    }

    await EasyRatingManager.incrementAppLaunches();

    if (adIdManager != null) {
      await _adManager.initialize(
        adIdManager: adIdManager,
        adKeywords: adKeywords,
        adSetting: _remoteConfig,
        isShowAppOpenOnAppStateChange: isShowAppOpenOnAppStateChange,
      );
    }

    _appInfo = AppInfo(
      appStoreID: appStoreID,
      itunesMoreAppLink: itunesMoreAppLink,
      androidDeveloperName: androidDeveloperName,
      supportEmail: supportEmail,
      aboutAppDescription: aboutAppDescription,
      appIconPath: appIconPath,
      privacyPolicy: privacyPolicy,
      appName: packageInfo.appName,
      packageName: packageInfo.packageName,
      versionAndBuild: '${packageInfo.version}+${packageInfo.buildNumber}',
    );

    if (useNotifications) {
      _notificationManager = EasyNotificationManager();
      _notificationsList = notificationsList;
      await _notificationManager?.init(appInfo: _appInfo);
      if ((_notificationsList?.isNotEmpty ?? false) &&
          isAutoScheduleNotification) scheduleAllNotifications();
    }
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
  Widget showBannerAd() => _adManager.showPriorityBanner();

  /// This will show the Interstitial ad
  bool showInterstitialAd({Function? onInterstitialClosed}) =>
      _adManager.showInterstitial(onInterstitialClosed: onInterstitialClosed);

  /// This will show the Interstitial ad with count from the remote config settings
  void showCountedInterstitialAd({Function? onInterstitialClosed}) => _adManager
      .showCountedInterstitial(onInterstitialClosed: onInterstitialClosed);

  /// This will show the Rewarded ad
  void showRewardedAd({Function? onRewardedClosed}) =>
      _adManager.showRewardedAd(onRewardedClosed: onRewardedClosed);

  Future<void> _fetch(
      String endpointUrl, RemoteConfigKeyMapper? wallpapersKey) async {
    try {
      final startIndex = endpointUrl.indexOf('/');
      final domain = endpointUrl.substring(0, startIndex);
      final endpoint = endpointUrl.substring(startIndex, endpointUrl.length);

      final url = Uri.https(domain, endpoint);
      final response = await http.get(url,
          headers: {'Content-Type': 'application/json', 'Charset': 'utf-8'});
      if (response.statusCode == 200) {
        final str = utf8.decode(response.bodyBytes).replaceAll('\n', '');
        final decodedResponse = jsonDecode(str) as Map<String, dynamic>;
        _remoteRawConfig = decodedResponse;
        _remoteConfig = RemoteConfig.fromMap(decodedResponse, wallpapersKey);
      }
    } catch (e) {
      if (kDebugMode) print(e);
    }
  }

  /// Call this to schedule all local notifications
  void scheduleAllNotifications() {
    if (_notificationsList?.isEmpty ?? true) return;
    _notificationManager?.scheduleAllNotifications(_notificationsList!);
  }

  /// Call this to schedule single notification
  Future<void>? scheduleNotification(
          NotificationModel model, Duration duration) =>
      _notificationManager?.scheduleNotification(model, duration);

  /// Call this to cancel single notification
  Future<void>? cancelNotification(int id, {String? tag}) =>
      _notificationManager?.cancelNotification(id, tag: tag);
}
