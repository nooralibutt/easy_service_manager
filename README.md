# Easy Services Manager

## Features
- Support for More Settings Screen
- Support for google play store and Appstore Rating system
- Support for [`in_app_review`](https://pub.dev/packages/in_app_review)
- Support for [`easy_ads_flutter`](https://pub.dev/packages/easy_ads_flutter)
- Support for remote settings and json data like wallpapers etc
- Support for [`flutter_local_notifications`](https://pub.dev/packages/flutter_local_notifications)

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

### - IOS Tracking Transparency Permissions
For tracking transparency permissions you must have to add the following permissions:

```xml
<key>NSUserTrackingUsageDescription</key>
<string>This identifier will be used to deliver personalized ads to you.</string>
<key>ITSAppUsesNonExemptEncryption</key>
<false/>
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

#### - For AppOpen ad

```dart
EasyServicesManager.instance.showAppOpenAd();
```

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
- Add permissions in the `AndroidManifest.xml` between the `<manifest>` tag

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

The plugin also requires that the `compileSdkVersion` in your application's Gradle file is set to 33:

```gradle
android {
    compileSdkVersion 33
    ...
}
```

### AndroidManifest.xml setup

Previously the plugin would specify all the permissions required all of the features that the plugin support in its own `AndroidManifest.xml` file so that developers wouldn't need to do this in their own app's `AndroidManifest.xml` file. Since version 16 onwards, the plugin will now only specify the bare minimum and these [`POST_NOTIFICATIONS`] (https://developer.android.com/reference/android/Manifest.permission#POST_NOTIFICATIONS) and [`VIBRATE`](https://developer.android.com/reference/android/Manifest.permission#VIBRATE) permissions.

For apps that need the following functionality please complete the following in your app's `AndroidManifest.xml`

* To schedule notifications the following changes are needed
    * Specify the appropriate permissions between the `<manifest>` tags.
        * `<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>`: this is required so the plugin can known when the device is rebooted. This is required so that the plugin can reschedule notifications upon a reboot
        * If the app requires scheduling notifications with exact timings (aka exact alarms), there are two options since Android 14 brought about behavioural changes (see [here](https://developer.android.com/about/versions/14/changes/schedule-exact-alarms) for more details)
            * specify `<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM" />` and call the `requestExactAlarmsPermission()` exposed by the `AndroidFlutterNotificationsPlugin` class so that the user can grant the permission via the app or
            * specify `<uses-permission android:name="android.permission.USE_EXACT_ALARM" />`. Users will not be prompted to grant permission, however as per the official Android documentation on the `USE_EXACT_ALARM` permission (refer to [here](https://developer.android.com/about/versions/14/changes/schedule-exact-alarms#calendar-alarm-clock) and [here](https://developer.android.com/reference/android/Manifest.permission#USE_EXACT_ALARM)), this requires the app to target Android 13 (API level 33) or higher and could be subject to approval and auditing by the app store(s) used to publish theapp
    * Specify the following between the `<application>` tags so that the plugin can actually show the scheduled notification(s)
    ```xml
    <receiver android:exported="false" android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver" />
    <receiver android:exported="false" android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver">
        <intent-filter>
            <action android:name="android.intent.action.BOOT_COMPLETED"/>
            <action android:name="android.intent.action.MY_PACKAGE_REPLACED"/>
            <action android:name="android.intent.action.QUICKBOOT_POWERON" />
            <action android:name="com.htc.intent.action.QUICKBOOT_POWERON"/>
        </intent-filter>
    </receiver>
    ```
* To use full-screen intent notifications, specify the `<uses-permission android:name="android.permission.USE_FULL_SCREEN_INTENT" />` permission between the `<manifest>` tags.
* To use notification actions, specify `<receiver android:exported="false" android:name="com.dexterous.flutterlocalnotifications.ActionBroadcastReceiver" />` between the `<application>` tags so that the plugin can process the actions and trigger the appropriate callback(s)

Developers can refer to the example app's `AndroidManifest.xml` to help see what the end result may look like. Do note that the example app covers all the plugin's supported functionality so will request more permissions than your own app may need

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

### 7: How to show welcome screen
```dart
@override
  Widget build(BuildContext context) {
  return Scaffold(
    body: WelcomeScreen(
      iconPath:
      'https://crosscode.dev/wp-content/uploads/2022/11/crosscode-horizontal-white.png',
      initializeBuilder: initializeBuilder,
      nextScreenRouteName: TabScreen.routeName,
    ),
  );
}

Future<void> initializeBuilder() {
  return EasyServicesManager.instance.initialize(
    ...
  );
}
```

## Authors
##### Noor Ali Butt
[![GitHub Follow](https://img.shields.io/badge/Connect--blue.svg?logo=Github&longCache=true&style=social&label=Follow)](https://github.com/nooralibutt) [![LinkedIn Link](https://img.shields.io/badge/Connect--blue.svg?logo=linkedin&longCache=true&style=social&label=Connect
)](https://www.linkedin.com/in/nooralibutt)
##### Hanzla Waheed
[![GitHub Follow](https://img.shields.io/badge/Connect--blue.svg?logo=Github&longCache=true&style=social&label=Follow)](https://github.com/mhanzla80) [![LinkedIn Link](https://img.shields.io/badge/Connect--blue.svg?logo=linkedin&longCache=true&style=social&label=Connect
)](https://www.linkedin.com/in/mhanzla80)