enum AdPriority { admob, appLovin, unity, facebook, any }

extension AdPriorityExtension on AdPriority {
  String get value => name;
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
  AdPriority.any,
];

typedef RemoteConfigKeyMapper =
    String Function(bool isAndroidApproving, bool isIosApproving);

class RemoteConfig {
  final List<AdPriority> adPriorityList;
  final List<AdPriority> bannerAdPriorityList;
  final bool isAndroidApproving;
  final bool isIosApproving;
  final int interstitialCounter;
  final Map<String, dynamic>? wallpapersData;
  final Map<String, dynamic>? chatLevelsData;
  final Map<String, dynamic>? presentationData;
  final Map<String, dynamic>? quizLevelCategoriesData;

  const RemoteConfig({
    this.adPriorityList = _defaultAdPriority,
    this.bannerAdPriorityList = _defaultAdPriority,
    this.interstitialCounter = 2,
    this.isIosApproving = true,
    this.isAndroidApproving = true,
    this.wallpapersData,
    this.chatLevelsData,
    this.presentationData,
    this.quizLevelCategoriesData,
  });

  factory RemoteConfig.fromMap(
    Map<String, dynamic> map,
    RemoteConfigKeyMapper? wallpapersKey,
  ) {
    // For legacy support
    final adSettings = map["ad_settings"] ?? map;

    final isAndroidApproving = adSettings["is_android_approving"] ?? true;
    final isIosApproving = adSettings["is_ios_approving"] ?? true;
    final key =
        wallpapersKey?.call(isAndroidApproving, isIosApproving) ?? 'wallpapers';

    return RemoteConfig(
      adPriorityList: _toList(adSettings["ad_priority"]),
      bannerAdPriorityList: _toList(adSettings["banner_ad_priority"]),
      interstitialCounter: adSettings["interstitial_ad_count"] ?? 4,
      isAndroidApproving: isAndroidApproving,
      isIosApproving: isIosApproving,
      wallpapersData: map[key] ?? map["data"],
      chatLevelsData: map["chat_levels"],
      presentationData: map["presentation_data"],
      quizLevelCategoriesData: map["quiz_level_categories"],
    );
  }

  static List<AdPriority> _toList(final List<dynamic>? list) {
    if (list == null) {
      return _defaultAdPriority;
    } else {
      return list
          .map<AdPriority>(
            (e) => adPriorityStringToEnumMap[e.toString()] ?? AdPriority.any,
          )
          .toList();
    }
  }
}
