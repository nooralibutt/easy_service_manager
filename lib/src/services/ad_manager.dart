import 'dart:async';
import 'dart:io';

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:easy_ads_flutter/easy_ads_flutter.dart';
import 'package:easy_service_manager/src/services/remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:unity_ads_plugin/unity_ads_plugin.dart';

class AdManager {
  List<AdPriority>? adPriorityList;
  List<AdNetwork>? bannerAdPriorityList;
  StreamSubscription? _streamSubscription;
  RemoteConfig? adSetting;

  Future<void> initialize({
    required IAdIdManager adIdManager,
    bool isShowAppOpenOnAppStateChange = false,
    List<String>? adKeywords,
    RemoteConfig? adSetting,
    Map<int, List<int>>? segments,
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

    bool authorized = await ConsentManager.gatherGdprConsent(
        debugGeography: kDebugMode ? DebugGeography.debugGeographyEea : null);
    await UnityAds.setPrivacyConsent(PrivacyConsentType.gdpr, authorized);

    bool privacyAuthorized = await ConsentManager.gatherPrivacyConsent();
    await UnityAds.setPrivacyConsent(
        PrivacyConsentType.ccpa, privacyAuthorized);
    await UnityAds.setPrivacyConsent(
        PrivacyConsentType.pipl, privacyAuthorized);

    await UnityAds.setPrivacyConsent(
        PrivacyConsentType.ageGate, isIosApproving || isAndroidApproving);

    final targetingInfo = AdRequest(
        nonPersonalizedAds: Platform.isIOS ? contextualAds : null,
        keywords: adKeywords);

    final requestConf = RequestConfiguration(
        maxAdContentRating: isIosApproving || isAndroidApproving
            ? MaxAdContentRating.pg
            : null);
    await EasyAds.instance.initialize(
      adIdManager,
      admobConfiguration: requestConf,
      adMobAdRequest: targetingInfo,
      isShowAppOpenOnAppStateChange: isShowAppOpenOnAppStateChange,
      showAdBadge: isAndroidApproving,
      fbiOSAdvertiserTrackingEnabled: isIosApproving,
      isAgeRestrictedUserForApplovin: isIosApproving || isAndroidApproving,
      segments: segments,
    );

    adPriorityList = adSetting?.adPriorityList ?? [];
    bannerAdPriorityList = adSetting?.getBannerPriorityList();
  }

  static void showAppOpenAd() => EasyAds.instance.showAd(AdUnitType.appOpen);

  Widget showPriorityBanner({AdSize adSize = AdSize.banner}) {
    final list = bannerAdPriorityList;
    if (list == null || list.isEmpty) {
      return EasySmartBannerAd(adSize: adSize);
    }

    return EasySmartBannerAd(priorityAdNetworks: list, adSize: adSize);
  }

  bool _showPriorityInterstitial({
    int loaderDuration = 0,
    BuildContext? context,
  }) {
    final list = adPriorityList;
    if (list == null || list.isEmpty) {
      return EasyAds.instance.showAd(
        AdUnitType.interstitial,
        loaderDuration: loaderDuration,
        context: context,
      );
    }

    for (int i = 0; i < list.length; i++) {
      if (list[i] == AdPriority.facebook) {
        if (EasyAds.instance.showAd(
          AdUnitType.interstitial,
          adNetwork: AdNetwork.facebook,
          loaderDuration: loaderDuration,
          context: context,
        )) return true;
      } else if (list[i] == AdPriority.unity) {
        if (EasyAds.instance.showAd(
          AdUnitType.interstitial,
          adNetwork: AdNetwork.unity,
          loaderDuration: loaderDuration,
          context: context,
        )) return true;
      } else if (list[i] == AdPriority.appLovin) {
        if (EasyAds.instance.showAd(
          AdUnitType.interstitial,
          adNetwork: AdNetwork.appLovin,
          loaderDuration: loaderDuration,
          context: context,
        )) return true;
      } else if (list[i] == AdPriority.admob) {
        if (EasyAds.instance.showAd(
          AdUnitType.interstitial,
          adNetwork: AdNetwork.admob,
          loaderDuration: loaderDuration,
          context: context,
        )) return true;
      }
    }

    return EasyAds.instance.showAd(
      AdUnitType.interstitial,
      loaderDuration: loaderDuration,
      context: context,
    );
  }

  bool showInterstitial({
    Function? onInterstitialClosed,
    int loaderDuration = 0,
    BuildContext? context,
  }) {
    if (_showPriorityInterstitial(
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
}
