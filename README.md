# Easy Services Manager

[![pub package](https://img.shields.io/pub/v/easy_service_manager.svg?logo=dart&logoColor=00b9fc)](https://pub.dartlang.org/packages/easy_service_manager)
[![License](https://img.shields.io/github/license/nooralibutt/easy_service_manager?logo=open-source-initiative&logoColor=green)](https://github.com/nooralibutt/easy_service_manager/blob/master/LICENSE)

**Show some 💙, 👍 the package & ⭐️ the repo to support the project**

## Features
- Support for More Settings Screen
- Support for google play store and Appstore Rating system
- Support for in app review system

## How to use

### Initialization
Initialize `EasyServicesManager` on the start of the app

```dart
await EasyServicesManager.instance.initialize(
aboutAppDescription: 'You can add the app description here.',
supportEmail: 'mail@example.com',
itunesMoreAppLink: 'tiktok-ltd/id1322881000',
androidDeveloperName: 'TikTok+Pte.+Ltd',
appStoreID: '835599320',
privacyPolicy: 'This is the privacy policy here.',
);
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

## Authors
##### Noor Ali Butt
[![GitHub Follow](https://img.shields.io/badge/Connect--blue.svg?logo=Github&longCache=true&style=social&label=Follow)](https://github.com/nooralibutt) [![LinkedIn Link](https://img.shields.io/badge/Connect--blue.svg?logo=linkedin&longCache=true&style=social&label=Connect
)](https://www.linkedin.com/in/nooralibutt)
##### Hanzla Waheed
[![GitHub Follow](https://img.shields.io/badge/Connect--blue.svg?logo=Github&longCache=true&style=social&label=Follow)](https://github.com/mhanzla80) [![LinkedIn Link](https://img.shields.io/badge/Connect--blue.svg?logo=linkedin&longCache=true&style=social&label=Connect
)](https://www.linkedin.com/in/mhanzla80)