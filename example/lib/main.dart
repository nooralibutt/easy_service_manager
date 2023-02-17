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
      aboutAppDescription:
          'Scary Teacher Chat Master consists of several activities related to mobile phone, '
          'especially texting and chat. Sometimes battle text become more attractive.\n'
          'Each Master chat scenario, where you choose what to write, is followed by one or two or'
          ' more text messages replies. Our Scary teacher Master Chat is a Master piece.',
      supportEmail: 'nallit.apps@gmail.com',
      itunesMoreAppLink: 'regent-branding-ltd/id1128207635',
      androidDeveloperName: 'Clay+Rock+Studio',
      appStoreID: '1552191588',
    );
  }

  @override
  Widget build(BuildContext context) {
    return const MoreSettings();
  }
}
