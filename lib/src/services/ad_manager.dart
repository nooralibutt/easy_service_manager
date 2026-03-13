import 'dart:async';
import 'dart:io';

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:easy_ads_flutter/easy_ads_flutter.dart';
import 'package:easy_service_manager/src/services/remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AdManager {
  StreamSubscription? _streamSubscription;
  RemoteConfig? adSetting;

  Future<void> initialize({
    required IAdIdManager adIdManager,
    bool isShowAppOpenOnAppStateChange = false,
    List<String>? adKeywords,
    RemoteConfig? adSetting,
    final bool autoLoadAds = true,
  }) async {
    this.adSetting = adSetting;
    final isIosApproving =
        Platform.isIOS && (adSetting?.isIosApproving ?? true);
    final isAndroidApproving =
        Platform.isAndroid && (adSetting?.isAndroidApproving ?? true);

    bool contextualAds = true;
    if (Platform.isIOS) {
      TrackingStatus status =
          await AppTrackingTransparency.trackingAuthorizationStatus;
      if (status == TrackingStatus.notDetermined) {
        status = await AppTrackingTransparency.requestTrackingAuthorization();
      }

      contextualAds = status != TrackingStatus.authorized;
    }

    if (Platform.isAndroid || contextualAds) {
      bool authorized = await ConsentManager.gatherGdprConsent(
        debugGeography: kDebugMode ? DebugGeography.debugGeographyEea : null,
      );

      // bool privacyAuthorized = await ConsentManager.gatherPrivacyConsent();
    }

    final targetingInfo = AdRequest(
      nonPersonalizedAds: Platform.isIOS ? contextualAds : null,
      keywords: adKeywords,
    );

    final requestConf = RequestConfiguration(
      maxAdContentRating: isIosApproving || isAndroidApproving
          ? MaxAdContentRating.pg
          : null,
    );
    await EasyAds.instance.initialize(
      adIdManager,
      admobConfiguration: requestConf,
      adMobAdRequest: targetingInfo,
      isShowAppOpenOnAppStateChange: isShowAppOpenOnAppStateChange,
      showAdBadge: isAndroidApproving,
      autoLoadAds: autoLoadAds,
    );
  }

  static void showAppOpenAd() => EasyAds.instance.showAd(AdUnitType.appOpen);

  bool showInterstitial({
    Function? onInterstitialClosed,
    int loaderDuration = 0,
    BuildContext? context,
  }) {
    if (EasyAds.instance.showAd(
      AdUnitType.interstitial,
      loaderDuration: loaderDuration,
      context: context,
    )) {
      if (onInterstitialClosed != null) {
        _streamSubscription?.cancel();
        _streamSubscription = EasyAds.instance.onEvent.listen((event) {
          if (event.adUnitType == AdUnitType.interstitial &&
              event.type == AdEventType.adDismissed) {
            _streamSubscription?.cancel();
            onInterstitialClosed.call();
          }
        });
      }
      return true;
    } else {
      onInterstitialClosed?.call();
      return false;
    }
  }

  int _count = 0;

  void showCountedInterstitial({
    Function? onInterstitialClosed,
    int loaderDuration = 0,
    BuildContext? context,
  }) {
    _count++;
    final serverCounter = adSetting?.interstitialCounter ?? 2;
    if (_count >= serverCounter &&
        showInterstitial(
          onInterstitialClosed: onInterstitialClosed,
          loaderDuration: loaderDuration,
          context: context,
        )) {
      _count = 0;
    }
  }

  bool showRewardedAd({Function? onRewardedClosed}) {
    _streamSubscription?.cancel();
    _streamSubscription = EasyAds.instance.onEvent.listen((event) {
      if (event.adUnitType == AdUnitType.rewarded &&
          event.type == AdEventType.adShowed) {
        _streamSubscription?.cancel();
        onRewardedClosed?.call();
      }
    });
    return false;
  }

  Future<void> showJitAppOpen({Function? onClosed}) async {
    await EasyAds.instance.showJitAppOpen(
      onAdDismissed: () => onClosed?.call(),
    );
  }

  Future<void> showJitInterstitial(
    BuildContext context, {
    Function? onClosed,
  }) async {
    await EasyAds.instance.showJitInterstitial(
      context,
      onAdDismissed: () => onClosed?.call(),
    );
  }

  Future<void> showJitRewarded(
    BuildContext context, {
    required void Function(BuildContext context) onEarnedReward,
  }) async {
    await EasyAds.instance.showJitRewarded(
      context,
      onEarnedReward: onEarnedReward,
    );
  }

  Widget showNativeAd() => EasyAds.instance.createNativeAd();
}
