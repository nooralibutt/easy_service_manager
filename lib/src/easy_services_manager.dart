class EasyServicesManager {
  EasyServicesManager._easyServicesManager();
  static final EasyServicesManager instance =
      EasyServicesManager._easyServicesManager();

  late final String? appStoreID;
  late final String? itunesMoreAppLink;
  late final String? androidDeveloperName;
  late final String? supportEmail;
  late final String? aboutAppDescription;
  late final String? appIconPath;
  late final String? privacyPolicy;

  void initialize(
      {String? appStoreID,
      String? itunesMoreAppLink,
      String? androidDeveloperName,
      String? supportEmail,
      String? aboutAppDescription,
      String? appIconPath,
      String? privacyPolicy}) {
    this.appStoreID = appStoreID;
    this.itunesMoreAppLink = itunesMoreAppLink;
    this.androidDeveloperName = androidDeveloperName;
    this.supportEmail = supportEmail;
    this.aboutAppDescription = aboutAppDescription;
    this.appIconPath = appIconPath;
    this.privacyPolicy = privacyPolicy;
  }
}
