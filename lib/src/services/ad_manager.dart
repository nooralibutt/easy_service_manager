import 'dart:async';
import 'dart:io';

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:easy_ads_flutter/easy_ads_flutter.dart';
import 'package:easy_service_manager/src/services/remote_config.dart';
import 'package:flutter/material.dart';
import 'package:unity_ads_plugin/unity_ads_plugin.dart';

class AdManager {
  List<AdPriority>? adPriorityList;
  List<AdNetwork>? bannerAdPriorityList;
  StreamSubscription? _streamSubscription;
  RemoteConfig? adSetting;

  Future<void> initialize(
      {required IAdIdManager adIdManager,
      List<String>? adKeywords,
      RemoteConfig? adSetting}) async {
    this.adSetting = adSetting;
    final isIosApproving =
        Platform.isIOS && (adSetting?.isIosApproving ?? true);
    final isAndroidApproving =
        Platform.isAndroid && (adSetting?.isAndroidApproving ?? true);

    if (Platform.isIOS) {
      TrackingStatus status =
          await AppTrackingTransparency.trackingAuthorizationStatus;
      if (status == TrackingStatus.notDetermined) {
        status = await AppTrackingTransparency.requestTrackingAuthorization();
      }

      await UnityAds.setPrivacyConsent(
          PrivacyConsentType.gdpr, status == TrackingStatus.authorized);
      await UnityAds.setPrivacyConsent(
          PrivacyConsentType.ccpa, status == TrackingStatus.authorized);
      await UnityAds.setPrivacyConsent(
          PrivacyConsentType.pipl, status == TrackingStatus.authorized);

      await Future.delayed(const Duration(seconds: 1));
    }

    await UnityAds.setPrivacyConsent(
        PrivacyConsentType.ageGate, isIosApproving || isAndroidApproving);

    final targetingInfo = AdRequest(
        nonPersonalizedAds: !isIosApproving || !isAndroidApproving,
        keywords: adKeywords);

    final requestConf = RequestConfiguration(
        maxAdContentRating: isIosApproving || isAndroidApproving
            ? MaxAdContentRating.pg
            : MaxAdContentRating.t);
    await EasyAds.instance.initialize(
      adIdManager,
      admobConfiguration: requestConf,
      adMobAdRequest: targetingInfo,
      showAdBadge: isAndroidApproving,
      fbiOSAdvertiserTrackingEnabled: isIosApproving,
      isAgeRestrictedUserForApplovin: isIosApproving || isAndroidApproving,
    );

    adPriorityList = adSetting?.adPriorityList ?? [];
    bannerAdPriorityList = adSetting?.getBannerPriorityList();
  }

  Widget showPriorityBanner({AdSize adSize = AdSize.banner}) {
    final list = bannerAdPriorityList;
    if (list == null || list.isEmpty) {
      return EasySmartBannerAd(adSize: adSize);
    }

    return EasySmartBannerAd(priorityAdNetworks: list, adSize: adSize);
  }

  bool _showPriorityInterstitial() {
    final list = adPriorityList;
    if (list == null || list.isEmpty) {
      return EasyAds.instance.showAd(AdUnitType.interstitial);
    }

    for (int i = 0; i < list.length; i++) {
      if (list[i] == AdPriority.facebook) {
        if (EasyAds.instance.showAd(AdUnitType.interstitial,
            adNetwork: AdNetwork.facebook)) return true;
      } else if (list[i] == AdPriority.unity) {
        if (EasyAds.instance.showAd(AdUnitType.interstitial,
            adNetwork: AdNetwork.unity)) return true;
      } else if (list[i] == AdPriority.appLovin) {
        if (EasyAds.instance.showAd(AdUnitType.interstitial,
            adNetwork: AdNetwork.appLovin)) return true;
      } else if (list[i] == AdPriority.admob) {
        if (EasyAds.instance.showAd(AdUnitType.interstitial,
            adNetwork: AdNetwork.admob)) return true;
      }
    }

    return EasyAds.instance.showAd(AdUnitType.interstitial);
  }

  bool showInterstitial({Function? onInterstitialClosed}) {
    if (_showPriorityInterstitial()) {
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
  void showCountedInterstitial({Function? onInterstitialClosed}) {
    _count++;
    final serverCounter = adSetting?.interstitialCounter ?? 2;
    if (_count >= serverCounter &&
        showInterstitial(onInterstitialClosed: onInterstitialClosed)) {
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
