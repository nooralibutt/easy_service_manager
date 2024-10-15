import 'dart:io';

import 'package:easy_service_manager/easy_service_manager.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyTestAdIdManager extends IAdIdManager {
  const MyTestAdIdManager();

  @override
  AppAdIds? get admobAdIds => AppAdIds(
        appId: Platform.isAndroid
            ? 'ca-app-pub-3940256099942544~3347511713'
            : 'ca-app-pub-3940256099942544~1458002511',
        appOpenId: Platform.isAndroid
            ? 'ca-app-pub-3940256099942544/3419835294'
            : 'ca-app-pub-3940256099942544/5575463023',
        bannerId: 'ca-app-pub-3940256099942544/6300978111',
        interstitialId: 'ca-app-pub-3940256099942544/1033173712',
        rewardedId: 'ca-app-pub-3940256099942544/5224354917',
      );

  @override
  AppAdIds? get unityAdIds => AppAdIds(
        appId: Platform.isAndroid ? '4374881' : '4374880',
        bannerId: Platform.isAndroid ? 'Banner_Android' : 'Banner_iOS',
        interstitialId:
            Platform.isAndroid ? 'Interstitial_Android' : 'Interstitial_iOS',
        rewardedId: Platform.isAndroid ? 'Rewarded_Android' : 'Rewarded_iOS',
      );

  @override
  AppAdIds? get appLovinAdIds => AppAdIds(
        appId: 'YOUR_SDK_KEY',
        bannerId: Platform.isAndroid
            ? 'ANDROID_BANNER_AD_UNIT_ID'
            : 'IOS_BANNER_AD_UNIT_ID',
        interstitialId: Platform.isAndroid
            ? 'ANDROID_INTER_AD_UNIT_ID'
            : 'IOS_INTER_AD_UNIT_ID',
        rewardedId: Platform.isAndroid
            ? 'ANDROID_REWARDED_AD_UNIT_ID'
            : 'IOS_REWARDED_AD_UNIT_ID',
      );

  @override
  AppAdIds? get fbAdIds => const AppAdIds(
        appId: '1579706379118402',
        interstitialId: 'VID_HD_16_9_15S_LINK#YOUR_PLACEMENT_ID',
        bannerId: 'IMG_16_9_APP_INSTALL#YOUR_PLACEMENT_ID',
        rewardedId: 'VID_HD_16_9_46S_APP_INSTALL#YOUR_PLACEMENT_ID',
      );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData.dark(useMaterial3: true),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WelcomeWidget(
        iconPath:
            'https://crosscode.dev/wp-content/uploads/2022/11/crosscode-horizontal-white.png',
        initializeBuilder: initializeBuilder,
        autoDone: true,
        onDone: () => onPressedStandalone(false),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          EasyServicesManager.instance.rateFloatingActionButton() ??
              const SizedBox(),
          FloatingActionButton(
            heroTag: "onFullScreenPressedStandalone",
            onPressed: () => onPressedStandalone(true),
            child: const Icon(Icons.launch),
          ),
          FloatingActionButton(
            heroTag: "onPressedStandalone",
            onPressed: () => onPressedStandalone(false),
            child: const Icon(Icons.push_pin),
          )
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  static Widget getMoreSettings() {
    return EasyServicesManager.instance.moreScreen();
  }

  void onPressedStandalone(bool fullscreenDialog) {
    Navigator.of(context).push(
      MaterialPageRoute(
          fullscreenDialog: fullscreenDialog,
          builder: (_) => Scaffold(body: getMoreSettings())),
    );
  }

  Future<void> initializeBuilder() {
    return EasyServicesManager.instance.initialize(
      adIdManager: const MyTestAdIdManager(),
      aboutAppDescription: 'You can add the app description here.',
      supportEmail: 'mail@example.com',
      itunesMoreAppLink: 'tiktok-ltd/id1322881000',
      androidDeveloperName: 'TikTok+Pte.+Ltd',
      appStoreID: '835599320',
      privacyPolicy: 'This is the privacy policy here.',
      remoteConfigEndpointUrl: 'nooralibutt.github.io/sample.json',
      wallpapersKey: _wallpapersKeyMapper,
      useNotifications: true,
      isAutoScheduleNotification: true,
      notificationsList: const [
        'This is the 1st notification',
        'This is the 2nd notification',
        'This is the 3rd notification',
        'This is the 4th notification',
      ],
    );
  }
}

String _wallpapersKeyMapper(bool isAndroidApproving, bool isIosApproving) {
  if (isAndroidApproving || isIosApproving) return 'approving_wallpapers';
  return 'wallpapers';
}
