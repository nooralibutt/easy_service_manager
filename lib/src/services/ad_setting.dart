import 'package:easy_ads_flutter/easy_ads_flutter.dart';
import 'package:flutter/foundation.dart';

enum AdPriority { admob, appLovin, unity, facebook, any }

extension AdPriorityExtension on AdPriority {
  String get value => describeEnum(this);
}

const adPriorityStringToEnumMap = {
  'admob': AdPriority.admob,
  'appLovin': AdPriority.appLovin,
  'unity': AdPriority.unity,
  'facebook': AdPriority.facebook,
  'any': AdPriority.any,
};

const _defaultAdPriority = [
  AdPriority.admob,
  AdPriority.facebook,
  AdPriority.unity,
  AdPriority.appLovin,
  AdPriority.any
];

typedef RemoteConfigKeyMapper = String Function(
    bool isAndroidApproving, bool isIosApproving);

class RemoteConfig {
  final List<AdPriority> adPriorityList;
  final List<AdPriority> bannerAdPriorityList;
  final bool isAndroidApproving;
  final bool isIosApproving;
  final int interstitialCounter;
  final Map<String, dynamic> wallpapersData;
  final Map<String, dynamic> chatLevelsData;
  final Map<String, dynamic> presentationData;
  final Map<String, dynamic> quizLevelCategoriesData;

  const RemoteConfig({
    this.adPriorityList = _defaultAdPriority,
    this.bannerAdPriorityList = _defaultAdPriority,
    this.interstitialCounter = 2,
    this.isIosApproving = true,
    this.isAndroidApproving = true,
    this.wallpapersData = const {},
    this.chatLevelsData = const {},
    this.presentationData = const {},
    this.quizLevelCategoriesData = const {},
  });

  factory RemoteConfig.fromMap(
      Map<String, dynamic> map, RemoteConfigKeyMapper? wallpapersKey) {
    final isAndroidApproving = map["is_android_approving"] ?? true;
    final isIosApproving = map["is_ios_approving"] ?? true;
    final key =
        wallpapersKey?.call(isAndroidApproving, isIosApproving) ?? 'wallpapers';

    return RemoteConfig(
      adPriorityList: _toList(map["ad_priority"]),
      bannerAdPriorityList: _toList(map["banner_ad_priority"]),
      interstitialCounter: map["interstitial_ad_count"],
      isAndroidApproving: map["is_android_approving"] ?? true,
      isIosApproving: map["is_ios_approving"] ?? true,
      wallpapersData: map[key] ?? map["data"],
      chatLevelsData: map["chatLevels"],
      presentationData: map["presentationData"],
      quizLevelCategoriesData: map["quizLevelCategories"],
    );
  }

  static List<AdPriority> _toList(final List<dynamic> list) => list
      .map<AdPriority>(
          (e) => adPriorityStringToEnumMap[e.toString()] ?? AdPriority.any)
      .toList();

  List<AdNetwork> getBannerPriorityList() {
    final List<AdNetwork> list = [];
    for (int i = 0; i < bannerAdPriorityList.length; i++) {
      if (bannerAdPriorityList[i] == AdPriority.admob) {
        list.add(AdNetwork.admob);
      } else if (bannerAdPriorityList[i] == AdPriority.facebook) {
        list.add(AdNetwork.facebook);
      } else if (bannerAdPriorityList[i] == AdPriority.appLovin) {
        list.add(AdNetwork.appLovin);
      } else if (bannerAdPriorityList[i] == AdPriority.unity) {
        list.add(AdNetwork.unity);
      }
    }
    return list;
  }
}
