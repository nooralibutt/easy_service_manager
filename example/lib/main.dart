import 'package:easy_service_manager/easy_service_manager.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
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
      body: WelcomeScreen(
        initializeBuilder: initializeBuilder,
        onDone: () => onPressedStandalone(true),
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
      adIdManager: const TestAdIdManager(),
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
