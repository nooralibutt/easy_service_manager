# Easy Services Manager

## Features
- Support for More Settings Screen
- Support for google play store and Appstore Rating system
- Support for `in_app_review` system
- Support for `easy_ads_flutter` system
- Support for remote settings and json data like wallpapers etc
- Support for `flutter_local_notifications`

## How to use

### Initialization
Initialize `EasyServicesManager` on the start of the app

```dart
await EasyServicesManager.instance.initialize(
    adIdManager: const TestAdIdManager(),
    aboutAppDescription: 'You can add the app description here.',
    supportEmail: 'mail@example.com',
    itunesMoreAppLink: 'tiktok-ltd/id1322881000',
    androidDeveloperName: 'TikTok+Pte.+Ltd',
    appStoreID: '835599320',
    privacyPolicy: 'This is the privacy policy here.',
    remoteConfigEndpointUrl: 'domain/YOUR_ENDPOINT.json',
    wallpapersKey: _wallpapersKeyMapper
);
```
### How to Integrate EasyAds
For Integrate `easy_ads_flutter`, you can see the readme of the package guide, see [easy_ads_flutter](https://pub.dev/packages/easy_ads_flutter) for better understanding how to add easy_ads_flutter.
Add `AdIdManager()` class in the initializer of the `EasyServicesManager` like this

```dart
EasyServicesManager.instance.initialize(adIdManager: const TestAdIdManager())
```

### - How to get remote data form the EasyServicesManager

you can get the remote data from the `EasyServicesManager` as follow:

```dart
EasyServicesManager.instance.remoteConfig
```

There are two ways to use More Setting Screen.

### 1: Stand-Alone App mode for more setting screen

```dart
Navigator.of(context).push(
    MaterialPageRoute(
    fullscreenDialog: fullscreenDialog,
    builder: (_) => Scaffold(body: EasyServicesManager.instance.moreScreen())),
);
```

### 2: Add more setting screen to Widget-Tree

```dart
EasyServicesManager.instance.moreScreen();
```

### 3: Show Rate Floating Action Button

```dart
EasyServicesManager.instance.rateFloatingActionButton();
```

### 4: Show Custom In App Review Dialog

```dart
EasyServicesManager.instance.tryShowingCustomInAppReview();
```

### 5: How to show ads
You can show banner, Interstitial and rewarded ads like this

#### - For Banner ad

```dart
EasyServicesManager.instance.showBannerAd();
```

#### - For Interstitial ad
```dart
EasyServicesManager.instance.showInterstitialAd();
```

#### - For Counted Interstitial ad
```dart
EasyServicesManager.instance.showCountedInterstitialAd();
```

#### - For Rewarded ad
```dart
EasyServicesManager.instance.showRewardedAd();
```

### 6: How to schedule local notifications
#### - For Android
- For implement local notifications, you have to add app icon with the  name `app_icon.png` inside the android drawable `android/app/src/main/res/drawable`

You have to pass the notification list in the initializer of `EasyServicesManager`. If you do not provide the notifications list then local notifications will not be initialize.
### - Initialization
```dart
EasyServicesManager.instance.initialize(
    notificationsList: const [
      'This is the 1st notification',
      'This is the 2nd notification',
      'This is the 3rd notification',
      'This is the 4th notification',
    ],
);
```
### - Usage
##### - To Schedule All Notifications List
Call the following method to schedule all notifications list
```dart
EasyServicesManager.instance.scheduleAllNotifications();
```
##### - To Schedule Single Notification
Call the following method to schedule single notification
```dart
EasyServicesManager.instance.scheduleNotification();
```
##### - To Cancel Notification
Call the following method to cancel single notification
```dart
EasyServicesManager.instance.cancelNotification();
```
## Authors
##### Noor Ali Butt
[![GitHub Follow](https://img.shields.io/badge/Connect--blue.svg?logo=Github&longCache=true&style=social&label=Follow)](https://github.com/nooralibutt) [![LinkedIn Link](https://img.shields.io/badge/Connect--blue.svg?logo=linkedin&longCache=true&style=social&label=Connect
)](https://www.linkedin.com/in/nooralibutt)
##### Hanzla Waheed
[![GitHub Follow](https://img.shields.io/badge/Connect--blue.svg?logo=Github&longCache=true&style=social&label=Follow)](https://github.com/mhanzla80) [![LinkedIn Link](https://img.shields.io/badge/Connect--blue.svg?logo=linkedin&longCache=true&style=social&label=Connect
)](https://www.linkedin.com/in/mhanzla80)