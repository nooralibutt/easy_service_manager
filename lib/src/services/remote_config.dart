typedef RemoteConfigKeyMapper =
    String Function(bool isAndroidApproving, bool isIosApproving);

class RemoteConfig {
  final bool isAndroidApproving;
  final bool isIosApproving;
  final int interstitialCounter;
  final Map<String, dynamic>? wallpapersData;
  final Map<String, dynamic>? chatLevelsData;
  final Map<String, dynamic>? presentationData;
  final Map<String, dynamic>? quizLevelCategoriesData;

  const RemoteConfig({
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
      interstitialCounter: adSettings["interstitial_ad_count"] ?? 4,
      isAndroidApproving: isAndroidApproving,
      isIosApproving: isIosApproving,
      wallpapersData: map[key] ?? map["data"],
      chatLevelsData: map["chat_levels"],
      presentationData: map["presentation_data"],
      quizLevelCategoriesData: map["quiz_level_categories"],
    );
  }
}
