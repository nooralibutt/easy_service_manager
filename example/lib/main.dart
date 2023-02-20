import 'package:easy_service_manager/easy_service_manager.dart';
import 'package:flutter/material.dart';

void main() {
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
  void initState() {
    super.initState();
    EasyServicesManager.instance.initialize(
      aboutAppDescription: 'You can add the app description here.',
      supportEmail: 'mail@example.com',
      itunesMoreAppLink: 'tiktok-ltd/id1322881000',
      androidDeveloperName: 'TikTok+Pte.+Ltd',
      appStoreID: '835599320',
      privacyPolicy: 'This is the privacy policy here.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: getMoreSettings(),
      floatingActionButton:
          EasyServicesManager.instance.rateFloatingActionButton(),
    );
  }

  static Widget getMoreSettings() {
    return EasyServicesManager.instance.moreScreen();
  }
}
